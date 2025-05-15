const { ChromaClient } = require("chromadb");

const client = new ChromaClient({
    path: "http://localhost:8000",
});


const query = process.argv[2];
if (!query) {
    console.error("Lütfen bir arama sorgusu girin.");
    process.exit(1);
}

async function main() {
    try {
        const collection = await client.getOrCreateCollection({ name: "example-collection" });

        const results = await collection.query({
            queryTexts: [query],
            nResults: 3,
        });

        console.log("En yakın sonuçlar:");
        results.documents[0].forEach((doc, i) => {
            console.log(`\nSonuç ${i + 1}:\n${doc}`);
        });

    } catch (err) {
        console.error("Arama hatası:", err);
    }
}

main();
