using AWS, CloudSegyIO.AWSS3SegyIO, SegyIO, SlimPlotting, AzStorage, CloudSegyIO.AzureBlobSegyIO, AzSessions

# Configuration
# You will need tpo configure AzSession for your credentials and replace the `resource`, `storageaccount`, `aws`, `bucket` and `blob`(bp-tti)
# By your own path
aws = global_aws_config()
bucket = "slim-bucket-common/bp-tti"
session = AzSession(;protocol=AzClientCredentials, resource="https://slimstorage.blob.core.windows.net/")
container = AzContainer("bp-tti"; storageaccount="slimstorage", session=session)

# Create the CloudPath for s3
s3path = S3Bucket(aws, bucket)

# Create the CloudPath for blob
blobpath = BlobPath(container)

# Make a global lookup table for dataset spread accross both cloud storage
# Replace the BPTTI by the string to filter thorugh your own container
@time block = segy_scan([s3path, blobpath], "BPTTI_130", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])

# Get all data and plot
data = hcat([block[i].data for i=1:length(block)]...)
# Plot with dummy units
plot_sdata(data, (6f0, 12.5f0); cmap="PuOr")