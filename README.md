# CloudSegyIO

SegyIO overlay for writing to Cloud buckets

## INSTALLATION

### Using SLIM Registry (preferred method) ###

First switch to package manager prompt (using ']') and add SLIM registry:

```
	registry add https://github.com/slimgroup/SLIMregistryJL.git
```

Then still from package manager prompt add CloudSegyIO:

```
	add CloudSegyIO
```

### Adding without SLIM registry ###

After switching to package manager prompt (using ']') type:

First add SegyIO:

```
    add https://github.com/slimgroup/SegyIO.jl.git"
```

then add CloudSegyIO

```
    add https://github.com/slimgroup/CloudSegyIO.jl.git
```

Configure AWS credentials if not done already or if needed. (On EC2 instances/containers use appropriate S3 role for EC2 if configured, otherwise run this configuration.) Use your AWS access keys and configure with command :

```
aws configure
```

