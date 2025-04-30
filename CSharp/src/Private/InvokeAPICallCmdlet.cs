namespace SherpaShell;
using System;
using System.Management.Automation;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

[Cmdlet(VerbsCommon.Add, $"{Consts.ModulePrefix}Asset")]
public class InvokeAPICallCmdlet : PSCmdlet
{
    [Parameter]
    public string ApiKey { get; set; }

    [Parameter]
    public SwitchParameter PassThru { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        // Use a default ApiKey if none is provided
        if (string.IsNullOrEmpty(ApiKey))
        {
            ApiKey = AuthConfig.ApiKey;
            if (string.IsNullOrEmpty(ApiKey))
            {
                throw new ArgumentException("API Key is required but was not provided.");
            }
        }
    }

    protected override void ProcessRecord()
    {
        base.ProcessRecord();

        // Call the async method and wait for the result
        var metadata = GetSDMetadataAsync(ApiKey).GetAwaiter().GetResult();

        if (metadata.Length > 1)
        {
            WriteHost("Multiple organizations found. Please select one:");
            for (int i = 0; i < metadata.Length; i++)
            {
                WriteHost($"{i} - {metadata[i].Name}");
            }

            int selection = GetSelection(metadata.Length);
            var selectedOrg = metadata[selection];

            // Update AuthConfig with the selected organization and instance
            AuthConfig.WorkingOrganization = selectedOrg.Key;
            AuthConfig.WorkingInstance = selectedOrg.Instances[0].Key;
        }
        else
        {
            var selectedOrg = metadata[0];
            AuthConfig.WorkingOrganization = selectedOrg.Key;
            AuthConfig.WorkingInstance = selectedOrg.Instances[0].Key;
        }

        if (PassThru.IsPresent)
        {
            WriteObject(metadata);
        }
    }

    private static async Task<Organization[]> GetSDMetadataAsync(string apiKey)
    {
        string encodedAuth = Convert.ToBase64String(Encoding.UTF8.GetBytes($"x:{apiKey}"));

        using HttpClient client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", encodedAuth);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        HttpResponseMessage response = await client.GetAsync("https://api.sherpadesk.com/organizations/");
        response.EnsureSuccessStatusCode();

        string responseBody = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<Organization[]>(responseBody);
    }

    private int GetSelection(int maxIndex)
    {
        while (true)
        {
            string input = Host.UI.Prompt("Enter the number corresponding to your choice", string.Empty, null);
            if (int.TryParse(input, out int selection) && selection >= 0 && selection < maxIndex)
            {
                return selection;
            }
            WriteWarning("Invalid selection. Please try again.");
        }
    }

    private void WriteHost(string message)
    {
        Host.UI.WriteLine(message);
    }

    private class Organization
    {
        public string Key { get; set; }
        public string Name { get; set; }
        public Instance[] Instances { get; set; }
    }

    private class Instance
    {
        public string Key { get; set; }
    }

    private static class AuthConfig
    {
        public static string ApiKey { get; set; }
        public static string WorkingOrganization { get; set; }
        public static string WorkingInstance { get; set; }
    }
}