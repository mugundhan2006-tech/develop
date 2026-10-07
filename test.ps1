$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$classes = Join-Path $projectRoot 'build/test-classes'

if (-not (Get-Command javac -ErrorAction SilentlyContinue) -or -not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw 'A JDK 17 or newer is required. Ensure java and javac are on PATH.'
}
if (Test-Path $classes) {
    Remove-Item $classes -Recurse -Force
}
New-Item -ItemType Directory -Path $classes -Force | Out-Null
$sources = @(
    Get-ChildItem (Join-Path $projectRoot 'src/main/java') -Filter '*.java' -Recurse
    Get-ChildItem (Join-Path $projectRoot 'src/test/java') -Filter '*.java' -Recurse
) | ForEach-Object { $_.FullName }
& javac --release 17 -encoding UTF-8 -d $classes $sources
if ($LASTEXITCODE -ne 0) {
    throw 'Test compilation failed.'
}
& java -ea -cp $classes com.example.calculator.CalculatorServiceTest
if ($LASTEXITCODE -ne 0) {
    throw 'Calculator tests failed.'
}