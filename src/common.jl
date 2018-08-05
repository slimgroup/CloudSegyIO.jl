module common

    export trace_buffer_parts
    """
    buf_sizes, trace_idx = trace_buffer_parts(nbufs::Integer,ntraces::Integer)
    
    """
    function trace_buffer_parts(nbufs::Integer,ntraces::Integer)
        part = Vector{Int}(nbufs)
        idxs = Vector{Int}(nbufs+1)
        r::Int = rem(ntraces,nbufs)
        c::Int = ceil(Int,ntraces/nbufs)
        f::Int = floor(Int,ntraces/nbufs)
        part[1:r]       = c
        part[r+1:nbufs] = f
        @assert sum(part)==ntraces "FATAL ERROR: failed to properly partition $ntraces to $nbufs workers"
        for i=0:nbufs idxs[i+1]=sum(part[1:i])+1 end
        return part,idxs
    end

end
