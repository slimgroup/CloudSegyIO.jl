using AWS, CloudSegyIO.AWSS3SegyIO, SegyIO, SlimPlotting

aws = global_aws_config()
bucket = "slim-bucket-common/bp-tti"


@time shot = segy_read(aws, bucket, "BPTTI_121.segy")

@time segy_write(aws, bucket, "BPTTI_121-copy.segy", shot)

@time block = segy_scan(aws, bucket, "BPTTI_12", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])
