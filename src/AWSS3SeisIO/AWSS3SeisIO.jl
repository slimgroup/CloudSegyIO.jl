module AWSS3SeisIO
    using AWSCore
        using AWSS3
    using SeisIO

    # SeisIO imports
    import SeisIO: segy_read

    #Reader
    include("read/segy_read.jl")

end # module
