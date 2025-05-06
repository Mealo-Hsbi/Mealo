const express = require('express');
const userRoutes = require('./app/routes/user.routes');

const app = express();
app.use(express.json());

// Routen einbinden
app.use('/api/users', userRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;