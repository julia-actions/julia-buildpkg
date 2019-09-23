import * as core from '@actions/core'
import * as exec from '@actions/exec'

async function run() {
    try {
        // Run Pkg.build
        await exec.exec('julia', ['--color=yes', '--project', '-e', 'using Pkg; if VERSION >= v\"1.1.0-rc1\"; Pkg.build(verbose=true); else Pkg.build(); end'])
    } catch (error) {
        core.setFailed(error.message)
    }
}

run()
