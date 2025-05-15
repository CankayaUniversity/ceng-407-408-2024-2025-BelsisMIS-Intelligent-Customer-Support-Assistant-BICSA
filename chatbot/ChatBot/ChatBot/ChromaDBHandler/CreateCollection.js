const { ChromaClient } = require("chromadb");

const client = new ChromaClient({
    path: "http://localhost:8000",
});

async function main() {
    try {
        const collection = await client.getOrCreateCollection({ name: "example-collection" });
        console.log("Collection created:", collection.name);
    } catch (err) {
        console.error("Failed to create collection:", err);
    }
}

main();
