FROM node:18-alpine

WORKDIR /app

# On copie package.json EN PREMIER (cache busting)
COPY package.json .
RUN npm install

# PUIS le code source
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]