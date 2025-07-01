const express = require('express');
const allRoutes = require('./app/routes/index');
require('./app/firebase');

const app = express();
app.use(express.json());

// Routen einbinden
app.use('/api', allRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({
    status:  'ok',
    version: '1.0.0',                // aus package.json
    commit: '1234567890',     // aus ENV_VAR
    now:    new Date().toISOString(),
  });
});

module.exports = app;
