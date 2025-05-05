using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;

class VectorDBHandler
{
    public void FillDb()
    {
        string userPrompt = "Ambar Personel Tanımları Kullanıcı Kılavuzu.";
        string vectorPrompt = GetEmbedding(userPrompt);

        // Vektör stringini dönüştürme
        List<double> queryEmbedding = ConvertToQueryEmbedding(vectorPrompt);

        var client = new HttpClient();
        string url = "http://localhost:8000/api/v2/tenants/chatbot/databases/chatdb/collections/727178d8-ae4a-4c2b-9fb5-5443579a189f/query";

        var queryEmbeddings = new List<List<double>>(); // Boş bir liste oluşturuluyor

        // 5'li bloklarla işlem yapalım
        for (int i = 0; i < queryEmbedding.Count; i += 5)
        {
            var embeddingBlock = new List<double>();

            // 5 elemanlı bir blok alalım (eğer kalan eleman sayısı 5'ten azsa, sadece kalan elemanları alır)
            for (int j = i; j < i + 5 && j < queryEmbedding.Count; j++)
            {
                embeddingBlock.Add(queryEmbedding[j]);
            }

            // Eğer blokta 5 eleman yoksa, eksik olanları 0 ile doldur
            while (embeddingBlock.Count < 5)
            {
                embeddingBlock.Add(0); // 0 ile tamamla
            }

            // Oluşturduğumuz 5'li bloğu queryEmbeddings listesine ekliyoruz
            queryEmbeddings.Add(embeddingBlock);
        }

        var requestBody = new
        {
            ids = new string[] { },
            include = new string[] { "documents" }, // "distances" parametresini kaldırdım çünkü Swagger'da sadece "documents" var
            n_results = 3,
            query_embeddings = queryEmbeddings
        };

        var content = new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");

        try
        {
            var response = client.PostAsync(url, content).GetAwaiter().GetResult();
            response.EnsureSuccessStatusCode(); // 2xx hata kodları dışında hata fırlatır

            string responseBody = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            Console.WriteLine("Response: " + responseBody);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error: " + ex.Message);
        }
    }

    // GetEmbedding metodu
    public static string GetEmbedding(string input)
    {
        using (HttpClient client = new HttpClient())
        {
            // İstek URL'si
            string url = "http://127.0.0.1:11434/api/embeddings";

            // JSON verisini hazırlama
            string jsonData = $"{{\"model\": \"nomic-embed-text\", \"prompt\": \"{EscapeJsonString(input)}\"}}";

            // JSON verisini HttpContent olarak hazırlama
            StringContent content = new StringContent(jsonData, Encoding.UTF8, "application/json");

            // POST isteği gönder
            HttpResponseMessage response = client.PostAsync(url, content).GetAwaiter().GetResult();

            // Yanıtı kontrol et
            if (response.IsSuccessStatusCode)
            {
                // Yanıtın içeriğini al
                string responseContent = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                return responseContent;
            }
            else
            {
                return string.Empty;
            }
        }
    }

    // JSON string'ini doğru formatta escape etmek için
    public static string EscapeJsonString(string input)
    {
        return input.Replace("\"", "\\\"");
    }

    // GetEmbedding'den dönen JSON verisini embedding vektör formatına dönüştürme
    public static List<double> ConvertToQueryEmbedding(string vectorPrompt)
    {
        List<double> firstRow = new List<double>();

        try
        {
            // JSON yanıtını deserialize et
            var jsonResponse = JsonConvert.DeserializeObject<Dictionary<string, object>>(vectorPrompt);

            // "embedding" anahtarından gelen vektörü al
            if (jsonResponse.ContainsKey("embedding"))
            {
                var embeddingJson = jsonResponse["embedding"].ToString();

                // "embedding" içeriği bir liste olmalı, onu deserialize ediyoruz
                var embedding = JsonConvert.DeserializeObject<List<double>>(embeddingJson);

                // Her bir sayıyı firstRow listesine ekle
                firstRow.AddRange(embedding); // AddRange, listeyi topluca ekler
            }
            else
            {
                throw new Exception("Embedding verisi bulunamadı.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error while converting embedding: " + ex.Message);
        }

        return firstRow;
    }
}
