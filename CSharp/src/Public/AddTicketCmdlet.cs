namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Add, $"{Consts.ModulePrefix}Ticket")]
public class AddTicketCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}