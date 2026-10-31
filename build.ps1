
$ErrorActionPreference = "Stop"

$pomPath = Join-Path $PSScriptRoot "pom.xml"
$maven = "C:\Users\HP\tools\apache-maven-3.9.11\bin\mvn.cmd"

# Read current POM
[xml]$xml = Get-Content -Raw $pomPath

$currentVersion = $xml.project.version
$parts = $currentVersion.Split(".")

# Increase minor version
$major = [int]$parts[0]
$minor = [int]$parts[1] + 1
$patch = [int]$parts[2]

$newVersion = "$major.$minor.$patch"

Write-Host "Current Version: $currentVersion"
Write-Host "New Version: $newVersion"

# Temporarily update POM
$xml.project.version = $newVersion
$xml.Save($pomPath)

# Build project
& $maven -f $pomPath clean package

if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS!"
    Write-Host "New JAR: target\student-microservice-$newVersion.jar"
} else {
    # Restore previous version if build fails
    $xml.project.version = $currentVersion
    $xml.Save($pomPath)
    Write-Host "BUILD FAILED! Previous version restored."
    exit 1
}
