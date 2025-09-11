FROM ubuntu:22.04

WORKDIR /app


RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY package*.json ./


RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
