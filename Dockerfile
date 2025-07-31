# Use Node.js 20 Alpine as base image for smaller size
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 👇 Accept VITE_API_URL as build argument
ARG VITE_API_URL

# 👇 Inject into env file so Vite picks it up during build
RUN echo "VITE_API_URL=${VITE_API_URL}" > .env.production

# 👇 Build the application with env vars
RUN npm run build

# Production image
FROM nginx:alpine AS runner
WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY --from=builder /app/dist .

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 3002

CMD ["nginx", "-g", "daemon off;"]
