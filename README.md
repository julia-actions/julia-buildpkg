# julia-buildpkg Action

This action runs the build step in a Julia package.

## Usage

Julia needs to be installed before this action can run. This can easily be achieved with the [setup-julia](https://github.com/marketplace/actions/setup-julia-environment) action.

And example workflow that uses this action might look like this:

```
name: Run tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        julia-version: [stable, lts]
        julia-arch: [x64, x86]
        os: [ubuntu-latest, windows-latest, macOS-latest]
        exclude:
          - os: macOS-latest
            julia-arch: x86

    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@v1
        with:
          version: ${{ matrix.julia-version }}
      - uses: julia-actions/julia-buildpkg@v1
      - uses: julia-actions/julia-runtest@v1
```


### Registry flavor preference

This actions defines (and exports for subsequent steps of the workflow) the
environmental variable `JULIA_PKG_SERVER_REGISTRY_PREFERENCE=eager` unless it
is already set. If you want another registry flavor (i.e. `conservative`) this
should be defined in the `env:` section of the relevant workflow or step. See
[Registry flavors](https://pkgdocs.julialang.org/dev/registries/#Registry-flavors)
for more information.

### Adding Local Registries

Personal registries, e.g. created with [LocalRegistry.jl](https://github.com/GunnarFarneback/LocalRegistry.jl), can be added to the CI using the `localregistry` input option. If the personal registry as well as packages needed in the current project are public, no additional setup is required if the registry url is specified in https-format.

If the registry contains private packages, or is itself private, the ssh protocol should to be used. The user has to provide the corresponding private SSH-keys to the `ssh-agent` to access packages and registry. This can be conveniently done using the [webfactory/ssh-agent](https://github.com/webfactory/ssh-agent) action. A snippet illustrating the usage of (private) personal registries is shown below

```yaml
...   
      # Adding private SSH keys (only necessary for accessing private packages and/or 
      # when providing Registry-link in ssh format)
      - uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: |
            ${{ secrets.PRIVATE_DEPLOY_KEY }}
            ${{ secrets.PRIVATE_DEPLOY_KEY2 }}
      - uses: julia-actions/julia-buildpkg@main # Update @main once new taged version available
        with:
          localregistry: |
            https://github.com/username/PersonalRegistry.git
            git@github.com:username2/PersonalRegistry2.git
          git_cli: false # = JULIA_PKG_USE_CLI_GIT. Options: true | false (default)
...
```

For Julia 1.7 and above, the `git_cli` option can be used to set the `JULIA_PKG_USE_CLI_GIT` [environment flag](https://docs.julialang.org/en/v1/manual/environment-variables/), for additional control of the SSH configuration used by `Pkg` to add/dev packages.