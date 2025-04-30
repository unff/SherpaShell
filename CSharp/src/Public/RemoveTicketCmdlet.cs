namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Remove, $"{Consts.ModulePrefix}Ticket")]
public class RemoveTicketCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}