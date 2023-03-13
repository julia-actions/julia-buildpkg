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
