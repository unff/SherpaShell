namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.VERBNAME, $"{Consts.ModulePrefix}CMDLETNAME")]
public class CLASSNAME : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}