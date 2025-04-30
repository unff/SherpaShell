namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}AssetCategory")]
public class GetAssetCategoryCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}