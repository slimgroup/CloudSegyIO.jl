export read_file

"""
read_file(aws,bicket,path,warn_user)

Read entire SEGY files from object in the AWS S3 bucket.

"""
function read_file(aws::AWSCore.AWSConfig, bucket::String, path::String, warn_user::Bool;
    buffer_size::Int=1024, start_byte::Int=3600, end_byte::Int=0 )
    
    verbose = false
    debug = false

    # Read and check sizes
    if end_byte==0
        end_byte = s3_get_meta(aws,bucket,path)["Content-Length"]
        end_byte = parse(Int,end_byte)
    end
    end_byte > start_byte || error("Fatal error: start_byte ($start_byte) < end_byte ($end_byte)")
    data_sz = end_byte - start_byte
    max_buf_sz = buffer_size * (1024^2)

    # Read File Header
    s=IOBuffer(AWSS3SeisIO.my_s3_get_range(aws,bucket,path,0,3599))
    fh = read_fileheader(s)
    
    # Move to start of block
    seek(s, start_byte)
    debug && println((start_byte,end_byte,length(s.data)))

    # Check datatype of file
    datatype = Float32
    if fh.bfh.DataSampleFormat == 1
        datatype = SeisIO.IBMFloat32
    elseif fh.bfh.DataSampleFormat != 5
        error("Data type not supported ($(fh.bfh.DataSampleFormat))")
    end

    # Check fixed length trace flag
    (fh.bfh.FixedLengthTraceFlag!=1 & warn_user) && warn("Fixed length trace flag set in stream: $s")
    
    ## Check for extended text header

    # Read traces
    trace_byte_len = 240 + fh.bfh.ns*4
    ntraces = Int(data_sz/trace_byte_len)
    max_tr_per_buf = Int(floor(max_buf_sz/trace_byte_len))
    nbuffers = Int(ceil(ntraces/max_tr_per_buf))
    debug && println((ntraces,fh.bfh.ns,trace_byte_len,data_sz,max_buf_sz,max_tr_per_buf,nbuffers))
    buf_sizes, trace_idx = trace_buffer_parts(nbuffers,ntraces)
    debug && println(buf_sizes)
    debug && println(trace_idx)

    # Preallocate memory
    headers = Array{BinaryTraceHeader, 1}(ntraces)
    data = Array{datatype, 2}(fh.bfh.ns, ntraces)
    th_b2s = th_byte2sample()

    # Read buffer
    for buffer=1:nbuffers
        buffer_start = start_byte + (trace_idx[buffer]-1)*trace_byte_len
        buffer_end = start_byte + (trace_idx[buffer+1]-1)*trace_byte_len-1
        s=IOBuffer(AWSS3SeisIO.my_s3_get_range(aws,bucket,path,buffer_start,buffer_end))
        # Read each trace
        for trace in trace_idx[buffer]:trace_idx[buffer+1]-1

            verbose && println("buffer $buffer $buffer_start $buffer_end trace $trace $(position(s)) $(position(s)+trace_byte_len-1)")
            SeisIO.read_trace!(s, fh.bfh, datatype, headers, data, trace, th_b2s)

        end
    end

    return SeisBlock(fh, headers, data)
end

"""
read_file(aws,bicket,path,keys,warn_user)

Read entire SEGY files from object in the AWS S3 bucket,
only reading the header values in 'keys'.

"""
function read_file(aws::AWSCore.AWSConfig, bucket::String, path::String, keys::Array{String,1}, warn_user::Bool;
    buffer_size::Int=1024, start_byte::Int=3600, end_byte::Int=0 )
    
    verbose = false
    debug = false

    # Read and check sizes
    if end_byte==0
        end_byte = s3_get_meta(aws,bucket,path)["Content-Length"]
        end_byte = parse(Int,end_byte)
    end
    end_byte > start_byte || error("Fatal error: start_byte ($start_byte) < end_byte ($end_byte)")
    data_sz = end_byte - start_byte
    max_buf_sz = buffer_size * (1024^2)

    # Read File Header
    s=IOBuffer(AWSS3SeisIO.my_s3_get_range(aws,bucket,path,0,3599))
    fh = read_fileheader(s)
    
    # Move to start of block
    seek(s, start_byte)
    debug && println((start_byte,end_byte,length(s.data)))

    # Check datatype of file
    datatype = Float32
    if fh.bfh.DataSampleFormat == 1
        datatype = SeisIO.IBMFloat32
    elseif fh.bfh.DataSampleFormat != 5
        error("Data type not supported ($(fh.bfh.DataSampleFormat))")
    end

    # Check fixed length trace flag
    (fh.bfh.FixedLengthTraceFlag!=1 & warn_user) && warn("Fixed length trace flag set in stream: $s")
    
    ## Check for extended text header

    # Read traces
    trace_byte_len = 240 + fh.bfh.ns*4
    ntraces = Int(data_sz/trace_byte_len)
    max_tr_per_buf = Int(floor(max_buf_sz/trace_byte_len))
    nbuffers = Int(ceil(ntraces/max_tr_per_buf))
    debug && println((ntraces,fh.bfh.ns,trace_byte_len,data_sz,max_buf_sz,max_tr_per_buf,nbuffers))
    buf_sizes, trace_idx = trace_buffer_parts(nbuffers,ntraces)
    debug && println(buf_sizes)
    debug && println(trace_idx)

    # Preallocate memory
    headers = Array{BinaryTraceHeader, 1}(ntraces)
    data = Array{datatype, 2}(fh.bfh.ns, ntraces)
    th_b2s = th_byte2sample()

    # Read buffer
    for buffer=1:nbuffers
        buffer_start = start_byte + (trace_idx[buffer]-1)*trace_byte_len
        buffer_end = start_byte + (trace_idx[buffer+1]-1)*trace_byte_len-1
        s=IOBuffer(AWSS3SeisIO.my_s3_get_range(aws,bucket,path,buffer_start,buffer_end))
        # Read each trace
        for trace in trace_idx[buffer]:trace_idx[buffer+1]-1

            verbose && println("buffer $buffer $buffer_start $buffer_end trace $trace $(position(s)) $(position(s)+trace_byte_len-1)")
            SeisIO.read_trace!(s, fh.bfh, datatype, headers, data, trace, keys, th_b2s)

        end
    end

    return SeisBlock(fh, headers, data)
end

