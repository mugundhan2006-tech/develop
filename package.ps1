param(
    [switch]$SourceOnly
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$buildRoot = Join-Path $projectRoot 'build'
$stage = Join-Path $buildRoot 'package-stage'
$handoff = Join-Path $stage 'calculator-week5'
$dist = Join-Path $projectRoot 'dist'
$archive = Join-Path $dist 'calculator-week5.zip'

if (-not $SourceOnly) {
    & (Join-Path $PSScriptRoot 'build.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Build failed; package was not created.'
    }
}

& python (Join-Path $projectRoot 'docs/generate_developer_guide.py')
if ($LASTEXITCODE -ne 0) {
    throw 'Developer guide generation failed; package was not created.'
}

if (Test-Path $stage) {
    Remove-Item $stage -Recurse -Force
}
New-Item -ItemType Directory -Path $handoff -Force | Out-Null
New-Item -ItemType Directory -Path $dist -Force | Out-Null
Copy-Item (Join-Path $projectRoot 'README.md') $handoff
Copy-Item (Join-Path $projectRoot 'src') $handoff -Recurse
Copy-Item (Join-Path $projectRoot 'scripts') $handoff -Recurse
Copy-Item (Join-Path $projectRoot 'docs') $handoff -Recurse
if (-not $SourceOnly) {
    New-Item -ItemType Directory -Path (Join-Path $handoff 'build') -Force | Out-Null
    Copy-Item (Join-Path $buildRoot 'calculator.jar') (Join-Path $handoff 'build')
}

if (Test-Path $archive) {
    Remove-Item $archive -Force
}
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -CompressionLevel Optimal
Write-Host "Created $archive"