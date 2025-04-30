namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}Time")]
public class GetTimeCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}