<#
.SYNOPSIS
    Checks whether this machine is set up correctly for ZCode.

.DESCRIPTION
    Runs a series of read-only checks and prints a report. Changes nothing.

    Three results are possible:

      PASS   working
      WARN   optional, or not set up yet. Safe to ignore on a first pass.
      FAIL   a required step did not land. Fix it before you start building.

    Exit code is 0 when there is no FAIL, and 1 when there is.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\verify-setup.ps1
#>

[CmdletBinding()]
param()

$script:Pass = 0
$script:Warn = 0
$script:Fail = 0
$script:Failures = New-Object System.Collections.ArrayList

function Add-Pass {
    param([string]$Name, [string]$Detail = '')
    $script:Pass++
    $suffix = ''
    if ($Detail) { $suffix = "  $Detail" }
    Write-Host ("  PASS  {0,-34}{1}" -f $Name, $suffix) -ForegroundColor Green
}

function Add-Warn {
    param([string]$Name, [string]$Detail = '')
    $script:Warn++
    $suffix = ''
    if ($Detail) { $suffix = "  $Detail" }
    Write-Host ("  WARN  {0,-34}{1}" -f $Name, $suffix) -ForegroundColor Yellow
}

function Add-Fail {
    param([string]$Name, [string]$Detail = '')
    $script:Fail++
    $suffix = ''
    if ($Detail) { $suffix = "  $Detail" }
    Write-Host ("  FAIL  {0,-34}{1}" -f $Name, $suffix) -ForegroundColor Red
    [void]$script:Failures.Add("$Name - $Detail")
}

function Write-Group {
    param([string]$Title)
    Write-Host ''
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host ('  ' + ('-' * 62)) -ForegroundColor DarkGray
}

function Get-ToolVersion {
    param([string]$Command, [string[]]$Arguments)

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        return $null
    }

    try {
        $output = & $Command @Arguments 2>&1 | Select-Object -First 1
        return "$output".Trim()
    } catch {
        return 'present, version unknown'
    }
}

function Test-TcpEndpoint {
    param(
        [string]$TargetHost,
        [int]$Port = 443,
        [int]$TimeoutMs = 4000
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($TargetHost, $Port, $null, $null)
        $reached = $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if (-not $reached) { return $false }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

# ===========================================================================
Write-Host ''
Write-Host '  ZCode dev setup - verification report' -ForegroundColor White
Write-Host "  $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm'))   $env:COMPUTERNAME" -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
Write-Group 'System'

Write-Host ("  info  {0,-34}  {1}" -f 'Windows', [Environment]::OSVersion.VersionString) -ForegroundColor DarkGray
Write-Host ("  info  {0,-34}  {1}" -f 'PowerShell', $PSVersionTable.PSVersion) -ForegroundColor DarkGray
Write-Host ("  info  {0,-34}  {1}" -f 'User', "$env:USERDOMAIN\$env:USERNAME") -ForegroundColor DarkGray

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Add-Pass 'winget available'
} else {
    Add-Fail 'winget available' 'Install "App Installer" from the Microsoft Store'
}

# ---------------------------------------------------------------------------
Write-Group 'Toolchain'

$toolchain = @(
    @{ Name = 'git';    Args = @('--version'); Cmd = 'git';    Hint = 'winget install --id Git.Git -e' }
    @{ Name = 'node';   Args = @('-v');        Cmd = 'node';   Hint = 'winget install --id OpenJS.NodeJS.LTS -e' }
    @{ Name = 'npm';    Args = @('-v');        Cmd = 'npm';    Hint = 'Installed with Node.js' }
    @{ Name = 'python'; Args = @('--version'); Cmd = 'python'; Hint = 'winget install --id Python.Python.3.12 -e' }
    @{ Name = 'uv';     Args = @('--version'); Cmd = 'uv';     Hint = 'winget install --id astral-sh.uv -e' }
    @{ Name = 'gh';     Args = @('--version'); Cmd = 'gh';     Hint = 'winget install --id GitHub.cli -e' }
    @{ Name = 'rg';     Args = @('--version'); Cmd = 'rg';     Hint = 'winget install --id BurntSushi.ripgrep.MSVC -e' }
)

foreach ($tool in $toolchain) {
    $version = Get-ToolVersion -Command $tool.Cmd -Arguments $tool.Args

    if ($version) {
        Add-Pass $tool.Name $version
    } else {
        # rg is genuinely optional; the others are not.
        if ($tool.Name -eq 'rg') {
            Add-Warn $tool.Name "not installed (optional) - $($tool.Hint)"
        } else {
            Add-Fail $tool.Name "not found - $($tool.Hint)"
        }
    }
}

# python3 is a trap on Windows. If it exists, say something.
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    $py3 = & python3 --version 2>&1 | Select-Object -First 1
    if ("$py3" -notmatch 'Python 3') {
        Add-Warn 'python3 alias' 'Using python3 will fail here. Always use "python".'
    }
}

