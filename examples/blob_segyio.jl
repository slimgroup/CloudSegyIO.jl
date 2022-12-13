using SegyIO, AzStorage, CloudSegyIO.AzureBlobSegyIO, AzSessions, SlimPlotting

# Configuration
# You will need tpo configure AzSession for your credentials and replace the `resource` , `storageaccount` and `blob`(bp-tti)
# By your own path
session = AzSession(;protocol=AzClientCredentials, resource="https://slimstorage.blob.core.windows.net/")
container = AzContainer("bp-tti"; storageaccount="slimstorage", session=session)

# Create the CloudPath and CloudFile object compatible with SegyIO
cloudpath = BlobPath(container)
# Replace the segy files below by your own in your container
cloudfile = BlobFile(cloudpath, "BPTTI_641.segy")
cloudfilewrite = BlobFile(cloudpath, "BPTTI_641-copy.segy")

@time block = segy_scan(cloudpath, "BPTTI_101", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])

@time shot = segy_read(cloudfile)

@time segy_write(cloudfilewrite, shot)