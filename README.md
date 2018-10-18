# CloudSeisIO

SeisIO overlay for writing to Cloud buckets

## INSTALLATION

From julia prompt run the following if you will not need developer's write access or if you do not have GitHub account:

First add SeisIO:

```
Pkg.add(PackageSpec(url="https://github.com/slimgroup/SeisIO.jl.git",rev="v07-devel"))
```

then if you just want to use CloudSeisIO

```
Pkg.add(PackageSpec(url="https://github.com/slimgroup/CloudSeisIO.jl.git",rev="v07-devel"))
```

or with GitHub account (and SSH keys registered) for full developer access:

```
Pkg.develop(PackageSpec(url="git@github.com:slimgroup/CloudSeisIO.jl.git"))
```

Configure AWS credentials if not done already or if needed. (On EC2 instances/containers use appropriate S3 role for EC2 if configured, otherwise run this configuration.) Use your AWS access keys and configure with command :

```
aws configure
```

