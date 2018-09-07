module CloudSeisIO

include("common.jl")
include("AWSS3SeisIO/AWSS3SeisIO.jl")
export AWSS3SeisIO
include("GCPBucketSeisIO/GCPBucketSeisIO.jl")
export GCPBucketSeisIO

end # module
