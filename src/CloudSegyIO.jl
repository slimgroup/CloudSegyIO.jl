module CloudSegyIO

include("common.jl")
include("AWSS3SegyIO/AWSS3SegyIO.jl")
export AWSS3SegyIO
include("GCPBucketSegyIO/GCPBucketSegyIO.jl")
export GCPBucketSegyIO

end # module
