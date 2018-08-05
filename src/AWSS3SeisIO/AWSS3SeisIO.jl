module AWSS3SeisIO
    using AWSCore
        using AWSS3
    using Retry
    using SeisIO
    using ..common: trace_buffer_parts

    # SeisIO imports
    import SeisIO: read_file, segy_read

    #Reader
    include("read/AWSS3extras.jl")
    include("read/read_file.jl")
    include("read/segy_read.jl")

end # module
