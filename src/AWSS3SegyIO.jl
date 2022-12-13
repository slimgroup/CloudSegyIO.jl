module AWSS3SegyIO
    using AWSS3, AWS, Distributed, SegyIO, Retry

    import CloudSegyIO: CloudPath, CloudFile, CloudIO
    import SegyIO: segy_write

    export S3File, S3Bucket

    ## BAse reader for s3 that reads a specific byte range
    function my_s3_get_range(aws::AWSConfig, bucket, path, rstart::Int, rend::Int; retry=false)
        hdr=Dict("Range"=>"bytes=$rstart-$rend")
        @repeat 4 try
            return AWSS3.s3_get(aws, bucket, path; retry=false, headers=hdr)
        catch e
            @delay_retry if retry && ecode(e) in ["NoSuchBucket", "NoSuchKey"] end
        end
    end

    my_s3_get_range(a...; b...) = my_s3_get_range(global_aws_config(), a...; b...)

    # Base write for S3. Can only write a full IO stream not specific byte ranges
    function s3_write_io(io::IO, aws::AWSConfig, bucket, path; retry=false)
        @repeat 4 try
            return AWSS3.s3_put(aws, bucket, path, take!(io), "application/octet-stream")
        catch e
            @delay_retry if retry && ecode(e) in ["NoSuchBucket", "NoSuchKey"] end
        end
    end

    # Wrapper for a S3 bucket as a string path
    struct S3Bucket <: CloudPath
        aws::AWS.AWSConfig
        bucket::String
    end

    Base.:(*)(p::S3Bucket, s::String) = S3File(p, s)
    Base.string(p::S3Bucket) = "s3:$(p.bucket)"
    Base.readdir(p::S3Bucket) = readdir(S3Path("s3://$(p.bucket)/"))

    # Wrapper for a S3 file
    struct S3File <: CloudFile
        p::S3Bucket
        name::String
    end

    Base.open(f::S3File) = S3FileIO(f, 0, 0)
    Base.filesize(f::S3File) = parse(Int64, s3_get_meta(f.p.aws, f.p.bucket, f.name)["Content-Length"])
    Base.string(f::S3File) = "$(f.p)/$(f.name)"

    # Wrapper for a and IO object in S3.
    mutable struct S3FileIO <: CloudIO
        o::S3File
        offset::Integer  # Used for seek
        ref::Integer
    end

    Base.filesize(f::S3FileIO) = filesize(f.o)

    function Base.read(s::S3FileIO, nb::Integer)
        r = my_s3_get_range(s.o.p.aws, s.o.p.bucket, s.o.name, s.offset, s.offset+nb-1)
        skip(s, nb)
        r
    end

    # SegyIO
    function segy_write(f::S3File, block::SeisBlock)
        io = IOBuffer(;write=true, read=true)
        segy_write(io, block)
        s3_write_io(io, f.p.aws, f.p.bucket, f.name)
        close(io)
    end
end # module
