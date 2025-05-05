const https = require('https');
const fs = require('fs');
const app = require('./app');

const PORT = process.env.PORT || 8080;

const options = {
  key: fs.readFileSync('./certs/key.pem'),
  cert: fs.readFileSync('./certs/cert.pem'),
};

https.createServer(options, app).listen(PORT, () => {
  console.log(`HTTPS-Server läuft auf https://localhost:${PORT}`);
});
