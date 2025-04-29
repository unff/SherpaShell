BeforeAll {
    $techs = Get-SDTechs
}
Describe 'Techs' -Tag 'Techs' {
    Context 'Get' {
        It 'Get-SDTechs should return data' {
            $techs | Should -Not -BeNullOrEmpty
        }
    }
}