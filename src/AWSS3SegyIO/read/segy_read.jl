export segy_read

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String)

# Optional Keyword Arguments

- `multipart=false`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if multipart=true
- `warn_user=true`: explict warnings

"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String; multipart::Bool=false, buffer_size::Int=1024, warn_user::Bool=true)
    
    s3_exists(aws, bucket, path) || @error "AWSS3SegyIO/segy_read: file $path does not exist in $bucket."
    if multipart
        return read_file(aws, bucket, path, warn_user)
    else
        s = IOBuffer(s3_get(aws, bucket, path);)
        return read_file(s, warn_user)
    end

end

"""
block = segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1})

# Optional Keyword Arguments

- `multipart=false`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if multipart=true
- `warn_user=true`: explict warnings

"""
function segy_read(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1}; multipart::Bool=false, buffer_size::Int=1024, warn_user::Bool=true)
    
    s3_exists(aws, bucket, path) || @error "AWSS3SegyIO/segy_read: file $path does not exist in $bucket."
    if multipart
        return read_file(aws, bucket, path, keys, warn_user)
    else
        s = IOBuffer(s3_get(aws, bucket, path);)
        return read_file(s, keys, warn_user)
    end

end
