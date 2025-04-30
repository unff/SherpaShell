namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Remove, $"{Consts.ModulePrefix}Asset")]
public class RemoveAssetCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}