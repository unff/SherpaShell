BeforeAll {
    $guid = (New-Guid) -replace '-',''
    $userParams = @{
        FirstName = 'Pester'
        LastName = 'Tester'
        Account = '-1'
        Email = "$guid@howell-it.com"
    }
}
Describe 'Users' -Tag 'Users' {
    Context 'New' {
        It 'Add-SDUser should create a user' {
            $user = Add-SDUser @userParams
            $user | Should -Not -BeNullOrEmpty
        }
        It 'Add-SDUser should throw an error on duplicate user' {
            {Add-SDUser @userParams} | Should -Throw
        }
    }
    Context 'Get' {
        It 'Get-SDUser should return data' {
            $users = Get-SDUser
            $users | Should -Not -BeNullOrEmpty
        }
    }
}