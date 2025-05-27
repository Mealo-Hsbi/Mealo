const express = require('express');
const profileRoutes = require('./app/routes/profile.routes');
const mediaRoutes   = require('./app/routes/media.routes');
const userRoutes    = require('./app/routes/user.routes'); // bleibt für Registrierung

const app = express();
app.use(express.json());

app.use('/api', mediaRoutes);
app.use('/api', userRoutes);
app.use('/api', profileRoutes);

module.exports = app;


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
