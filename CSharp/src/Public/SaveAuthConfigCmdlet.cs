namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Save, $"{Consts.ModulePrefix}AuthConfig")]
public class SaveAuthConfigCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}