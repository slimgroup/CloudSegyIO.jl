module GCPBucketSeisIO
    using GoogleCloud
    using SeisIO

    # SeisIO imports
    import SeisIO: segy_read

    #Reader
    include("read/segy_read.jl")

end # module
