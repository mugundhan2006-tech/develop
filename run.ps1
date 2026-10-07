$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'build.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'Build failed; application was not started.'
}
& java -jar (Join-Path $projectRoot 'build/calculator.jar')
if ($LASTEXITCODE -ne 0) {
    throw 'Calculator exited with an error.'
}