#
# Shellcode dumping script. 
#
# Usage:
#     powershell ./scdump.ps1 w32-exec-calc-shellcode.exe
#
# dumpbin.exe must be in the PATH!
#
# Author: Oleg Mitrofanov (reider-roque) 2015
#


Param ( [String]$filepath = "" )

If ($filepath -eq "") {
    Write-Host "`nUsage: powershell .\scdump.ps1 FILEPATH`n"
    exit
}

If (!(Test-Path $filepath)) {
    Write-Host "`nError: file ""$filepath"" not found.`n"
    exit
}

# Exclude lines contiaining Microsoft or file words, empty lines and lines that don't begin with spaces
$dbMatches = dumpbin /disasm $filepath | Select-String -NotMatch ".*Microsoft.*|.*file.*|^\s*$|^[^\s].*" 

$opcodes = ''
foreach ($dbMatch in $dbMatches) 
{
    # Summary title and everything below should be ignored
    If ($dbMatch.line.Contains("Summary")) { Break }

    $len = $dbMatch.line.Length

    # Remove the address field
    $tmpStr = $dbMatch.line.substring(11, $len-11) 

    # Implicitly populate the built-in $matches variable
    $tmpstr -match "(\s[0-9A-F][0-9A-F])+" > $null

    # $matches[0] holds the overall regex match
    $opcodes += $matches[0]
}

$shellcode = $opcodes |`
    % { $_ -replace " ", "\x" }     # Replace all spaces with \x

Write-Host "`nLength:" ($shellcode.Length / 4)
Write-Host "Shellcode: ""$shellcode""`n"