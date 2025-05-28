require('dotenv').config();
const sharp = require('sharp'); // Sicherstellen, dass sharp importiert ist
const OpenAI = require('openai');

// Sicherstellen, dass der API-Key gesetzt ist
if (!process.env.OPENAI_API_KEY) {
  throw new Error('Bitte setze OPENAI_API_KEY in deiner .env-Datei.');
}

// OpenAI-Client initialisieren (v4 SDK)
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// detectIngredients erhält nun einen Buffer, nicht einen Pfad
async function detectIngredients(imageBuffer) { // GEÄNDERT: imagePath -> imageBuffer
    // 1) Bild mit sharp bearbeiten (Buffer -> Buffer)
    // Das resize/compress ist immer noch nützlich, um die Datenmenge für GPT zu reduzieren
    const processedBuffer = await sharp(imageBuffer) // Nutze den übergebenen Buffer
        .resize({ width: 512, withoutEnlargement: true })
        .jpeg({ quality: 40 })
        .toBuffer();

    // 2) Base64-String
    const b64 = processedBuffer.toString('base64');

    // 3) Minimaler Prompt, JSON-Only
    const systemPrompt = `Analyze the image, identify visible ingredients, and return *only* a JSON object:
      {"ingredients":[{"name":string,"confidence":float,"quantity":number,"unit":string},...]}.
      IMPORTANT: For the 'name' field, always use the singular form of the ingredient (e.g., "Tomato" instead of "Tomatos", "Potato" instead of "Potatoes").`;
    // Assuming image is JPEG after Sharp processing and base64 encoded
    const userMessage = `data:image/jpeg;base64,${b64}`; 

    // 4) GPT-4o-mini API Call
      const response = await openai.chat.completions.create({
        model: 'gpt-4o-mini',
        temperature: 0,
        messages: [
            { role: 'system', content: systemPrompt },
            { 
              role: 'user', 
              content: [
                { type: 'text', text: 'Identify all ingredients in the image and provide them as JSON.' },
                { type: 'image_url', image_url: { url: userMessage } }
              ]
            }
        ]
    });

    // 5) Antwort parsen
    let raw = response.choices[0].message.content.trim();

    // NEU: Entferne den Markdown-Code-Block um das JSON
    if (raw.startsWith('```json')) {
        raw = raw.substring(7); // Entferne '```json'
    }
    if (raw.endsWith('```')) {
        raw = raw.substring(0, raw.length - 3); // Entferne '```'
    }
    raw = raw.trim(); // Erneutes Trimmen, falls Leerzeichen/Newlines übrig bleiben
    console.log('Raw response from OpenAI:', JSON.parse(raw)); // Debugging-Ausgabe
    try {
        return JSON.parse(raw);
    } catch (err) {
        throw new Error(`JSON Parsing Error from OpenAI response: ${err.message}\nRaw response was:\n${raw}`);
    }
}

module.exports = { detectIngredients }; // Sicherstellen, dass exportiert wird