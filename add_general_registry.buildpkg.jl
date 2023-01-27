using Pkg

function tarball_general_registry_location()
    reg_dir = joinpath(DEPOT_PATH[1], "registries")
    general_registry_tarball = joinpath(reg_dir, "General.tar.gz")
    registry_toml_file = joinpath(reg_dir, "General.toml")
    return general_registry_tarball, registry_toml_file
end

function cloned_general_registry_location()
    general_registry_dir = joinpath(DEPOT_PATH[1], "registries", "General")
    registry_toml_file = joinpath(general_registry_dir, "Registry.toml")
    return general_registry_dir, registry_toml_file
end

function general_registry_exists()
    general_registry_tarball, registry_toml_file = tarball_general_registry_location()
    if isfile(general_registry_tarball) && isfile(registry_toml_file)
        return true
    end

    general_registry_dir, registry_toml_file = cloned_general_registry_location()
    if isdir(general_registry_dir) && isfile(registry_toml_file)
        return true
    end

    return false
end

function add_general_registry()
    @info("Attempting to install the General registry")

    general_registry_tarball, registry_toml_file = tarball_general_registry_location()
    rm(general_registry_tarball; force = true, recursive = true)
    rm(registry_toml_file; force = true, recursive = true)

    general_registry_dir, registry_toml_file = cloned_general_registry_location()
    rm(general_registry_dir; force = true, recursive = true)

    registry_flavor = get(ENV, "JULIA_PKG_SERVER_REGISTRY_PREFERENCE", "eager")
    withenv("JULIA_PKG_SERVER_REGISTRY_PREFERENCE" => registry_flavor) do
        Pkg.Registry.add("General")
    end

    general_registry_exists() || throw(ErrorException("The Registry was not intalled properly"))
    return nothing
end

function main(; n = 10, max_delay = 120)
    VERSION >= v"1.5-" || return

    if general_registry_exists()
        @info("The General registry already exists locally")
        return
    end

    delays = ExponentialBackOff(; n = n, max_delay = max_delay)
    try
        retry(add_general_registry; delays = delays)()
        @info("Successfully added the General registry")
    catch ex
        msg = "I was unable to add the General registry. However, the build will continue."
        @error(msg, exception=(ex,catch_backtrace()))
    end

    return
end

main()
