using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

public class ChatModel : PageModel
{
    [BindProperty]
    public string UserMessage { get; set; }

    public string AssistantResponse { get; set; }

    private string apiUrl = "https://api.openai.com/v1"; // API URL
    private string apiKey = "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"; // API Key
    private string assistantId = "asst_L3HHeWRaKijE0VZofrRFcEaM"; // Assistant ID

    // Constructor
    public ChatModel()
    {
    }
    public async Task OnPost()
    {
        if (!string.IsNullOrEmpty(UserMessage))
        {
            // Kullanýcýdan alýnan mesajý OpenAI API'ye gönder ve yanýtý al
            AssistantResponse = await SendUserPrompt(UserMessage);
        }
    }

    // OpenAI'ye kullanýcý mesajýný gönderip yanýt almak için kullanýlan metod
    public async Task<string> SendUserPrompt(string userPrompt)
    {
        string threadId = await CreateThreadAsync(apiKey);
        string response = await CallAssistantAsync(apiKey, assistantId, threadId, userPrompt);
        return response;
    }

    // Thread oluþturma
    private async Task<string> CreateThreadAsync(string apiKey)
    {
        string requestUri = apiUrl + "/threads";

        string json = JsonConvert.SerializeObject(new { });
        StringContent data = new StringContent(json, Encoding.UTF8, "application/json");
        var request = new HttpRequestMessage(HttpMethod.Post, requestUri);
        request.Content = new StringContent(json, Encoding.UTF8, "application/json");

        var client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
        client.DefaultRequestHeaders.Add("OpenAI-Beta", "assistants=v2");

        HttpResponseMessage response = client.SendAsync(request).GetAwaiter().GetResult();
        dynamic responseObject = JsonConvert.DeserializeObject(response.Content.ReadAsStringAsync().GetAwaiter().GetResult());
        string result = responseObject["id"]?.ToString();

        return result;
    }

    private async Task<string> CallAssistantAsync(string apiKey, string assistantId, string threadId, string userPrompt)
    {
        if (string.IsNullOrEmpty(threadId) || string.IsNullOrEmpty(userPrompt))
            throw new ArgumentException("Thread ID and user prompt must not be null or empty.");

        string messageId = await AddMessageToThreadAsync(apiKey, userPrompt, threadId);
        string runId = await RunMessageThreadAsync(apiKey, assistantId, threadId);

        if (string.IsNullOrEmpty(runId))
            throw new InvalidOperationException("Failed to start assistant on the thread.");

        string assistantResponse = await GetAssistantResponseAsync(apiKey, threadId, messageId);
        return assistantResponse ?? "Seems to be a delay in response. Please try again, or try back later.";
    }
    private async Task<string> AddMessageToThreadAsync(string apiKey, string userPrompt, string threadId)
    {
        string url = $"{apiUrl}/threads/{threadId}/messages";
        var requestBody = new { role = "user", content = userPrompt };

        var response = await SendPostRequestAsync(url, apiKey, requestBody);
        return response?.GetValue("id")?.ToString();
    }
    private async Task<string> RunMessageThreadAsync(string apiKey, string assistantId, string threadId)
    {
        string url = $"{apiUrl}/threads/{threadId}/runs";
        var requestBody = new { assistant_id = assistantId };

        var response = await SendPostRequestAsync(url, apiKey, requestBody);
        return response?.GetValue("id")?.ToString();
    }
    private async Task<JObject> SendPostRequestAsync(string url, string apiKey, object requestBody)
    {
        StringContent data = new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");
        var request = new HttpRequestMessage(HttpMethod.Post, url);
        request.Content = new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");

        var client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
        client.DefaultRequestHeaders.Add("OpenAI-Beta", "assistants=v2");

        HttpResponseMessage response = client.SendAsync(request).GetAwaiter().GetResult();
        dynamic responseObject = JsonConvert.DeserializeObject(response.Content.ReadAsStringAsync().GetAwaiter().GetResult());
        return responseObject;
    }
    private async Task<string> GetAssistantResponseAsync(string apiKey, string threadId, string messageId)
    {
        int maxAttempts = 2000;
        int attempts = 0;
        string assistantResponse = null;

        while (attempts < maxAttempts)
        {
            await Task.Delay(500); // Wait for 4 seconds before checking for a response

            string url = $"{apiUrl}/threads/{threadId}/messages";
            var response = await SendGetRequestAsync(url, apiKey);

            var messages = response?.GetValue("data") as JArray;
            if (messages != null)
            {

                foreach (var message in messages)
                {
                    if (message.Value<string>("role") == "assistant")
                    {
                        assistantResponse = message["content"]?.FirstOrDefault()?["text"]?["value"]?.ToString();
                        break;
                    }
                }
            }

            if (!string.IsNullOrEmpty(assistantResponse))
                break;

            attempts++;
        }

        assistantResponse = assistantResponse.Replace("4:0†source", "");
        assistantResponse = assistantResponse.Replace("†", "");

        return assistantResponse;
    }
    private async Task<JObject> SendGetRequestAsync(string url, string apiKey)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, url);

        var client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
        client.DefaultRequestHeaders.Add("OpenAI-Beta", "assistants=v2");

        HttpResponseMessage response = client.SendAsync(request).GetAwaiter().GetResult();
        dynamic responseObject = JsonConvert.DeserializeObject(response.Content.ReadAsStringAsync().GetAwaiter().GetResult());
        return responseObject;
    }
}

