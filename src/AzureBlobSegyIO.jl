module AzureBlobSegyIO
    using AzStorage, Distributed
    import AzStorage: AzObject, AzContainer

    using SegyIO

    struct AzBlobFile <: AbstractString
        container::AzContainer
        name::String
    end

    Base.display(f::AzBlobFile) = println("AzBlob($(f.container), $(f.name))")
    Base.show(io::IO, f::AzBlobFile) = print(io, "AzBlob($(f.container), $(f.name))")
    Base.show(io::IO, m::String, f::AzBlobFile) = print(io, "AzBlob($(f.container), $(f.name))")
    Base.print(io::IOBuffer, f::AzBlobFile) = print(io, "AzBlob($(f.container), $(f.name))")

    Base.open(f::AzBlobFile) = AzFileIO(AzObject(f.container, f.name), 0, 0)
    Base.filesize(f::AzBlobFile) = filesize(AzObject(f.container, f.name))

    mutable struct AzFileIO <: IO
        o::AzObject
        offset::Integer  # Used for seek
        ref::Integer
    end

    Base.filesize(f::AzFileIO) = filesize(f.o)
    Base.close(::AzFileIO) = nothing
    Base.open(::AzFileIO) = nothing

    Base.seek(s::AzFileIO, pos::Integer) = begin s.offset = pos; s end
    Base.skip(s::AzFileIO, nb::Integer) = begin s.offset += nb; s end
    Base.mark(s::AzFileIO) = begin s.ref = s.offset; s end
    Base.reset(s::AzFileIO) = begin s.offset = s.ref; s end
    Base.eof(s::AzFileIO) = s.offset >= filesize(s.o)

    function Base.seekend(s::AzFileIO)
        s.offset = filesize(s.o)
        s
    end

    Base.position(s::AzFileIO) = s.offset

    function Base.read(s::AzFileIO, nb::Integer)
        r = AzStorage.readbytes!(s.o.container, s.o.name, Vector{UInt8}(undef, nb); offset=div(s.offset, sizeof(UInt8)))
        skip(s, nb)
        r
    end

    for DT in [Int32, Int16]
        @eval function Base.read(s::AzFileIO, ::Type{$DT})
            r = read!(s.o.container, s.o.name, Vector{$DT}(undef, 1); offset=div(s.offset, sizeof($DT)))[1]
            skip(s, sizeof($DT))
            r
        end
    end

    # SegyIO
    function SegyIO.segy_read(container::AzContainer, name::AbstractString; warn_user::Bool = true)
        mkpath(container)
        s = AzFileIO(AzObject(container, string(name)), 0, 0)
        read_file(s, warn_user)
    end

    function SegyIO.segy_write(container::AzContainer, name::AbstractString, block::SeisBlock)
        io = IOBuffer(;write=true, read=true)
        segy_write(io, block)
        AzStorage.writebytes(container, name, take!(io); contenttype="application/octet-stream")
        close(io)
    end

    function SegyIO.segy_scan(container::AzContainer, filt::Union{String, Regex}, keys::Array{String,1}; 
                              chunksize::Int = SegyIO.CHUNKSIZE, pool::WorkerPool=WorkerPool(workers()),
                              verbosity::Int = 1,  filter::Bool = true)
        filenames = filter ? SegyIO.searchdir(container, filt) : [filt]
        files = map(x -> AzBlobFile(container, string(x)), filenames)
        run_scan(f) = scan_file(f, keys, chunksize=chunksize, verbosity=verbosity)
        s = pmap(run_scan, pool, files)
        return merge(s)
    end

end
