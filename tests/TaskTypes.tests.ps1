BeforeAll {
    $taskTypes = Get-SDTaskTypes
}
Describe 'TaskTypes' -Tag 'TaskTypes' {
    Context 'Get' {
        It 'Get-SDTaskTypes should return data' {
            $taskTypes | Should -Not -BeNullOrEmpty
        }
    }
}