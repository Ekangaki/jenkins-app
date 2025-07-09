# Stage 1
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# Stage 2
FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000
CMD ["npm", "start"]
