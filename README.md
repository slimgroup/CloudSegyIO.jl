# CloudSegyIO

SegyIO overlay for writing to Cloud buckets

## INSTALLATION

From julia prompt run the following if you will not need developer's write access or if you do not have GitHub account:

First add SegyIO:

```
Pkg.add(PackageSpec(url="https://github.com/slimgroup/SegyIO.jl.git",rev="master"))
```

then if you just want to use CloudSegyIO

```
Pkg.add(PackageSpec(url="https://github.com/slimgroup/CloudSegyIO.jl.git",rev="master"))
```

or with GitHub account (and SSH keys registered) for full developer access:

```
Pkg.develop(PackageSpec(url="git@github.com:slimgroup/CloudSegyIO.jl.git"))
```

Configure AWS credentials if not done already or if needed. (On EC2 instances/containers use appropriate S3 role for EC2 if configured, otherwise run this configuration.) Use your AWS access keys and configure with command :

```
aws configure
```

