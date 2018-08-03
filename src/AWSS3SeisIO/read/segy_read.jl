export segy_read

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String)

# Optional Keyword Arguments

- `single_request=true`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if single_request=false
- `warn_user=true`: explict warnings

"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String; single_request::Bool=true, buffer_size::Int=1024, warn_user::Bool=true)
    
    s3_exists(aws, bucket, path) || error("AWSS3SeisIO/segy_read: file $path does not exist in $bucket.")
    if single_request
        s = IOBuffer(s3_get(aws, bucket, path);)
        return read_file(s, warn_user)
    else
        #s = open(file)
        error("AWSS3SeisIO/segy_read: direct IO not implemented in AWSS3.")
    end

end

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1})

# Optional Keyword Arguments

- `single_request=true`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if single_request=false
- `warn_user=true`: explict warnings

"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1}; single_request::Bool=true, buffer_size::Int=1024, warn_user::Bool=true)
    
    s3_exists(aws, bucket, path) || error("AWSS3SeisIO/segy_read: file $path does not exist in $bucket.")
    if single_request
        s = IOBuffer(s3_get(aws, bucket, path);)
        return read_file(s, keys, warn_user)
    else
        #s = open(file)
        error("AWSS3SeisIO/segy_read: direct IO not implemented in AWSS3.")
    end

end
