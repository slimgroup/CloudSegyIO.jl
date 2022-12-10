using SegyIO, AzStorage, CloudSegyIO.AzureBlobSegyIO, AzSessions, SlimPlotting

session = AzSession(;protocal=AzClientCredentials, resource="https://slimstorage.blob.core.windows.net/")
container = AzContainer("mathias-exp"; storageaccount="slimstorage", session=session)

shot = segy_read(container, "BPTTI_641.segy")

block = segy_scan(container, "BPTTI", ["GroupX","GroupY","RecGroupElevation","SourceSurfaceElevation","dt"])