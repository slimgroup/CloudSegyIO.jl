export segy_read

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String)
"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String; buffer::Bool = true, warn_user::Bool = true)
    
    s3_exists(aws, bucket, path) || error("AWSS3SeisIO/segy_read: file $path does not exist in $bucket.")
    if buffer
        s = IOBuffer(s3_get(aws, bucket, path);)
    else
        #s = open(file)
        error("AWSS3SeisIO/segy_read: direct IO not implemented in AWSS3.")
    end

    read_file(s, warn_user)
end

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1})
"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1}; buffer::Bool = true, warn_user::Bool = true)
    
    s3_exists(aws, bucket, path) || error("AWSS3SeisIO/segy_read: file $path does not exist in $bucket.")
    if buffer
        s = IOBuffer(s3_get(aws, bucket, path);)
    else
        #s = open(file)
        error("AWSS3SeisIO/segy_read: direct IO not implemented in AWSS3.")
    end

    read_file(s, keys, warn_user)
end
