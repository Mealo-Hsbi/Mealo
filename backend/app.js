const express = require('express');
const profileRoutes = require('./app/routes/profile.routes');
const mediaRoutes   = require('./app/routes/media.routes');
const userRoutes    = require('./app/routes/user.routes'); // bleibt für Registrierung
require('./app/firebase');
const visionRoutes = require('./app/routes/vision.routes');

const app = express();
app.use(express.json());

app.use('/api', mediaRoutes);
app.use('/api', userRoutes);
app.use('/api', profileRoutes);



// Health-Check mit Versions- und Commit-Angabe
app.use('/api/vision', visionRoutes);

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
