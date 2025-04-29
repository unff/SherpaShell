# Get-SDTime is not implemented correctly yet

# BeforeAll {
#     $testTech = '950330'
#     $times = Get-SDTime
# }
# Describe 'Time' -Tag 'Time' {
#     Context 'Get' {
#         It 'Get-SDTime should return data' {
#             $times | Should -Not -BeNullOrEmpty
#         }
#         It 'Get-SDTime -Tech should return data' {
#             $time = Get-SDTime -Tech $testTech
#             $time | Should -Not -BeNullOrEmpty
#         }
#         It 'Get-SDTime -Account should return data' {
#             $time = Get-SDTime -Account -1
#             $time | Should -Not -BeNullOrEmpty
#         }
#     }
# }