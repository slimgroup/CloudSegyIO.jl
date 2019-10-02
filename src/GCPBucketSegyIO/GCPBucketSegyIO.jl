module GCPBucketSegyIO
    using GoogleCloud
    using SegyIO

    # SegyIO imports
    import SegyIO: segy_read

    #Reader
    include("read/segy_read.jl")

end # module
