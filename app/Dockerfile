FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY server.js .

ENV PORT=3000
ENV APP_VERSION=1.0.0
ENV APP_ENV=production
ENV APP_COLOUR=#0ea5e9

EXPOSE 3000

USER node

CMD ["node", "server.js"]
