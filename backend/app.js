const express = require('express');
const userRoutes = require('./app/routes/user.routes');
const imageRecognitionRoutes = require('./app/routes/imageRecognition.routes');
require('./app/firebase');
const visionRoutes = require('./app/routes/vision.routes');

const app = express();
app.use(express.json());

// Routen einbinden
app.use('/api/users', userRoutes);
app.use('/api/image-recognition', imageRecognitionRoutes);

app.use('/api/vision', visionRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;