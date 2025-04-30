namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}Asset")]
public class GetAssetCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}