class ImageRecognitionError extends Error {
  constructor(message) {
    super(message);
    this.name = "ImageRecognitionError";
  }
}

// backend/app/services/imageRecognition.service.js (AKTUALISIERT)

// Importiere die neue detectIngredients Funktion
const { detectIngredients } = require('./vision.service'); // Pfad anpassen, falls nötig

// Diese Funktion verarbeitet eine Liste von hochgeladenen Bilddateien (von Multer)
exports.processImages = async (imageFiles) => {
    if (!imageFiles || imageFiles.length === 0) {
        return [];
    }

    const allRecognizedIngredients = [];

    for (const file of imageFiles) {
        // Multer stellt den Bildinhalt als Buffer in file.buffer bereit
        const imageBuffer = file.buffer; 

        try {
            // Rufe die detectIngredients Funktion mit dem Buffer auf
            const result = await detectIngredients(imageBuffer);
            
            // Angenommen, detectIngredients gibt ein Objekt der Form {"ingredients": [...]} zurück
            if (result && Array.isArray(result.ingredients)) {
                // Hier extrahieren wir nur die Namen der Zutaten aus der ChatGPT-Antwort
                // Du könntest hier auch weitere Felder (confidence, quantity, unit) speichern,
                // wenn deine Frontend-Ingredients-Struktur das vorsieht.
                const ingredientNames = result.ingredients.map(item => item.name);
                allRecognizedIngredients.push(...ingredientNames);
            } else {
                console.warn('ChatGPT did not return ingredients in the expected format for a file.', result);
            }
        } catch (error) {
            console.error(`Error processing image ${file.originalname}:`, error.message);
            // Je nachdem, wie du mit Fehlern umgehen willst:
            // - Den Fehler weiterwerfen, um den gesamten Request fehlschlagen zu lassen
            // - Oder den Fehler loggen und mit den erfolgreich erkannten Zutaten fortfahren
            // Fürs Erste loggen wir nur und fahren fort.
        }
    }

    // Optional: Duplikate entfernen, wenn du eine Liste einzigartiger Zutaten willst
    const uniqueRecognizedIngredients = [...new Set(allRecognizedIngredients)];
    
    // Rückgabe einer Liste von String-Namen, wie vom Frontend erwartet
    return uniqueRecognizedIngredients; 
};

// Falls du eine eigene Error-Klasse hast, wie im Controller kommentiert:
// class ImageRecognitionError extends Error {
//     constructor(message) {
//         super(message);
//         this.name = 'ImageRecognitionError';
//     }
// }