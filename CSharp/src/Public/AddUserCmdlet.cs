namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Add, $"{Consts.ModulePrefix}User")]
public class AddUserCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}