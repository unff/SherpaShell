BeforeAll {
    $guid = New-Guid
    $ticketParams = @{
        Status = 'Open'
        Subject = "Test ticket from Pester $guid"
    }
}
Describe 'Tickets' -Tag 'Tickets' {
    Context 'New' {
        It 'Add-SDTicket should create a ticket' {
            $newTicket = Add-SDTicket @ticketParams
            $newTicket | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Get' {
        It 'Get-SDTicket should return data' {
            $tickets = Get-SDTicket
            $tickets | Should -Not -BeNullOrEmpty
        }
        It 'Get-SDTicket -Key $newTicket.ID should return the test ticket' {
            $testTicket = Get-SDTicket -Key $newTicket.ID
            $testTicket.Subject | Should -BeLike "*$guid"
        }
        It 'Get-SDTicket -key should throw on bad key' {
            {Get-SDTicket -key $guid} | Should -Throw
        }
    }
    Context 'Set' {
        It 'Set-SDTicket should change the status' {
            Set-SDTicket -key $newTicket.Id -Status 'Closed'
            $ticket = Get-SDTicket -key $newTicket.Id
            $ticket.status | Should -Be 'Closed'
        }
    }
}
