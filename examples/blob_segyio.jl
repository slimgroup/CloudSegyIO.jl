using SegyIO, AzStorage, CloudSegyIO.AzureBlobSegyIO, AzSessions, SlimPlotting

session = AzSession(;protocal=AzClientCredentials, resource="https://slimstorage.blob.core.windows.net/")
container = AzContainer("bp-tti"; storageaccount="slimstorage", session=session)

@time block = segy_scan(container, "BPTTI_101", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])

@time shot = segy_read(container, "BPTTI_641.segy")

@time segy_write(container, "BPTTI_641-copy.segy", shot)