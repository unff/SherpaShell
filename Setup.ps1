./build.ps1

Import-Module .\build\SherpaShell\SherpaShell.psm1 -Force

Get-SDAPIKey -Email 'jryan@sayresd.org'

Get-SDMetaData

