require('dotenv').config();

const allSpoonacularKeys = [
    process.env.SPOONACULAR_API_KEY,
    process.env.SPOONACULAR_API_KEY_1,
    process.env.SPOONACULAR_API_KEY_2,
];

// Filtere alle undefined- oder leeren String-Werte heraus
const validSpoonacularKeys = allSpoonacularKeys.filter(key => key && typeof key === 'string' && key.trim() !== '');

if (validSpoonacularKeys.length === 0) {
    console.warn('Warning: No valid Spoonacular API keys found. API calls will likely fail.');
}

module.exports = {
    spoonacularKeys: validSpoonacularKeys,
    // Hier könnten weitere Konfigurationen liegen
};
    // Hier könnten weitere Konfigurationen liegen