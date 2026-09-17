<#
.SYNOPSIS
    Sets up a Windows machine for building software with ZCode.

.DESCRIPTION
    Installs the basic toolchain, creates a Dev folder, sets your Git identity,
    and merges the MCP server entries into ZCode's user configuration.

    The script is idempotent: run it as often as you like. Anything already
    installed is skipped.

    It deliberately does NOT do these, because a human must:
      - install ZCode (it downloads the installer and starts it; you click through)
      - log in to GitHub, your model provider, or Notion
      - run the Blender MCP installer (it is interactive)

.PARAMETER DryRun
    Show what would happen. Change nothing.

.PARAMETER DevRoot
    Where projects live. Defaults to C:\Users\<you>\Dev.

.PARAMETER GitName
    Your name for Git commits. If omitted, the script asks.

.PARAMETER GitEmail
    Your email for Git commits. If omitted, the script asks.

.PARAMETER WithBlender
    Also print the Blender MCP install steps. It does not run them.

.PARAMETER SkipTools
    Do not install the toolchain. Use when you only want the config work.

.PARAMETER SkipConfig
    Do not touch ZCode's config.json. Use when you only want the toolchain.

.PARAMETER ZCodeVersion
    Which ZCode installer version to download. Check https://zcode.z.ai for
    the current version if this one returns a 404.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1 -DryRun

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1 -WithBlender
#>

