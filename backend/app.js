// app.js

const express      = require('express');
const userRoutes   = require('./app/routes/user.routes');
const mediaRoutes  = require('./app/routes/media.routes');
require('./app/firebase'); // Firebase-Admin initialisiert

// Versions-Info aus package.json
const { version }  = require('./package.json');
// Commit-SHA muss beim Deployment als ENV_VAR gesetzt werden
const COMMIT_SHA   = process.env.COMMIT_SHA || 'dev';

const app = express();
app.use(express.json());

// Endpoints
app.use('/api/users', userRoutes);
app.use('/api/media', mediaRoutes);

// Health-Check mit Versions- und Commit-Angabe
app.get('/health', (req, res) => {
  res.status(200).json({
    status:  'ok',
    version,                // aus package.json
    commit: COMMIT_SHA,     // aus ENV_VAR
    now:    new Date().toISOString(),
  });
});

module.exports = app;
