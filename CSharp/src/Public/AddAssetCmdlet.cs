namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Add, $"{Consts.ModulePrefix}Asset")]
public class AddAssetCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}