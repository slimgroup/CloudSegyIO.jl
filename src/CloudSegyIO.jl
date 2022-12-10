module CloudSegyIO

export AWSS3SegyIO, AzureBlobSegyIO

# S3, read/scan only, write not implemented
include("AWSS3SegyIO.jl")
# Azure blob, read, scan and write
include("AzureBlobSegyIO.jl")

end # module
