class ImageRecognitionError extends Error {
  constructor(message) {
    super(message);
    this.name = "ImageRecognitionError";
  }
}

/**
 * Processes the uploaded image files to recognize ingredients.
 * This is a simulated implementation for now, returning an array of strings.
 * @param {Array<Object>} imageFiles - Array of image file objects (from multer, with buffer).
 * @returns {Promise<Array<string>>} - A promise that resolves to an array of recognized ingredient names (strings).
 */
exports.processImages = async (imageFiles) => {
  // Simulate a delay to mimic actual image processing
  await new Promise(resolve => setTimeout(resolve, 3000)); // Simulate 3 seconds processing time

  // --- Start of Simulated Logic ---
  // You can uncomment the following lines to simulate an error response
  // const shouldSimulateError = Math.random() < 0.3; // 30% chance to simulate an error
  // if (shouldSimulateError) {
  //   console.error("Simulating an image recognition error.");
  //   throw new ImageRecognitionError("Simulated error: Could not recognize ingredients.");
  // }
  // --- End of Simulated Logic ---

  console.log(`Processing ${imageFiles.length} images... (simulated)`);

  // Simulate recognized ingredient names as strings (now in English)
  const recognizedIngredientNames = [
    'Tomato',
    'Mozzarella',
    'Basil',
    'Olive Oil',
    'Salt',
    'Black Pepper',
    'Garlic', // Added another one
  ];

  return recognizedIngredientNames;
};