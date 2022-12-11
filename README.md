# CloudSegyIO

SegyIO overlay for reading from, writing to, and scanning Cloud storage. Functionnalities rely on implementation of CLouds API and may not always be optimal in some case. However, the full application range of  SegyIO is extended here to Cloud storage enabling at scale usage of SEGY in the CLoud.

## INSTALLATION

First switch to package manager prompt (using ']') and add CloudSegyIO registry:

```
	add CloudSegyIO
```
## Configuration

Because cloud platform require advance credential managment, user ware require to setup credentials and authentification. We breifly describe the steps below.

### AWS

Configure AWS credentials if not done already or if needed. (On EC2 instances/containers use appropriate S3 role for EC2 if configured, otherwise run this configuration.) Use your AWS access keys and configure with the aws CLI command :

```
aws configure
```

### Azure

Azure setup is a little bit more complicated. We rely on [AzStorage.jl](https://github.com/ChevronETC/AzStorage.jl) for read/write to azure Blob which uses [AzSessions.jl](https://github.com/ChevronETC/AzSessions.jl) as a credential manager. Follow setup instructions at for these two packages to setup your credentials.

## Example

We provide two simple usage examples for `S3` and Azure `Blob`. These examples are setup for our own storage accoutn and content and will need to be updated with your own path/filename but describe the interface fully.
