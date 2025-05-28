// backend/app/services/vision.service.js (AKTUALISIERT)
const sharp = require('sharp'); // Sicherstellen, dass sharp importiert ist
const openai = require('../../config/openai'); // Annahme: OpenAI-Client ist hier initialisiert

// detectIngredients erhält nun einen Buffer, nicht einen Pfad
async function detectIngredients(imageBuffer) { // GEÄNDERT: imagePath -> imageBuffer
    // 1) Bild mit sharp bearbeiten (Buffer -> Buffer)
    // Das resize/compress ist immer noch nützlich, um die Datenmenge für GPT zu reduzieren
    const processedBuffer = await sharp(imageBuffer) // Nutze den übergebenen Buffer
        .resize({ width: 512, withoutEnlargement: true })
        .jpeg({ quality: 70 })
        .toBuffer();

    // 2) Base64-String
    const b64 = processedBuffer.toString('base64');

    // 3) Minimaler Prompt, JSON-Only
    const systemPrompt = `Analysiere das Foto, erkenne sichtbare Zutaten und gib ausschließlich diese JSON-Struktur zurück:
{"ingredients":[{"name":string,"confidence":float,"quantity":int,"unit":string},...]}`;
    
    // Wichtig: ChatGPT Vision benötigt das MIME-Type Präfix im Data URI
    // Annahme: Alle Bilder, die hier ankommen, sind JPEGs nach der Sharp-Verarbeitung
    const userMessage = `data:image/jpeg;base64,${b64}`; 

    // 4) GPT-4o-mini Aufruf
    const response = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        temperature: 0,
        messages: [
            { role: 'system', content: systemPrompt },
            { 
              role: 'user', 
              content: [ // content ist ein Array für Vision-Prompts
                { type: 'text', text: 'Bitte erkenne alle Zutaten in diesem Bild und gib sie als JSON zurück, wie im System-Prompt beschrieben.' }, // Zusätzlicher Text-Prompt
                { type: 'image_url', image_url: { url: userMessage } } // Bild als Data URL
              ]
            }
        ]
    });

    // 5) Antwort parsen
    const raw = response.choices[0].message.content.trim();
    try {
        // Die Antwort sollte JSON sein, das direkt geparst werden kann
        return JSON.parse(raw); 
    } catch (err) {
        throw new Error(`JSON Parsing Error from OpenAI response: ${err.message}\nRaw response was:\n${raw}`);
    }
}

module.exports = { detectIngredients }; // Sicherstellen, dass exportiert wird