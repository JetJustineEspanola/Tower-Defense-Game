param([Parameter(Mandatory=$true)][string]$Godot)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$destination = Join-Path $projectRoot 'builds/windows'
New-Item -ItemType Directory -Force $destination | Out-Null
& $Godot --headless --path $projectRoot --export-debug 'Windows Desktop' (Join-Path $destination 'CodeBorn.exe')
if ($LASTEXITCODE -ne 0) { throw 'Windows export failed. Install matching Godot 4.6.stable export templates.' }
Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $destination 'CodeBorn.exe'),(Join-Path $destination 'CodeBorn.pck')
