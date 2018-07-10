module AWSS3SeisIO
    using AWSCore
        using AWSS3
    using SeisIO

    #Reader
    include("read/segy_read.jl")

end # module
