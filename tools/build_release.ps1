# Builds the Windows release folder: build\windows\Codeborn.exe plus the offline
# PDF/DOCX importer it launches from tools\astral_import\bin beside the exe.
#
# Usage (from the project folder):
#   powershell -ExecutionPolicy Bypass -File tools\build_release.ps1 -Godot "C:\path\to\Godot_v4.6-stable_win64_console.exe"
# or set the GODOT environment variable once and run without -Godot.
param(
	[string]$Godot = $env:GODOT,
	[switch]$SkipTests
)
$ErrorActionPreference = "Stop"
$project = Split-Path -Parent $PSScriptRoot
$output = Join-Path $project "build\windows"

if ([string]::IsNullOrWhiteSpace($Godot) -or -not (Test-Path $Godot)) {
	throw "Pass -Godot with the path to Godot 4.6 (the _console.exe is best), or set the GODOT environment variable."
}

if (-not $SkipTests) {
	foreach ($test in @(
		"res://tests/questions/formatted_questions_test.gd",
		"res://tests/network/lan_session_test.gd",
		"res://tests/ui/menu_layout_test.gd",
		"res://tests/audio/arjie_voice_test.gd")) {
		Write-Host "Running $test"
		& $Godot --headless --path $project -s $test
		if ($LASTEXITCODE -ne 0) { throw "Test failed: $test" }
	}
}

# Start from an empty folder so stale files from older builds never ship.
if (Test-Path $output) { Remove-Item -Recurse -Force $output }
New-Item -ItemType Directory -Force $output | Out-Null

Write-Host "Exporting Windows Desktop (release)..."
& $Godot --headless --path $project --export-release "Windows Desktop" (Join-Path $output "Codeborn.exe")
if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $output "Codeborn.exe"))) { throw "Godot export failed." }

$importer = Join-Path $project "tools\astral_import"
$target = Join-Path $output "tools\astral_import"
New-Item -ItemType Directory -Force (Join-Path $target "bin") | Out-Null
Copy-Item (Join-Path $importer "bin\astral_extract.exe") (Join-Path $target "bin\astral_extract.exe")
Copy-Item -Recurse (Join-Path $importer "licenses") (Join-Path $target "licenses")

Write-Host ""
Write-Host "Release ready: $output"
Write-Host "Ship the whole folder (zip it). Codeborn.exe needs tools\astral_import beside it for PDF/DOCX import."
