
const fs = require('fs');
const app = require('./app');

const PORT = process.env.PORT || 8080;

const options = {
  key: fs.readFileSync('./certs/key.pem'),
  cert: fs.readFileSync('./certs/cert.pem'),
};

app.listen(process.env.PORT || 8080, '0.0.0.0', () => {
    console.log(`Server läuft auf Port ${process.env.PORT || 8080}`);
  });