# ---------------------------------------------------------------------------
Write-Group 'Dev folder'

$devRoot = Join-Path $env:USERPROFILE 'Dev'

if (Test-Path $devRoot) {
    Add-Pass 'Dev folder exists' $devRoot

    $inOneDrive = $false
    if ($env:OneDrive -and ($devRoot -like "$($env:OneDrive.TrimEnd('\'))*")) {
        $inOneDrive = $true
    }
    if ($inOneDrive) {
        Add-Fail 'Dev folder outside OneDrive' 'OneDrive sync corrupts node_modules and .git'
    } else {
        Add-Pass 'Dev folder outside OneDrive'
    }

    try {
        $probe = Join-Path $devRoot '.write-test'
        Set-Content -Path $probe -Value 'x' -ErrorAction Stop
        Remove-Item $probe -Force -ErrorAction SilentlyContinue
        Add-Pass 'Dev folder is writable'
    } catch {
        Add-Fail 'Dev folder is writable' $_.Exception.Message
    }

    $projects = @(Get-ChildItem $devRoot -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -notlike '_*' -and $_.Name -ne '.git' })
    Write-Host ("  info  {0,-34}  {1}" -f 'Projects in Dev', $projects.Count) -ForegroundColor DarkGray
} else {
    Add-Warn 'Dev folder exists' "Not created yet: $devRoot"
}

# ---------------------------------------------------------------------------
Write-Group 'Git and GitHub'

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitName  = git config --global user.name  2>$null
    $gitEmail = git config --global user.email 2>$null
    $branch   = git config --global init.defaultBranch 2>$null
    $longpath = git config --global core.longpaths 2>$null

    if ($gitName) { Add-Pass 'git user.name' "$gitName" } else { Add-Fail 'git user.name' 'git config --global user.name "Your Name"' }
    if ($gitEmail) { Add-Pass 'git user.email' "$gitEmail" } else { Add-Fail 'git user.email' 'git config --global user.email "you@example.com"' }
    if ($branch -eq 'main') { Add-Pass 'git init.defaultBranch' 'main' } else { Add-Warn 'git init.defaultBranch' 'not set to main' }
    if ($longpath -eq 'true') { Add-Pass 'git core.longpaths' 'true' } else { Add-Warn 'git core.longpaths' 'not set - long paths will fail' }
} else {
    Add-Fail 'Git configuration' 'git is not installed'
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    $authOut = ''
    $authOk = $false
    try {
        $authOut = (gh auth status 2>&1 | Out-String)
        $authOk = ($LASTEXITCODE -eq 0)
    } catch {
        $authOk = $false
    }

    if ($authOk) {
        $who = ''
        foreach ($line in ($authOut -split "`n")) {
            if ($line -match 'account\s+(\S+)') { $who = $Matches[1]; break }
        }
        if ($who) { Add-Pass 'GitHub authenticated' $who } else { Add-Pass 'GitHub authenticated' }
    } else {
        Add-Fail 'GitHub authenticated' 'Run: gh auth login   then   gh auth setup-git'
    }
} else {
    Add-Fail 'GitHub authentication' 'gh is not installed'
}

# ---------------------------------------------------------------------------
Write-Group 'ZCode'

$zcodeExe = Join-Path $env:LOCALAPPDATA 'Programs\ZCode\ZCode.exe'
$zcodeDir = Join-Path $env:USERPROFILE '.zcode\cli'
$zcodeCfg = Join-Path $zcodeDir 'config.json'

if (Test-Path $zcodeExe) {
    Add-Pass 'ZCode installed' $zcodeExe
} else {
    Add-Fail 'ZCode installed' 'Download from https://zcode.z.ai'
}