[CmdletBinding()]
param(
    [string]$DevRoot,
    [string]$GitName,
    [string]$GitEmail,
    [switch]$DryRun,
    [switch]$WithBlender,
    [switch]$SkipTools,
    [switch]$SkipConfig,
    [string]$ZCodeVersion = '3.12.3'
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

$script:Problems = New-Object System.Collections.ArrayList
$script:Skipped  = New-Object System.Collections.ArrayList

function Write-Head {
    param([string]$Text)
    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor DarkGray
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor DarkGray
}

function Write-Ok    { param([string]$T) Write-Host "  [ ok ]   $T" -ForegroundColor Green }
function Write-Skip  { param([string]$T) Write-Host "  [skip]   $T" -ForegroundColor DarkGray }
function Write-Doing { param([string]$T) Write-Host "  [ .. ]   $T" -ForegroundColor White }
function Write-Note  { param([string]$T) Write-Host "  [note]   $T" -ForegroundColor Yellow }

function Write-Warn {
    param([string]$T)
    Write-Host "  [warn]   $T" -ForegroundColor Yellow
    [void]$script:Skipped.Add($T)
}

function Write-Bad {
    param([string]$T)
    Write-Host "  [FAIL]   $T" -ForegroundColor Red
    [void]$script:Problems.Add($T)
}

function Test-CommandExists {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Show-Command {
    param([string]$Command)
    if ($DryRun) {
        Write-Host "           would run: $Command" -ForegroundColor DarkYellow
    }
}

# ---------------------------------------------------------------------------
# PATH refresh
#
# Installing a tool changes PATH, but an already-running shell keeps the old
# value. Re-reading it from the registry is what makes a freshly installed
# tool usable in this same window.
# ---------------------------------------------------------------------------

function Update-SessionPath {
    # Merge, never replace. Replacing drops the entries this process was started
    # with - a bundled tool path, for instance - and then tools that are
    # genuinely installed look missing.
    $current = @($env:Path -split ';' | Where-Object { $_ })
    $fresh   = @()

    foreach ($scope in @('Machine', 'User')) {
        $value = [Environment]::GetEnvironmentVariable('Path', $scope)
        if ($value) { $fresh += @($value -split ';' | Where-Object { $_ }) }
    }

    $added = @()
    foreach ($entry in $fresh) {
        if ($current -notcontains $entry) {
            $current += $entry
            $added   += $entry
        }
    }

    if ($added.Count -gt 0) {
        $env:Path = ($current -join ';')
    }
}

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

Write-Head 'Preflight'

if ($env:OS -ne 'Windows_NT') {
    Write-Bad 'This script is for Windows. On macOS or Linux, use Track A from 01-human-setup.md instead.'
    exit 1
}

$isAdmin = $false
try {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {
    $isAdmin = $false
}

Write-Host "  Windows       : $([Environment]::OSVersion.VersionString)"
Write-Host "  PowerShell    : $($PSVersionTable.PSVersion)"
Write-Host "  Administrator : $isAdmin"
Write-Host "  Dry run       : $([bool]$DryRun)"

if (-not (Test-CommandExists 'winget')) {
    Write-Note 'winget not found. It comes from "App Installer" in the Microsoft Store.'
    Write-Note 'Open the Store, install or update App Installer, then run this script again.'
    $skipWinget = $true
} else {
    Write-Ok 'winget is available'
    $skipWinget = $false
}

Update-SessionPath

# ---------------------------------------------------------------------------
# 1. Toolchain
# ---------------------------------------------------------------------------

$tools = @(
    @{ Id = 'Git.Git';                 Cmd = 'git';    What = 'Records changes to your files. Your undo button.' }
    @{ Id = 'OpenJS.NodeJS.LTS';       Cmd = 'node';   What = 'Runs JavaScript tools, and installs npm.' }
    @{ Id = 'Python.Python.3.12';      Cmd = 'python'; What = 'Runs Python tools.' }
    @{ Id = 'astral-sh.uv';            Cmd = 'uv';     What = 'Installs and runs Python tools cleanly. Provides uvx.' }
    @{ Id = 'GitHub.cli';              Cmd = 'gh';     What = 'Talks to GitHub.' }
    @{ Id = 'BurntSushi.ripgrep.MSVC'; Cmd = 'rg';     What = 'Very fast text search. Agents use it constantly.' }
)

if ($SkipTools) {
    Write-Head '1. Toolchain - skipped (-SkipTools)'
} else {
    Write-Head '1. Installing the toolchain'

    foreach ($tool in $tools) {
        $label = "$($tool.Id)"

        if (Test-CommandExists $tool.Cmd) {
            $version = ''
            try {
                $version = (& $tool.Cmd --version 2>&1 | Select-Object -First 1)
            } catch {
                $version = ''
            }
            Write-Skip "$label already present  ($version)"
            continue
        }

        if ($skipWinget) {
            Write-Bad "$label is missing and winget is not available"
            continue
        }

        Write-Doing "installing $label"
        Write-Host "           $($tool.What)" -ForegroundColor DarkGray

        if ($DryRun) {
            Show-Command "winget install --id $($tool.Id) -e --accept-source-agreements --accept-package-agreements"
            continue
        }

        try {
            $wingetArgs = @(
                'install', '--id', $tool.Id, '-e',
                '--accept-source-agreements',
                '--accept-package-agreements',
                '--disable-interactivity'
            )
            & winget @wingetArgs | Out-Null
            $code = $LASTEXITCODE
            Update-SessionPath

            if (Test-CommandExists $tool.Cmd) {
                Write-Ok "$label installed"
            } elseif ($code -eq 0) {
                Write-Ok "$label installed (not on PATH yet in this window)"
            } else {
                Write-Bad "$label failed to install (winget exit code $code)"
            }
        } catch {
            Write-Bad "$label failed to install: $($_.Exception.Message)"
        }
    }

    Update-SessionPath

    Write-Host ''
    Write-Host '  Versions found:' -ForegroundColor DarkGray
    $verify = @(
        @{ Cmd = 'git';    Args = '--version' },
        @{ Cmd = 'node';   Args = '-v' },
        @{ Cmd = 'npm';    Args = '-v' },
        @{ Cmd = 'python'; Args = '--version' },
        @{ Cmd = 'uv';     Args = '--version' },
        @{ Cmd = 'gh';     Args = '--version' }
    )
    foreach ($v in $verify) {
        if (Test-CommandExists $v.Cmd) {
            $out = ''
            try { $out = (& $v.Cmd $v.Args 2>&1 | Select-Object -First 1) } catch { $out = 'error' }
            Write-Host ("    {0,-8} {1}" -f $v.Cmd, $out) -ForegroundColor DarkGray
        } else {
            Write-Host ("    {0,-8} {1}" -f $v.Cmd, 'NOT FOUND') -ForegroundColor Red
        }
    }
}

# ---------------------------------------------------------------------------
# 2. Dev folder
# ---------------------------------------------------------------------------

Write-Head '2. Dev folder'

if (-not $DevRoot) {
    $DevRoot = Join-Path $env:USERPROFILE 'Dev'
}
$sandbox = Join-Path $DevRoot '_sandbox'

$inOneDrive = $false
if ($env:OneDrive) {
    $od = $env:OneDrive.TrimEnd('\')
    if ($DevRoot -like "$od*") { $inOneDrive = $true }
}

Write-Host "  Target: $DevRoot"

if ($inOneDrive) {
    Write-Bad "That path is inside OneDrive ($env:OneDrive)."
    Write-Host '           OneDrive syncing node_modules and .git causes slow machines and corrupted projects.' -ForegroundColor Yellow
    Write-Host '           Use a path outside OneDrive, for example:' -ForegroundColor Yellow
    Write-Host '             -DevRoot C:\Dev' -ForegroundColor Yellow
    Write-Host '           Then run this script again.' -ForegroundColor Yellow
} else {
    Write-Ok 'Not inside OneDrive'

    if ($DryRun) {
        Show-Command "New-Item -ItemType Directory -Force -Path '$DevRoot'"
        Show-Command "New-Item -ItemType Directory -Force -Path '$sandbox'"
    } else {
        try {
            New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
            New-Item -ItemType Directory -Force -Path $sandbox | Out-Null
            Write-Ok "Created $DevRoot"
            Write-Ok "Created $sandbox (somewhere to make a mess)"
        } catch {
            Write-Bad "Could not create the Dev folder: $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------------------
# 3. Git identity
# ---------------------------------------------------------------------------

Write-Head '3. Git identity'

if (-not (Test-CommandExists 'git')) {
    Write-Bad 'git is not installed, so the Git settings were skipped'
} else {
    if (-not $GitName) {
        $existing = ''
        try { $existing = (git config --global user.name) } catch { $existing = '' }
        if ($existing) {
            $GitName = $existing
            Write-Skip "Git name already set: $existing"
        } elseif ($DryRun) {
            Write-Note 'Would ask you for your name and email'
        } else {
            Write-Host ''
            Write-Host '  Git stamps every commit with a name and an email.' -ForegroundColor Yellow
            Write-Host '  Use the email address on your GitHub account.' -ForegroundColor Yellow
            Write-Host ''
            $GitName = Read-Host '  Your name for Git commits'
        }
    }

    if (-not $GitEmail) {
        $existingMail = ''
        try { $existingMail = (git config --global user.email) } catch { $existingMail = '' }
        if ($existingMail) {
            $GitEmail = $existingMail
            Write-Skip "Git email already set: $existingMail"
        } elseif ($DryRun) {
            Write-Note 'Would ask you for your email'
        } else {
            $GitEmail = Read-Host '  Your email for Git commits'
        }
    }

    $gitSettings = @(
        @{ Key = 'init.defaultBranch'; Value = 'main';  Why = 'New repos start on main, the modern default' }
        @{ Key = 'core.longpaths';     Value = 'true';  Why = 'Windows refuses paths over 260 characters; deep project folders hit that' }
        @{ Key = 'core.autocrlf';      Value = 'true';  Why = 'Handles Windows vs Unix line endings' }
    )

    if ($GitName -and $GitEmail) {
        if ($DryRun) {
            Show-Command "git config --global user.name `"$GitName`""
            Show-Command "git config --global user.email `"$GitEmail`""
        } else {
            try {
                git config --global user.name  "$GitName"
                git config --global user.email "$GitEmail"
                Write-Ok "Set user.name  = $GitName"
                Write-Ok "Set user.email = $GitEmail"
            } catch {
                Write-Bad "Could not set the Git identity: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warn 'No Git name or email given, so those two settings were skipped'
    }

    foreach ($s in $gitSettings) {
        if ($DryRun) {
            Show-Command "git config --global $($s.Key) $($s.Value)"
        } else {
            try {
                git config --global $s.Key $s.Value
                Write-Ok "$($s.Key) = $($s.Value)   ($($s.Why))"
            } catch {
                Write-Warn "Could not set $($s.Key)"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 4. GitHub login
# ---------------------------------------------------------------------------

Write-Head '4. GitHub login - this one is yours'

if (-not (Test-CommandExists 'gh')) {
    Write-Bad 'gh is not installed. Install GitHub.cli first, then run this script again.'
} else {
    $ghOk = $false
    try {
        gh auth status 2>&1 | Out-Null
        $ghOk = ($LASTEXITCODE -eq 0)
    } catch {
        $ghOk = $false
    }

    if ($ghOk) {
        Write-Ok 'Already logged in to GitHub'
        if (-not $DryRun) {
            try { gh auth setup-git 2>&1 | Out-Null; Write-Ok 'Git configured to use the gh credentials' } catch { }
        }
    } else {
        Write-Note 'Not logged in yet. Run these two commands yourself:'
        Write-Host ''
        Write-Host '      gh auth login' -ForegroundColor White
        Write-Host '      gh auth setup-git' -ForegroundColor White
        Write-Host ''
        Write-Host '  gh auth login asks questions. Answer:' -ForegroundColor DarkGray
        Write-Host '      account          -> GitHub.com' -ForegroundColor DarkGray
        Write-Host '      protocol         -> HTTPS' -ForegroundColor DarkGray
        Write-Host '      authenticate Git -> Yes' -ForegroundColor DarkGray
        Write-Host '      how              -> Login with a web browser' -ForegroundColor DarkGray
        Write-Host ''
        Write-Host '  It shows a one-time code, then opens your browser. Paste the code,' -ForegroundColor DarkGray
        Write-Host '  sign in, and click Authorize. Nobody should ever type your password' -ForegroundColor DarkGray
        Write-Host '  into a terminal for you.' -ForegroundColor DarkGray
        [void]$script:Skipped.Add('GitHub login (human step)')
    }
}

# ---------------------------------------------------------------------------
# 5. ZCode
# ---------------------------------------------------------------------------

Write-Head '5. ZCode'

$zcodeExe = Join-Path $env:LOCALAPPDATA 'Programs\ZCode\ZCode.exe'
$zcodeCfgDir = Join-Path $env:USERPROFILE '.zcode\cli'
$zcodeCfg = Join-Path $zcodeCfgDir 'config.json'

if (Test-Path $zcodeExe) {
    Write-Ok "ZCode is installed: $zcodeExe"
} else {
    Write-Note 'ZCode is not installed.'
    $url = "https://cdn-zcode.z.ai/zcode/electron/releases/$ZCodeVersion/windows-x64/ZCode-$ZCodeVersion-win-x64.exe"
    Write-Host "  Download page : https://zcode.z.ai" -ForegroundColor DarkGray
    Write-Host "  Direct link   : $url" -ForegroundColor DarkGray
    Write-Host ''

    if ($DryRun) {
        Show-Command "download $url to Downloads, then start the installer"
    } else {
        $answer = Read-Host '  Download and start the ZCode installer now? (y/n)'
        if ($answer -match '^(y|yes|j|ja)$') {
            $target = Join-Path $env:USERPROFILE "Downloads\ZCode-$ZCodeVersion-win-x64.exe"
            try {
                Write-Doing "downloading to $target"
                $progress = $ProgressPreference
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing
                $ProgressPreference = $progress
                Write-Ok "Downloaded $target"
                Write-Note 'Starting the installer. Click through the wizard, then reopen ZCode.'
                Start-Process -FilePath $target
                Write-Note 'Come back to this script after ZCode has been installed and opened once.'
            } catch {
                Write-Bad "Download failed: $($_.Exception.Message)"
                Write-Note "If this is a 404, get the current link from https://zcode.z.ai and install by hand."
            }
        } else {
            Write-Warn 'ZCode install skipped. Install it by hand from https://zcode.z.ai.'
        }
        [void]$script:Skipped.Add('ZCode install (human step)')
    }
}

# ---------------------------------------------------------------------------
# 6. MCP servers
# ---------------------------------------------------------------------------

if ($SkipConfig) {
    Write-Head '6. MCP servers - skipped (-SkipConfig)'
} else {
    Write-Head '6. MCP servers'

    if (-not (Test-Path $zcodeCfgDir)) {
        Write-Warn "ZCode's config folder does not exist yet: $zcodeCfgDir"
        Write-Note 'Open ZCode, change any setting, close it, then run this script again.'
    } else {
        # --- find npx ------------------------------------------------------
        $npxPath = $null
        $npxCmd = Get-Command 'npx.cmd' -ErrorAction SilentlyContinue
        if ($npxCmd) {
            $npxPath = $npxCmd.Source
        } else {
            $candidate = Join-Path $env:ProgramFiles 'nodejs\npx.cmd'
            if (Test-Path $candidate) { $npxPath = $candidate }
        }

        if ($npxPath) {
            # ZCode needs forward slashes in paths.
            $npxJson = $npxPath -replace '\\', '/'
            Write-Ok "npx found: $npxJson"
        } else {
            Write-Bad 'Could not find npx.cmd. Install Node.js first, then run this script again.'
            $npxJson = 'C:/Program Files/nodejs/npx.cmd'
            Write-Note "Falling back to $npxJson - verify that path exists before relying on it."
        }

        # --- is a Blender server already registered? ------------------------
        # Checked before nagging, so an existing working setup is left alone.
        $existingBlender = @()
        if (Test-Path $zcodeCfg) {
            try {
                $currentCfg = (Get-Content $zcodeCfg -Raw) | ConvertFrom-Json
                if ($currentCfg.mcp -and $currentCfg.mcp.servers) {
                    $existingBlender = @($currentCfg.mcp.servers.PSObject.Properties |
                                        Where-Object { $_.Name -match 'blender' } |
                                        Select-Object -ExpandProperty Name)
                }
            } catch {
                # An unreadable config is reported further down, where it is written.
            }
        }

        # --- desired servers ----------------------------------------------
        $desired = [ordered]@{}
        $desired['notion'] = [PSCustomObject][ordered]@{
            type      = 'stdio'
            command   = $npxJson
            args      = @('-y', 'mcp-remote', 'https://mcp.notion.com/mcp', '--transport', 'http-only')
            timeoutMs = 60000
        }

        if ($WithBlender) {
            # Find whatever the Blender MCP installer left behind.
            $blenderExe = $null
            $blenderRoot = Join-Path $env:LOCALAPPDATA 'BlenderMCP'
            if (Test-Path $blenderRoot) {
                $found = Get-ChildItem $blenderRoot -Recurse -Filter 'blender-mcp.exe' -ErrorAction SilentlyContinue |
                         Select-Object -First 1
                if ($found) { $blenderExe = $found.FullName }
            }

            if ($existingBlender.Count -gt 0) {
                Write-Skip "A Blender server is already registered: $($existingBlender -join ', ')"
                if ($blenderExe) {
                    Write-Host "           Installer copy found at: $blenderExe" -ForegroundColor DarkGray
                    Write-Host "           Left as it is. Remove the existing entry first if you want this one." -ForegroundColor DarkGray
                }
            } elseif ($blenderExe) {
                $desired['blender-fork'] = [PSCustomObject][ordered]@{
                    type    = 'stdio'
                    command = ($blenderExe -replace '\\', '/')
                    args    = @()
                    env     = [PSCustomObject][ordered]@{ BLENDER_MCP_DISABLE_TELEMETRY = '1' }
                }
                Write-Ok "Found the Blender MCP server: $blenderExe"
            } else {
                Write-Note 'The Blender MCP is not installed yet. Run this by hand first:'
                Write-Host ''
                Write-Host '      Set-ExecutionPolicy Bypass -Scope Process -Force' -ForegroundColor White
                Write-Host '      irm https://raw.githubusercontent.com/newo-ether/blender-mcp/main/bootstrap.ps1 | iex' -ForegroundColor White
                Write-Host ''
                Write-Host '  It is interactive: it shows a checklist and asks which Blender' -ForegroundColor DarkGray
                Write-Host '  version and which MCP clients to register. Read its prompts.' -ForegroundColor DarkGray
                Write-Host '  Then run this script again with -WithBlender.' -ForegroundColor DarkGray
                [void]$script:Skipped.Add('Blender MCP (run the installer by hand, then re-run with -WithBlender)')
            }
        } else {
            Write-Note 'Blender MCP not requested. Add -WithBlender when you want it.'
        }

        # --- read, back up, merge, write -----------------------------------
        if (Test-Path $zcodeCfg) {
            $raw = Get-Content $zcodeCfg -Raw

            $valid = $true
            try {
                $config = $raw | ConvertFrom-Json
            } catch {
                $valid = $false
                Write-Bad "config.json is not valid JSON, so it was left untouched: $($_.Exception.Message)"
                Write-Note 'Fix it by hand, or restore a backup, then run this script again.'
            }

            if ($valid) {
                if ($DryRun) {
                    Write-Note "Would back up $zcodeCfg first"
                    foreach ($name in $desired.Keys) {
                        Show-Command "merge MCP server '$name' into mcp.servers"
                    }
                } else {
                    $stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
                    $backup = "$zcodeCfg.bak-$stamp"
                    Copy-Item $zcodeCfg $backup
                    Write-Ok "Backed up to $backup"

                    # Merge into mcp.servers, creating the containers if missing.
                    if (-not $config.PSObject.Properties['mcp']) {
                        $config | Add-Member -NotePropertyName 'mcp' -NotePropertyValue ([PSCustomObject]@{})
                    }
                    if (-not $config.mcp.PSObject.Properties['servers']) {
                        $config.mcp | Add-Member -NotePropertyName 'servers' -NotePropertyValue ([PSCustomObject]@{})
                    }

                    foreach ($name in $desired.Keys) {
                        if ($config.mcp.servers.PSObject.Properties[$name]) {
                            Write-Skip "MCP server '$name' is already configured - left as it is"
                        } else {
                            $config.mcp.servers | Add-Member -NotePropertyName $name -NotePropertyValue $desired[$name]
                            Write-Ok "Added MCP server '$name'"
                        }
                    }

                    # Write UTF-8 without a BOM. A BOM makes some JSON parsers fail.
                    $json = $config | ConvertTo-Json -Depth 100
                    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                    [System.IO.File]::WriteAllText($zcodeCfg, $json, $utf8NoBom)

                    # Prove the file we just wrote parses.
                    try {
                        Get-Content $zcodeCfg -Raw | ConvertFrom-Json | Out-Null
                        Write-Ok 'config.json is still valid JSON'
                    } catch {
                        Write-Bad 'The written config.json does not parse. Restoring the backup.'
                        Copy-Item $backup $zcodeCfg -Force
                        Write-Note "Restored from $backup"
                    }

                    Write-Note 'Close ZCode and open it again, so it picks up the new servers.'
                }
            }
        } else {
            Write-Warn "No config file at $zcodeCfg"
            Write-Note 'Open ZCode once, close it, then run this script again.'
        }
    }
}

# ---------------------------------------------------------------------------
# 7. Skills
# ---------------------------------------------------------------------------

Write-Head '7. Skills'

$skillsRoot  = Join-Path $env:USERPROFILE '.agents\skills'
$repoSkills = Join-Path (Split-Path -Parent $PSScriptRoot) 'skills'

if (-not (Test-Path $skillsRoot)) {
    if ($DryRun) {
        Show-Command "New-Item -ItemType Directory -Force -Path '$skillsRoot'"
    } else {
        New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null
        Write-Ok "Created $skillsRoot"
    }
} else {
    Write-Ok "Skills folder exists: $skillsRoot"
}

if (Test-Path $repoSkills) {
    $skillDirs = @(Get-ChildItem $repoSkills -Directory -ErrorAction SilentlyContinue)
    if ($skillDirs.Count -eq 0) {
        Write-Note 'No skills in this repo to install.'
    }
    foreach ($dir in $skillDirs) {
        $target = Join-Path $skillsRoot $dir.Name

        if (-not (Test-Path (Join-Path $dir.FullName 'SKILL.md'))) {
            Write-Warn "Skipping '$($dir.Name)' - it has no SKILL.md directly inside it"
            continue
        }

        if (Test-Path $target) {
            Write-Skip "'$($dir.Name)' is already installed - left as it is"
            Write-Host "           (delete $target and re-run to update it)" -ForegroundColor DarkGray
            continue
        }

        if ($DryRun) {
            Show-Command "copy '$($dir.FullName)' -> '$target'"
        } else {
            Copy-Item -Recurse -Force $dir.FullName $target
            Write-Ok "Installed skill '$($dir.Name)'"
        }
    }
} else {
    Write-Note "No skills folder in this repo, so nothing to install."
}

Write-Note 'Restart ZCode, then check Settings -> Skills.'

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Head 'Summary'

if ($script:Problems.Count -eq 0) {
    Write-Host '  No failures.' -ForegroundColor Green
} else {
    Write-Host "  $($script:Problems.Count) problem(s) need attention:" -ForegroundColor Red
    foreach ($p in $script:Problems) { Write-Host "    - $p" -ForegroundColor Red }
}

if ($script:Skipped.Count -gt 0) {
    Write-Host ''
    Write-Host '  Skipped, or needs you to act:' -ForegroundColor Yellow
    foreach ($s in $script:Skipped) { Write-Host "    - $s" -ForegroundColor Yellow }
}

Write-Host ''
Write-Host '  Still needs a human:' -ForegroundColor Cyan
Write-Host '    1. Install ZCode if it is not installed, and connect a model.' -ForegroundColor Gray
Write-Host '    2. Log in to GitHub:  gh auth login   then   gh auth setup-git' -ForegroundColor Gray
Write-Host '    3. Close ZCode and reopen it, so new MCP servers and skills load.' -ForegroundColor Gray
Write-Host '    4. Approve the Notion sign-in in the browser on first use.' -ForegroundColor Gray
Write-Host '    5. Check everything:  .\scripts\verify-setup.ps1' -ForegroundColor Gray
Write-Host ''

if ($DryRun) {
    Write-Host '  This was a dry run. Nothing was changed.' -ForegroundColor DarkYellow
    Write-Host ''
    exit 0
}

if ($script:Problems.Count -gt 0) { exit 1 }
exit 0
