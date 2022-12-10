module AWSS3SegyIO
    using AWS

    using Retry
    using SegyIO
    using ..common: trace_buffer_parts

    # SegyIO imports
    import SegyIO: read_file, segy_read

    #Reader
    include("read/AWSS3extras.jl")
    include("read/read_file.jl")
    include("read/segy_read.jl")

end # module
