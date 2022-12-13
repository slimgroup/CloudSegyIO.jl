module AzureBlobSegyIO
    using AzStorage, Distributed, SegyIO

    import AzStorage: AzContainer
    import CloudSegyIO: CloudPath, CloudFile, CloudIO
    import SegyIO: segy_write

    export BlobFile, BlobPath

    # Wrapper for a blob container as a string path
    struct BlobPath <: CloudPath
        container::AzContainer
    end

    Base.:(*)(p::BlobPath, s::String) = BlobFile(p, s)
    Base.string(p::BlobPath) = "blob:$(p.container.storageaccount)/$(p.container.containername)"
    Base.readdir(p::BlobPath) = readdir(p.container)

    # Wrapper for a blob file
    struct BlobFile <: CloudFile
        p::BlobPath
        name::String
    end

    Base.string(f::BlobFile) = "$(f.p)/$(f.name)"
    Base.open(f::BlobFile) = AzFileIO(f, 0, 0)
    Base.filesize(f::BlobFile) = filesize(f.p.container, f.name)

    # Wrapper for a and IO object in blob.
    mutable struct AzFileIO <: CloudIO
        f::BlobFile
        offset::Integer  # Used for seek
        ref::Integer
    end

    Base.filesize(f::AzFileIO) = filesize(f.f)

    function Base.read(s::AzFileIO, nb::Integer)
        r = AzStorage.readbytes!(s.f.p.container, s.f.name, Vector{UInt8}(undef, nb); offset=div(s.offset, sizeof(UInt8)))
        skip(s, nb)
        r
    end

    function SegyIO.segy_write(f::BlobFile, block::SeisBlock)
        io = IOBuffer(;write=true, read=true)
        segy_write(io, block)
        AzStorage.writebytes(f.p.container, f.name, take!(io); contenttype="application/octet-stream")
        close(io)
    end
end
