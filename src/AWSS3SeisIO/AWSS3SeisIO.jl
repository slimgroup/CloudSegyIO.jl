module AWSS3SeisIO
    using AWSCore
        using AWSS3
    using Retry
    using SeisIO

    # SeisIO imports
    import SeisIO: segy_read

    #Reader
    include("read/AWSS3extras.jl")
    include("read/segy_read.jl")

end # module
