BeforeAll {
        $commands = Get-Command -Module 'SherpaShell'
}
Describe 'Module' -Tag Module {
    Context 'Available Commands' {
        It 'Get-SDAccount should be available' {
            $commands.Name | Should -Contain 'Get-SDAccount'
        }
        It 'Get-SDAPIKey should be available' {
            $commands.Name | Should -Contain 'Get-SDAPIKey'
        }
        It 'Get-SDAuthConfig should be available' {
            $commands.Name | Should -Contain 'Get-SDAuthConfig'
        }
        It 'Get-SDMetadata should be available' {
            $commands.Name | Should -Contain 'Get-SDMetadata'
        }
        It 'Get-SDProject should be available' {
            $commands.Name | Should -Contain 'Get-SDProject'
        }
        It 'Get-SDTaskTypes should be available' {
            $commands.Name | Should -Contain 'Get-SDTaskTypes'
        }
        It 'Get-SDTechs should be available' {
            $commands.Name | Should -Contain 'Get-SDTechs'
        }
        It 'Get-SDTicket should be available' {
            $commands.Name | Should -Contain 'Get-SDTicket'
        }
        It 'Get-SDTime should be available' {
            $commands.Name | Should -Contain 'Get-SDTime'
        }
        It 'Get-SDUser should be available' {
            $commands.Name | Should -Contain 'Get-SDUser'
        }
        It 'Add-SDTicket should be available' {
            $commands.Name | Should -Contain 'Add-SDTicket'
        }
        It 'Add-SDUser should be available' {
            $commands.Name | Should -Contain 'Add-SDUser'
        }
        It 'Save-SDAuthConfig should be available' {
            $commands.Name | Should -Contain 'Save-SDAuthConfig'
        }
        It 'Set-SDTicket should be available' {
            $commands.Name | Should -Contain 'Set-SDTicket'
        }
    }
    Context 'Private Commands' {
        It 'Get-SDSavePath should not be available' {
            $commands.Name | Should -Contain 'Get-SDSavePath'
        }
        It 'Invoke-SherpaDeskAPICall should not be available' {
            $commands.Name | Should -Contain 'Invoke-SherpaDeskAPICall'
        }
    }
}