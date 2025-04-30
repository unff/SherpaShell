namespace SherpaShell;
using System.Management.Automation;

[Cmdlet(VerbsCommon.Set, $"{Consts.ModulePrefix}Ticket")]
public class SetTicketCmdlet : PSCmdlet
{
    [Parameter()] public string example { get; set; } = "example string";
    protected override void EndProcessing() {
        WriteObject("done");
    }
}