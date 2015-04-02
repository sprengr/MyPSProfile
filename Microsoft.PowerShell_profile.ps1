# Load Jump-Location profile
Import-Module Jump.Location

# posh-npm
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
Import-Module posh-npm
Pop-Location

# Autocomplete for different stuff
Import-Module TabExpansion++

# posh-git
Import-Module Posh-git

# Bash Style Auto-complete
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# show only one folder name
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  "$p> "
}

# Current path
function Get-CurrentPath 
{
  return (Get-Item -Path ".\" -Verbose).FullName;
}
Set-Alias cwd Get-CurrentPath

# Build directory (grunt)
Set-PSReadlineKeyHandler -Key Ctrl+B `
                         -BriefDescription BuildCurrentDirectory `
                         -LongDescription "Build the current directory" `
                         -ScriptBlock {
    [PSConsoleUtilities.PSConsoleReadLine]::RevertLine()
    [PSConsoleUtilities.PSConsoleReadLine]::Insert("grunt")
    [PSConsoleUtilities.PSConsoleReadLine]::AcceptLine()
}

# Smart Completion
# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience. 
Set-PSReadlineKeyHandler -Key '"',"'" `
                         -BriefDescription SmartInsertQuote `
                         -LongDescription "Insert paired quotes if not already on a quote" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar) {
        # Just move the cursor
        [PSConsoleUtilities.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        # Insert matching quotes, move cursor to be in between the quotes
        [PSConsoleUtilities.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
        [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [PSConsoleUtilities.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    }
}

Set-PSReadlineKeyHandler -Key '(','{','[' `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    [PSConsoleUtilities.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [PSConsoleUtilities.PSConsoleReadLine]::SetCursorPosition($cursor - 1)        
}

Set-PSReadlineKeyHandler -Key ')',']','}' `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [PSConsoleUtilities.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [PSConsoleUtilities.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadlineKeyHandler -Key Backspace `
                         -BriefDescription SmartBackspace `
                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [PSConsoleUtilities.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        switch ($line[$cursor])
        {
            <#case#> '"' { $toMatch = '"'; break }
            <#case#> "'" { $toMatch = "'"; break }
            <#case#> ')' { $toMatch = '('; break }
            <#case#> ']' { $toMatch = '['; break }
            <#case#> '}' { $toMatch = '{'; break }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [PSConsoleUtilities.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [PSConsoleUtilities.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}
