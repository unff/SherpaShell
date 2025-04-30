namespace SherpaShell;
using System;
using System.Management.Automation;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

[Cmdlet(VerbsCommon.Get, $"{Consts.ModulePrefix}SDAPIKey")]
public class GetAPIKeyCmdlet : PSCmdlet
{
    [Parameter(Mandatory = true, ParameterSetName = "EmailOnly")] public string Email { get; set; }
    [Parameter(Mandatory = true, ParameterSetName = "Credential")] public PSCredential Credential { get; set; }
    [Parameter] public SwitchParameter PassThru { get; set; }

    protected override void BeginProcessing() {
        base.BeginProcessing();

        if (ParameterSetName == "EmailOnly")
        {
            // Prompt for credentials if only email is provided
            var credential = Host.UI.PromptForCredential(
                "Retrieving API Key",
                "Enter your SherpaDesk password:",
                Email,
                string.Empty
            );
            Credential = new PSCredential(Email, credential.Password.ToSecureString());
        }
    }

    protected override void ProcessRecord() {
        base.ProcessRecord();

        string email = Credential.UserName;
        string password = Credential.GetNetworkCredential().Password;

        // Call the async method and wait for the result
        string apiKey = GetSDAPIKeyAsync(email, password).GetAwaiter().GetResult();

    }

    protected override void EndProcessing() {
        base.EndProcessing();
        if (PassThru.IsPresent) {
            WriteObject(apiKey);
        }
    }

    private static async Task<string> GetSDAPIKeyAsync(string email, string password) {
        string credentials = $"{email}:{password}";
        string encodedCredentials = Convert.ToBase64String(Encoding.UTF8.GetBytes(credentials));

        using HttpClient client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", encodedCredentials);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        HttpResponseMessage response = await client.GetAsync("https://api.sherpadesk.com/login");
        response.EnsureSuccessStatusCode();

        string responseBody = await response.Content.ReadAsStringAsync();
        var responseJson = JsonSerializer.Deserialize<ApiResponse>(responseBody);

        var authConfig = new AuthConfig
        {
            ApiKey = responseJson.ApiToken,
            WorkingOrganization = string.Empty,
            WorkingInstance = string.Empty
        };
        SessionState.PSVariable.Set("AuthConfig", authConfig); // Store the auth config in a session variable
        return responseJson.ApiToken;
    }

    private class ApiResponse {
        public string ApiToken { get; set; }
    }

    private class AuthConfig {
        public string ApiKey { get; set; }
        public string WorkingOrganization { get; set; }
        public string WorkingInstance { get; set; }
    }
}