if (Test-Path $zcodeCfg) {
    Add-Pass 'config.json exists'

    $config = $null
    try {
        $config = (Get-Content $zcodeCfg -Raw) | ConvertFrom-Json
        Add-Pass 'config.json is valid JSON'
    } catch {
        Add-Fail 'config.json is valid JSON' $_.Exception.Message
    }

    if ($config) {
        if ($config.mcp -and $config.mcp.servers) {
            $names = @($config.mcp.servers.PSObject.Properties.Name)
            if ($names.Count -gt 0) {
                Add-Pass 'MCP servers configured' ($names -join ', ')
            } else {
                Add-Warn 'MCP servers configured' 'mcp.servers exists but is empty'
            }

            if ($names -contains 'notion') { Add-Pass 'Notion MCP registered' } else { Add-Warn 'Notion MCP registered' 'optional - see reference/notion-access.md' }
            if ($names -contains 'blender-fork' -or $names -contains 'blender' -or $names -contains 'mcp-for-blender') {
                Add-Pass 'Blender MCP registered'
            } else {
                Add-Warn 'Blender MCP registered' 'optional'
            }

            if (($names -contains 'blender-fork') -and ($names -contains 'blender')) {
                Add-Warn 'Only one Blender MCP' 'two are registered - the agent may call the wrong one'
            }

            # Every stdio server must point at a program that exists.
            foreach ($property in $config.mcp.servers.PSObject.Properties) {
                $server = $property.Value
                if ($server.command) {
                    $path = "$($server.command)".Replace('/', '\')
                    if ($path -match '^[A-Za-z]:' -and -not (Test-Path $path)) {
                        Add-Fail "MCP '$($property.Name)' command exists" "not found: $($server.command)"
                    } elseif ($path -match '^[A-Za-z]:') {
                        Add-Pass "MCP '$($property.Name)' command exists"
                    }
                }
            }
        } else {
            Add-Warn 'MCP servers configured' 'No mcp.servers in config.json'
        }

        if ($config.plugins -and $config.plugins.enabledPlugins) {
            $enabled = @($config.plugins.enabledPlugins.PSObject.Properties |
                         Where-Object { $_.Value -eq $true } |
                         Select-Object -ExpandProperty Name)
            if ($enabled.Count -gt 0) {
                Add-Pass 'Plugins enabled' ($enabled -join ', ')
            }
        }
    }
} else {
    Add-Warn 'config.json exists' "Not created yet: $zcodeCfg"
    Write-Host '        Open ZCode once and close it, then run this again.' -ForegroundColor DarkGray
}

$mcpAuth = Join-Path $env:USERPROFILE '.mcp-auth\mcp-remote-v1'
if (Test-Path $mcpAuth) {
    Add-Pass 'Notion sign-in cached' 'a browser prompt should not appear again'
} else {
    Add-Warn 'Notion sign-in cached' 'the first Notion call will open a browser'
}

# ---------------------------------------------------------------------------
Write-Group 'Skills and instructions'

$skillRoots = @(
    (Join-Path $env:USERPROFILE '.agents\skills'),
    (Join-Path $env:USERPROFILE '.zcode\skills')
)

$foundSkills = @()
foreach ($root in $skillRoots) {
    if (Test-Path $root) {
        $found = @(Get-ChildItem $root -Directory -ErrorAction SilentlyContinue)
        foreach ($dir in $found) {
            $skillFile = Join-Path $dir.FullName 'SKILL.md'
            if (Test-Path $skillFile) {
                $foundSkills += $dir.Name
            } else {
                Add-Warn "Skill '$($dir.Name)'" 'no SKILL.md directly inside - will not be discovered'
            }
        }
    }
}

if ($foundSkills.Count -gt 0) {
    Add-Pass 'Skills installed' ("$($foundSkills.Count): " + ($foundSkills -join ', '))
} else {
    Add-Warn 'Skills installed' 'none yet - see reference/skills-and-plugins.md'
}

$agentsMd = Join-Path $env:USERPROFILE '.zcode\AGENTS.md'
if (Test-Path $agentsMd) {
    Add-Pass 'Global AGENTS.md' $agentsMd
} else {
    Add-Warn 'Global AGENTS.md' 'optional - config\AGENTS.md in this repo is a starter'
}

# ---------------------------------------------------------------------------
Write-Group 'Network'

$endpoints = @(
    @{ Host = 'zcode.z.ai';            What = 'ZCode download and account' }
    @{ Host = 'mcp.notion.com';        What = 'Notion MCP' }
    @{ Host = 'raw.githubusercontent.com'; What = 'the agent setup runbook' }
    @{ Host = 'github.com';            What = 'GitHub' }
)

foreach ($endpoint in $endpoints) {
    if (Test-TcpEndpoint -TargetHost $endpoint.Host) {
        Add-Pass $endpoint.Host $endpoint.What
    } else {
        Add-Warn $endpoint.Host "unreachable - $($endpoint.What)"
    }
}

# ---------------------------------------------------------------------------
$rule = '  ' + ('=' * 62)
Write-Host ''
Write-Host $rule -ForegroundColor DarkGray
Write-Host ("  {0} passed   {1} warning(s)   {2} failed" -f $script:Pass, $script:Warn, $script:Fail) -ForegroundColor White
Write-Host $rule -ForegroundColor DarkGray

if ($script:Fail -eq 0) {
    Write-Host ''
    Write-Host '  Everything required is in place.' -ForegroundColor Green
    Write-Host '  If you have not done it yet, restart ZCode and start a NEW task, so new MCP servers and skills load.' -ForegroundColor DarkGray
    Write-Host ''
    exit 0
}

Write-Host ''
Write-Host '  Fix these before you start building:' -ForegroundColor Red
foreach ($failure in $script:Failures) {
    Write-Host "    - $failure" -ForegroundColor Red
}
Write-Host ''
Write-Host '  Which step created each one: 01-human-setup.md' -ForegroundColor DarkGray
Write-Host '  Symptom to fix:              reference/troubleshooting.md' -ForegroundColor DarkGray
Write-Host ''

exit 1
