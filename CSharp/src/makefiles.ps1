$files = Get-ChildItem -Path "C:\Dev\Powershell\SherpaShell\src\Public"
$newpath = "C:\Dev\Powershell\SherpaShell\CSharpsrc\Public"


foreach ($file in $files) { 
    # Get Function Name from File Name
    $name = $file.name -replace ".ps1", ""
    $params = $name.Split("-") # 0 contains verb, 1 contains name

    $newname = $file.name -replace ".ps1", "Cmdlet.cs"
    $newname = $newname -replace "-SD", ""

    $content = Get-Content -Path "C:\Dev\Powershell\SherpaShell\CSharpsrc\template.cs" -Raw
    $content = $content -replace "VERBNAME", $params[0]
    $content = $content -replace "CMDLETNAME", $params[1]
    $content = $content -replace "CLASSNAME", $newname.split('.')[0]

    New-item -Path "$newpath\$newname" -ItemType file -Value $content -Force
}