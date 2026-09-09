param([Parameter(Mandatory=$true)][string]$Godot, [switch]$SkipVisual)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$artifactRoot = Join-Path $projectRoot 'tests/artifacts'
New-Item -ItemType Directory -Force $artifactRoot | Out-Null
$engine = (Resolve-Path -LiteralPath $Godot).Path

function Start-Suite([string]$Name, [bool]$Visual = $false) {
    $arguments = '--path "' + $projectRoot + '" res://tests/test_runner.tscn -- --suite=' + $Name
    if (-not $Visual) { $arguments = '--headless ' + $arguments }
    $started = Start-Process -FilePath $engine -ArgumentList $arguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $artifactRoot ($Name+'.log')) -RedirectStandardError (Join-Path $artifactRoot ($Name+'-errors.log'))
    $null = $started.Handle
    return $started
}

function Finish-Suite($Process, [string]$Name, [int]$Seconds = 110) {
    if (-not $Process.WaitForExit($Seconds*1000)) {
        $Process.Kill()
        throw "$Name timed out"
    }
    $errorText = Get-Content -LiteralPath (Join-Path $artifactRoot ($Name+'-errors.log')) -Raw
    $outputText = Get-Content -LiteralPath (Join-Path $artifactRoot ($Name+'.log')) -Raw
    if (($null -ne $Process.ExitCode -and $Process.ExitCode -ne 0) -or $errorText -match 'ERROR|SCRIPT ERROR' -or $outputText -match 'FAIL:' -or $outputText -notmatch 'TEST SUMMARY.*0 failures|Quit button invoked') {
        throw "$Name failed. Inspect tests/artifacts/$Name-errors.log and $Name.log"
    }
    Write-Output ($outputText -split "`n" | Where-Object { $_ -match 'TEST SUMMARY|Quit button' })
}

Push-Location $projectRoot
try {
    $importOutput = & $engine --headless --editor --path $projectRoot --import --quit 2>&1
    $importOutput | Set-Content -LiteralPath (Join-Path $artifactRoot 'import.log')
    if ($LASTEXITCODE -ne 0 -or ($importOutput -join "`n") -match 'ERROR|SCRIPT ERROR') { throw 'Godot import failed' }
    Finish-Suite (Start-Suite 'rules') 'rules'
    Finish-Suite (Start-Suite 'quit') 'quit'
    if (-not $SkipVisual) { Finish-Suite (Start-Suite 'ui' $true) 'ui' }

    $hostProcess = Start-Suite 'host'
    Start-Sleep -Milliseconds 300
    $clientProcess = Start-Suite 'client'
    Finish-Suite $hostProcess 'host'
    Finish-Suite $clientProcess 'client'
    $hostStates = @(Get-Content (Join-Path $artifactRoot 'host.log') | Where-Object { $_.StartsWith('RESULT ') } | ForEach-Object {
        $state = $_.Substring(7) | ConvertFrom-Json
        $state.PSObject.Properties.Remove('orders')
        $state.PSObject.Properties.Remove('questions')
        $state | ConvertTo-Json -Compress -Depth 30
    })
    $clientStates = @(Get-Content (Join-Path $artifactRoot 'client.log') | Where-Object { $_.StartsWith('RESULT ') } | ForEach-Object {
        $state = $_.Substring(7) | ConvertFrom-Json
        $state.PSObject.Properties.Remove('orders')
        $state.PSObject.Properties.Remove('questions')
        $state | ConvertTo-Json -Compress -Depth 30
    })
    if ($hostStates.Count -ne 2 -or ($hostStates -join "`n") -cne ($clientStates -join "`n")) { throw 'Peer final snapshots differ' }
    Write-Output 'PASS: Public final states and both wallets match exactly for both matches; private orders/questions excluded'

    $faultHost = Start-Suite 'fault-host'
    Start-Sleep -Milliseconds 300
    Finish-Suite (Start-Suite 'fault-mismatch') 'fault-mismatch'
    $faultClient = Start-Suite 'fault-client'
    $deadline = (Get-Date).AddSeconds(8)
    do {
        Start-Sleep -Milliseconds 50
        $clientLog = Get-Content (Join-Path $artifactRoot 'fault-client.log') -Raw -ErrorAction SilentlyContinue
    } until ($clientLog -match 'Fault client handshake' -or (Get-Date) -gt $deadline)
    Finish-Suite (Start-Suite 'fault-full') 'fault-full'
    Finish-Suite $faultHost 'fault-host'
    Finish-Suite $faultClient 'fault-client'

    $exitHost = Start-Suite 'fault-exit-host'
    Start-Sleep -Milliseconds 300
    $exitClient = Start-Suite 'fault-exit-client'
    Finish-Suite $exitHost 'fault-exit-host'
    Finish-Suite $exitClient 'fault-exit-client'
    Finish-Suite (Start-Suite 'fault-timeout') 'fault-timeout'
    Write-Output 'All automated checks passed. Physical LAN and human visual acceptance are separate gates.'
} finally {
    Pop-Location
}
