// backend/app/services/vision.service.js
require('dotenv').config();
const fs    = require('fs');
const path  = require('path');
const sharp = require('sharp');
const OpenAI = require('openai');

// Sicherstellen, dass der API-Key gesetzt ist
if (!process.env.OPENAI_API_KEY) {
  throw new Error('Bitte setze OPENAI_API_KEY in deiner .env-Datei.');
}

// OpenAI-Client initialisieren (v4 SDK)
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

/**
 * Erkennt Zutaten in einem Bild mithilfe von GPT-4o-mini.
 * Das Bild wird automatisch auf max. 512px Breite skaliert,
 * JPEG-komprimiert (Quality 70) und dann als Base64 kodiert.
 * @param {string} imagePath - Pfad zur lokalen Bilddatei
 * @returns {Promise<Object>} - JSON-Objekt mit ingredients-Array
 */
async function detectIngredients(imagePath) {
  // 1) Bild mit sharp einlesen, skalieren und komprimieren
  const buffer = await sharp(imagePath)
    .resize({ width: 512, withoutEnlargement: true })
    .jpeg({ quality: 70 })
    .toBuffer();

  // 2) Base64-String
  const b64 = buffer.toString('base64');

  // 3) Minimaler Prompt, JSON-Only
  const systemPrompt = `Analysiere das Foto, erkenne sichtbare Zutaten und gib ausschließlich diese JSON-Struktur zurück:
{"ingredients":[{"name":string,"confidence":float,"quantity":int,"unit":string},...]}`;
  const userMessage = `data:image/jpeg;base64,${b64}`;

  // 4) GPT-4o-mini Aufruf
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    temperature: 0,
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMessage }
    ]
  });

  // 5) Antwort parsen


  const raw = response.choices[0].message.content.trim();
  try {
    return JSON.parse(raw);
  } catch (err) {
    throw new Error(`JSON Parsing Error: ${err.message}\nAntwort war:\n${raw}`);
  }
}

module.exports = { detectIngredients };
