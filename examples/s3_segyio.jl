using AWS, CloudSegyIO.AWSS3SegyIO, SegyIO, SlimPlotting

# Configuration
aws = global_aws_config()
# Replace by your own bucket
bucket = "slim-bucket-common/bp-tti"

# Create the CloudPath and CloudFile object compatible with SegyIO
cloudpath = S3Bucket(aws, bucket)
# Replace by your own file names
cloudfile = S3File(cloudpath, "BPTTI_130.segy")
cloudfilewrite = S3File(cloudpath, "BPTTI_130-copy.segy")


@time shot = segy_read(cloudfile)
@time segy_write(cloudfilewrite, shot)
@time block = segy_scan(cloudpath, "BPTTI_1", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])


########### We can also directly read open data on S3
# For examplke we can read the 1997 BP 2.5D migration benchmark model from
# https://wiki.seg.org/wiki/1997_BP_2.5D_migration_benchmark_model

public_bucket = "open.source.geoscience/open_data/bp2.5d1997/"
bp1997 = S3File(public_bucket, "model.segy")

vp = convert(Matrix{Float32}, segy_read(bp1997).data);
plot_velocity(vp, (10f0, 10f0))