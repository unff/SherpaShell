$srcPath = "$PSScriptRoot\Powershell\src"
$buildPath = "$PSScriptRoot\Powershell\build"
$docPath = "$PSScriptRoot\Powershell\docs"
$testPath = "$PSScriptRoot\Powershell\tests"
$moduleName = "SherpaShell"
$modulePath = "$buildPath\$moduleName"
$author = 'Anthony Howell, JC Ryan'
$version = '0.0.1'

task Clean {
    If(Get-Module $moduleName){
        Remove-Module $moduleName
    }
    If(Test-Path $modulePath){
        $null = Remove-Item $modulePath -Recurse -ErrorAction Ignore
    }
}

# platyPS: generate MAML help files for the module from The Module code
task DocGen {
    New-MarkdownHelp -Module $moduleName -OutputFolder $docPath -Language en-US
}

# playPS: generate Markdown help files for the module from MAML
task DocBuild {
    Update-MarkdownHelp $docPath
    New-ExternalHelp $docPath -OutputPath "$modulePath\EN-US"
}

# Generate the psm
task ModuleBuild Clean, DocBuild, {
    $pubFiles = Get-ChildItem "$srcPath\public" -Filter *.ps1 -File
    $privFiles = Get-ChildItem "$srcPath\private" -Filter *.ps1 -File
    If(-not(Test-Path $modulePath)){
        New-Item $modulePath -ItemType Directory
    }
    ForEach($file in ($pubFiles + $privFiles)) {
        Get-Content $file.FullName | Out-File "$modulePath\$moduleName.psm1" -Append -Encoding utf8
    }
    Copy-Item "$srcPath\$moduleName.psd1" -Destination $modulePath

    $moduleManifestData = @{
        Author = $author
        Copyright = "(c) $((get-date).Year) $author. All rights reserved."
        Path = "$modulePath\$moduleName.psd1"
        FunctionsToExport = $pubFiles.BaseName
        RootModule = "$moduleName.psm1"
        ModuleVersion = $version
        ProjectUri = 'https://github.com/unff/SherpaShell'
    }
    Update-ModuleManifest @moduleManifestData
    Import-Module $modulePath -RequiredVersion $version
}

task Test ModuleBuild, {
    Save-SDAuthConfig -APIKey $env:SDApiKey -Instance $env:SDInstance -Organization $env:SDOrganization
    Invoke-Pester $testPath
}

task Publish Test, {
    Invoke-PSDeploy -Path $PSScriptRoot -Force
}

task All ModuleBuild, Publish