# Node.js Base
FROM node:18-lts

# Arbeitsverzeichnis setzen
WORKDIR /app

# Dependencies kopieren
COPY package*.json ./
RUN npm install

# Code kopieren
COPY . .

# Port für Cloud Run
EXPOSE 8080

# Startbefehl
CMD [ "node", "server.js" ]
