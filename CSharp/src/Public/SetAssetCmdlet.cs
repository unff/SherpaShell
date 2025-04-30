namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Set, $"{Consts.ModulePrefix}Asset")]
public class SetAssetCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}