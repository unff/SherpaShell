BeforeAll {
    $accounts = Get-SDAccount
}
Describe 'Accounts' -Tag 'Accounts' {
    Context 'Get' {
        It 'Get-SDAccount should return data' {
            
            $accounts | Should -Not -BeNullOrEmpty
        }
        It 'Get-SDAccount -AccountID should return data' {
            $account = Get-SDAccount -AccountID $accounts[0].id
            $account | Should -Not -BeNullOrEmpty
        }
        It 'Get-SDAccount -AccountID should throw on bad key' {
            {Get-SDAccount -AccountID (New-Guid)} | Should -Throw
        }
    }
}