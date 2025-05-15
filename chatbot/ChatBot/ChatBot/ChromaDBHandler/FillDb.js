const { ChromaClient } = require("chromadb");
const fs = require("fs");
const path = require("path");

const client = new ChromaClient({
    path: "http://localhost:8000",
});

const folderPath = path.join(process.env.HOME || process.env.USERPROFILE, "Desktop", "A");

async function main() {
    try {
        const collection = await client.getOrCreateCollection({ name: "example-collection" });

        const existing = await collection.get();
        if (existing.ids.length > 0) {
            await collection.delete({ ids: existing.ids });
            console.log("Old documents deleted.");
        }

        const files = fs.readdirSync(folderPath).filter(file => file.endsWith(".txt"));

        const ids = [];
        const documents = [];

        files.forEach((file, idx) => {
            const content = fs.readFileSync(path.join(folderPath, file), "utf-8");
            ids.push(`doc${idx + 1}`);
            documents.push(content);
        });

        await collection.add({
            ids: ids,
            documents: documents,
        });

        console.log("New documents added.");

    } catch (err) {
        console.error("Error:", err);
    }
}

main();
