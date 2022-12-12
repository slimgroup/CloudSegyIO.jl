module CloudSegyIO

using SegyIO

export AWSS3SegyIO, AzureBlobSegyIO

######### Base abstract types and methods

"""
    Abstract String representing a "path" in Cloud storage

Instantiated CloudPath must imnplement:
    - `string(p::CloudPath)::String` string representation of the path
    - `Base.*(p::CloudPath, f::String)::CloudFile` combing the path and a filename into a CloudFile
"""
abstract type CloudPath <: AbstractString end

Base.display(p::CloudPath) = println("CloudPath($(string(p))")
Base.show(io::IO, p::CloudPath) = print(io, "CloudPath($(string(p)))")
Base.show(io::IO, ::String, p::CloudPath) = print(io, "CloudPath($(string(p)))")
Base.print(io::IOBuffer, p::CloudPath) = print(io, "CloudPath($(string(p)))")
Base.endswith(p::CloudPath, s::String) = true

"""
    Abstract String representing a File in Cloud storage

Instantiated CloudFile must implement:
    - `open(f::CloudFile)::CloudIO` open the cloud object as a readable CloudIO
    - `string(f::CloudFile)::String` string representation of the file
    - `filesize(f::CloudFile)::Integer` size in bytes of the file
"""
abstract type CloudFile <: AbstractString end

Base.display(f::CloudFile) = println("CloudFile($(string(f))")
Base.show(io::IO, f::CloudFile) = print(io, "CloudFile($(string(f)))")
Base.show(io::IO, ::String, f::CloudFile) = print(io, "CloudFile($(string(f)))")
Base.print(io::IOBuffer, f::CloudFile) = print(io, "CloudFile($(string(f)))")
SegyIO.segy_read(f::CloudFile; warn_user::Bool=true, buffer::Bool=true) = read_file(open(f), warn_user)

"""
Generic CloudIO object with offset tracking to read specific bytes.

Any instantiated struct of type CloudIO must have  `offset::Integer` and `ref::Integer` as properties

Any instantiated struct of type CloudIO must implement:
    `filesize(f::CloudIO)` : Size of the underlying file in bytes
    `read(f::CloudIO, nb::Integer)` : Read `nb` bytes from f
"""
abstract type CloudIO <: IO end

Base.close(::CloudIO) = nothing
Base.open(::CloudIO) = nothing

Base.seek(s::CloudIO, pos::Integer) = begin s.offset = pos; s end
Base.skip(s::CloudIO, nb::Integer) = begin s.offset += nb; s end
Base.mark(s::CloudIO) = begin s.ref = s.offset; s end
Base.reset(s::CloudIO) = begin s.offset = s.ref; s end
Base.eof(s::CloudIO) = s.offset >= filesize(s)
Base.seekend(s::CloudIO) = begin s.offset = filesize(s); s end
Base.position(s::CloudIO) = s.offset

for DT in [Int32, Int16]
    @eval Base.read(s::CloudIO, ::Type{$DT}) = reinterpret($(DT), read(s, sizeof($DT)))
end

# S3, read/scan only, write not implemented
include("AWSS3SegyIO.jl")
# Azure blob, read, scan and write
include("AzureBlobSegyIO.jl")

end # module
