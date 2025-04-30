namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}AssetStatuses")]
public class GetAssetStatusesCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}