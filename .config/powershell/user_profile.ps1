# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# config file environment
$CONFIG_FILE = Join-Path $HOME .config/powershell/user_profile.ps1

# none-blinking filled box cursor
[Console]::Write("`e[2 q")

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
if ($Host.UI.SupportsVirtualTerminal) { Set-PSReadLineOption -PredictionSource History }
Set-PSReadLineKeyHandler -Key 'Ctrl+l' -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key 'Alt+l' -Function AcceptNextSuggestionWord

# PSScriptAnalyzer
Import-Module PSScriptAnalyzer
Set-Alias -Name 'psprettier' -Value 'Invoke-Formatter'

# fnm
fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell powershell | Out-String | Invoke-Expression
$Env:Path = '%USERPROFILE%\.node_modules' + ';' + $Env:Path

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Alias
Set-Alias -Name 'c' -Value 'clear'
Set-Alias -Name 'vim' -Value 'nvim'
Set-Alias -Name 'g' -Value 'git'
Set-Alias -Name 'grep' -Value 'rg'
Remove-Item alias:ls
function ls { eza --group-directories-first --icons auto $args }
function la { eza -a --group-directories-first --icons auto $args }
function l { eza -l --group-directories-first --icons auto $args }
function ll { eza -al --group-directories-first --icons auto $args }
Set-Alias -Name 'lg' -Value 'lazygit'
Set-Alias -Name 'nvm' -Value 'fnm'
Set-Alias -Name 'curl' -Value '~/scoop/apps/curl/current/bin/curl.exe'
Set-Alias -Name 'tig' -Value 'C:/Program Files/Git/usr/bin/tig.exe'
function cat { bat --paging=never --style=plain $args }
function less { bat --paging=never $args }

# Functions
# which command
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# update command
function _update {
  scoop update -a && scoop cleanup -a
  npm update -g
  winget upgrade
}

# Restart Explorer command
function Restart-Explorer {
  Stop-Process -Name 'explorer'
  yasbc.exe reload
}

# czg
function czg {
  $originalNodeOptions = $env:NODE_OPTIONS
  $env:NODE_OPTIONS = '--experimental-transform-types --disable-warning ExperimentalWarning'
  & czg $Args
  $env:NODE_OPTIONS = $originalNodeOptions
}

# Completions
# argc-completions
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
$env:ARGC_COMPLETIONS_ROOT = '~\.config\powershell\argc-completions'
$env:ARGC_COMPLETIONS_PATH = ($env:ARGC_COMPLETIONS_ROOT + '\completions\windows;' + $env:ARGC_COMPLETIONS_ROOT + '\completions')
$env:PATH = $env:ARGC_COMPLETIONS_ROOT + '\bin' + [IO.Path]::PathSeparator + $env:PATH
# To add completions for only the specified command, modify next line e.g. $argc_scripts = @("cargo", "git")
$argc_scripts = ((Get-ChildItem -File -Path ($env:ARGC_COMPLETIONS_ROOT + '\completions\windows'), ($env:ARGC_COMPLETIONS_ROOT + '\completions')) | ForEach-Object { $_.BaseName })
argc --argc-completions powershell $argc_scripts | Out-String | Invoke-Expression

# starship
function Invoke-Starship-TransientFunction {
  &starship module character
}
function Invoke-Starship-PreCommand {
  $loc = $executionContext.SessionState.Path.CurrentLocation;
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem") {
    $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt