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

    function SegyIO.segy_scan(container::AzContainer, filt::Union{String, Regex}, keys::Array{String,1}; 
                              chunksize::Int = SegyIO.CHUNKSIZE, pool::WorkerPool=WorkerPool(workers()),
                              verbosity::Int = 1,  filter::Bool = true)
        filenames = filter ? SegyIO.searchdir(container, filt) : [filt]
        @show filenames
        files = map(x -> AzBlobFile(container, string(x)), filenames)
        @show files
        run_scan(f) = scan_file(f, keys, chunksize=chunksize, verbosity=verbosity)
        s = pmap(run_scan, pool, files)
        return merge(s)
    end

    function scan_chunk!(s::AzFileIO, max_blocks_per_chunk::Int, mem_block::Int, mem_trace::Int,
                        keys::Array{String,1}, file::String, scan::Array{BlockScan,1}, count::Int)
                    
        io = IOBuffer(read(s, max_blocks_per_chunk*mem_block))
        scan_chunk!(io, max_blocks_per_chunk, mem_block, mem_trace, keys, file, scan, count)
    end

    function scan_shots!(s::AzFileIO, mem_chunk::Int, mem_trace::Int, keys::Array{String,1},
                         file::String, scan::Array{BlockScan,1}, fl_eof::Bool)

        @show div(mem_chunk, 4), filesize(s)
        io = IOBuffer(read(s, div(mem_chunk, 4)))
        scan_shots!(io, mem_chunk, mem_trace, keys, file, scan,fl_eof)
    end
end
