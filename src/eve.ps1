#!/usr/bin/env pwsh

function Show-Help {
    Write-Host "`nUsage:`n"
    Write-Host "Commands:"
    Get-Content .\eve.ps1 | Where-Object { $_ -match '^# Command:' } | ForEach-Object {
        $command = ($_ -split 'Command: ',  2)[1]
        $description = (Get-Content .\eve.ps1 | Where-Object { $_ -match '^# Description:' })[$_.IndexOf('Command: ')].Substring('Description: '.Length)
        Write-Host ("  {0,-20} {1}" -f $command, $description)
    }
    Write-Host "`nOptions:`n  -h, --help     Show this help message"
}

function Handle-GitCheckFolders {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Host "Path does not exist or is not a directory: $Path"
        return
    }

    Get-ChildItem -Path $Path -Recurse -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".git") } | ForEach-Object {
        Set-Location $_.FullName
        $gitStatusOutput = git status --porcelain
        if ($gitStatusOutput) {
            Write-Host "Uncommitted changes detected at: $($_.FullName)"
        }
    }
}

function Handle-Reinstall {
    $formulas = @("neovim", "tmux", "btop", "gh")
    $casks = @("raycast", "wezterm")
    $totalSteps = $formulas.Count + $casks.Count
    $step =   0
    $startTime = Get-Date

    foreach ($formula in $formulas) {
        $step++
        $elapsedTime = (Get-Date) - $startTime
        $eta = [int](($elapsedTime.TotalSeconds * $totalSteps) / $step - $elapsedTime.TotalSeconds)
        $percentage = [int](($step *   100) / $totalSteps)
        $progressBar = " " * ($totalSteps - $step) + "#" * $step
        Write-Progress -Activity "Reinstalling" -PercentComplete $percentage -CurrentOperation "Step $step/$totalSteps" -Status "ETA: $($eta /   60) minutes $($eta %   60) seconds"
        if (-not (scoop list   2>$null | Select-String -Pattern "^${formula}$")) {
            scoop install $formula
        }
    }

    foreach ($cask in $casks) {
        $step++
        $elapsedTime = (Get-Date) - $startTime
        $eta = [int](($elapsedTime.TotalSeconds * $totalSteps) / $step - $elapsedTime.TotalSeconds)
        $percentage = [int](($step *   100) / $totalSteps)
        $progressBar = " " * ($totalSteps - $step) + "#" * $step
        Write-Progress -Activity "Reinstalling" -PercentComplete $percentage -CurrentOperation "Step $step/$totalSteps" -Status "ETA: $($eta /   60) minutes $($eta %   60) seconds"
        if (-not (scoop list   2>$null | Select-String -Pattern "^${cask}$")) {
            scoop install $cask
        }
    }

    Clear-Host
    Write-Host "Reinstallation complete."
}

if ($args.Count -eq  0) {
    Show-Help
    exit  1
}

switch ($args[0]) {
    "reinstall" {
        Handle-Reinstall
    }
    "git_checkFolders" {
        Handle-GitCheckFolders -Path $args[1]
    }
    default {
        Write-Host "Unknown command: $($args[0])"
        Show-Help
        exit  1
    }
}