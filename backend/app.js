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
    version,                // aus package.json
    commit: COMMIT_SHA,     // aus ENV_VAR
    now:    new Date().toISOString(),
  });
});

module.exports = app;
