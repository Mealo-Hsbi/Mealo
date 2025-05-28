# 1. Basis-Image
FROM node:20

# 2. Arbeitsverzeichnis
WORKDIR /app

# 3. package.json + package-lock.json kopieren und Abhängigkeiten installieren
COPY package*.json ./
RUN npm install

# 4. OpenSSL-Dev-Bibliothek (für Prisma-Binary auf Debian) installieren
RUN apt-get update && apt-get install -y libssl-dev

# 5. Prisma-Schema kopieren und Client generieren
COPY prisma ./prisma
RUN npx prisma generate

# 6. Restlichen App-Code kopieren
COPY . .

# 7. Port freigeben
EXPOSE 8080

ENV GOOGLE_APPLICATION_CREDENTIALS=/secrets/firebase/serviceAccountKey.json

# 8. Start-Kommando
CMD ["node", "server.js"]

