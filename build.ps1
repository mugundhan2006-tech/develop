$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$classes = Join-Path $projectRoot 'build/classes'
$jarPath = Join-Path $projectRoot 'build/calculator.jar'

if (-not (Get-Command javac -ErrorAction SilentlyContinue) -or -not (Get-Command jar -ErrorAction SilentlyContinue)) {
    throw 'A JDK 17 or newer is required. Ensure java, javac, and jar are on PATH.'
}

$javaVersion = (& java -version 2>&1 | Out-String)
if ($javaVersion -notmatch 'version "(\d+)') {
    throw 'Unable to determine the installed Java version.'
}
$majorVersion = [int]$Matches[1]
if ($majorVersion -lt 17) {
    throw "Java 17 or newer is required; detected Java $majorVersion."
}

if (Test-Path $classes) {
    Remove-Item $classes -Recurse -Force
}
New-Item -ItemType Directory -Path $classes -Force | Out-Null
$sources = Get-ChildItem (Join-Path $projectRoot 'src/main/java') -Filter '*.java' -Recurse | ForEach-Object { $_.FullName }
if ($sources.Count -eq 0) {
    throw 'No Java source files were found.'
}
& javac --release 17 -encoding UTF-8 -d $classes $sources
if ($LASTEXITCODE -ne 0) {
    throw 'Java compilation failed.'
}
& jar --create --file $jarPath --main-class com.example.calculator.CalculatorApp -C $classes .
if ($LASTEXITCODE -ne 0) {
    throw 'JAR creation failed.'
}
Write-Host "Created $jarPath"