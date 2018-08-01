function my_s3_get_range(aws::AWSConfig, bucket, path, rstart::Int, rend::Int; version="",
                                              retry=true,
                                              raw=false)

    hdr=Dict("Range"=>"bytes=$rstart-$rend")

    @repeat 4 try

        return AWSS3.s3(aws, "GET", bucket; path = path,
                                      version = version,
                                      return_raw = raw,
                                      headers = hdr)

    catch e
        @delay_retry if retry && ecode(e) in ["NoSuchBucket", "NoSuchKey"] end
    end
end

my_s3_get_range(a...; b...) = my_s3_get_range(default_aws_config(), a...; b...)

