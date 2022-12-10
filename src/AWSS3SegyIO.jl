module AWSS3SegyIO
    using AWSS3, AWS

    using Retry
    using SegyIO

    function my_s3_get_range(aws::AWSConfig, bucket, path, rstart::Int, rend::Int; version="",
                                                retry=true,
                                                raw=false)

        hdr=Dict("Range"=>"bytes=$rstart-$rend")

        @repeat 4 try
            return AWSS3.s3(aws, "GET", bucket; path = path,
                                        version = version,
                                        return_raw = raw,
                                        headers = hdr)

        catch e
            @delay_retry if retry && ecode(e) in ["NoSuchBucket", "NoSuchKey"] end
        end
    end

    my_s3_get_range(a...; b...) = my_s3_get_range(default_aws_config(), a...; b...)

    struct S3File <: AbstractString
        aws::AWS.AWSConfig
        bucket::String
        name::String
    end

    Base.display(f::S3File) = println("S3File($(f.bucket), $(f.name))")
    Base.show(io::IO, f::S3File) = print(io, "S3File($(f.bucket), $(f.name))")
    Base.show(io::IO, m::String, f::S3File) = print(io, "S3File($(f.bucket), $(f.name))")
    Base.print(io::IOBuffer, f::S3File) = print(io, "S3File($(f.bucket), $(f.name))")

    Base.open(f::S3File) = S3FileIO(f, 0, 0)
    Base.filesize(f::S3File) = s3_get_meta(f.aws, f.bucket, f.name)["Content-Length"]

    mutable struct S3FileIO <: IO
        o::S3File
        offset::Integer  # Used for seek
        ref::Integer
    end

    Base.filesize(f::S3FileIO) = filesize(f.o)
    Base.close(::S3FileIO) = nothing
    Base.open(::S3FileIO) = nothing

    Base.seek(s::S3FileIO, pos::Integer) = begin s.offset = pos; s end
    Base.skip(s::S3FileIO, nb::Integer) = begin s.offset += nb; s end
    Base.mark(s::S3FileIO) = begin s.ref = s.offset; s end
    Base.reset(s::S3FileIO) = begin s.offset = s.ref; s end
    Base.eof(s::S3FileIO) = s.offset >= filesize(s.o)

    function Base.seekend(s::S3FileIO)
        s.offset = filesize(s)
        s
    end

    Base.position(s::S3FileIO) = s.offset

    function Base.read(s::S3FileIO, nb::Integer)
        r = my_s3_get_range(s.o.aws, s.o.bucket, s.o.path, s.offset, s.offset+nb-1)
        skip(s, nb)
        r
    end

    for DT in [Int32, Int16]
        @eval Base.read(s::S3FileIO, ::Type{$DT}) = read(s, sizof($T))
    end

    # SegyIO
    function SegyIO.segy_read(aws::AWS.AWSConfig, bucket::String, path::String; warn_user::Bool = true)
        s = S3FileIO(S3File(aws, bucket, path), 0, 0)
        read_file(s, warn_user)
    end


    function SegyIO.segy_scan(aws::AWS.AWSConfig, bucket::String, filt::Union{String, Regex}, keys::Array{String,1}; 
                              chunksize::Int = SegyIO.CHUNKSIZE, pool::WorkerPool=WorkerPool(workers()),
                              verbosity::Int = 1,  filter::Bool = true)
        filenames = filter ? SegyIO.searchdir((aws, bucket), filt) : [filt]
        files = map(x -> S3File(aws, bucket, string(x)), filenames)
        run_scan(f) = scan_file(f, keys, chunksize=chunksize, verbosity=verbosity)
        s = pmap(run_scan, pool, files)
        return merge(s)
    end
    Base.readdir(a::Tuple{AWS.AWSConfig, String}) = AWSS3.s3_list_objects(a[1], a[2])

end # module
