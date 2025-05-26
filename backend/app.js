const express = require('express');
const userRoutes = require('./app/routes/user.routes');
const mediaRoutes = require('./app/routes/media.routes');
require('./app/firebase');


const app = express();
app.use(express.json());

// Routen einbinden
app.use('/api/users', userRoutes);

app.use('/api/media', mediaRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;