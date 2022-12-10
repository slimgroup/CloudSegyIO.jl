module CloudSegyIO

include("common.jl")
include("AWSS3SegyIO/AWSS3SegyIO.jl")
include("AzureBlobSegyIO/AzureBlobSegyIO.jl")
export AWSS3SegyIO, AzureBlobSegyIO

end # module
