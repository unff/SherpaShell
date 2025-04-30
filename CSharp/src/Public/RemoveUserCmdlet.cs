namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Remove, $"{Consts.ModulePrefix}User")]
public class RemoveUserCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}