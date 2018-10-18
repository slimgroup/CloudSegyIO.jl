export segy_read

"""
block = segy_read(gcp::GoogleCloud.credentials.JSONCredentials, bucket::String, path::String)

# Optional Keyword Arguments

- `multipart=false`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if multipart=true
- `warn_user=true`: explict warnings

"""
function segy_read(gcp::GoogleCloud.credentials.JSONCredentials, bucket::String, path::String; multipart::Bool=false, buffer_size::Int=1024, warn_user::Bool=true)
    
    if multipart
        error("GCPBucketSeisIO/segy_read: multipart read is not supported")
    else
        session=GoogleSession(gcp, ["devstorage.full_control"])
        set_session!(GoogleCloud.storage, session)
        s = IOBuffer(storage(:Object, :get, bucket, path);)
        return read_file(s, warn_user)
    end

end

"""
block = segy_read(gcp::GoogleCloud.credentials.JSONCredentials, bucket::String, path::String, keys::Array{String,1})

# Optional Keyword Arguments

- `multipart=false`: read entire object in single REST request (beware of memory overhead for large objects)
- `buffer_size=1024`: buffer size [MB] if multipart=true
- `warn_user=true`: explict warnings

"""
function segy_read(gcp::GoogleCloud.credentials.JSONCredentials, bucket::String, path::String, keys::Array{String,1}; multipart::Bool=false, buffer_size::Int=1024, warn_user::Bool=true)
    
    if multipart
        error("GCPBucketSeisIO/segy_read: multipart read is not supported")
    else
        session=GoogleSession(gcp, ["devstorage.full_control"])
        set_session!(GoogleCloud.storage, session)
        s = IOBuffer(storage(:Object, :get, bucket, path);)
        return read_file(s, keys, warn_user)
    end

end