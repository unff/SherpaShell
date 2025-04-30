namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}AccountStatistics")]
public class GetAccountStatisticsCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}