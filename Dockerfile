# ---------------------------
# Stage 1: Base Node.js image
# ---------------------------
    FROM node:20-alpine AS base

    # ---------------------------
    # Stage 2: Install dependencies
    # ---------------------------
    FROM base AS deps
    WORKDIR /app
    RUN apk add --no-cache libc6-compat
    
    COPY package.json package-lock.json* ./
    RUN npm ci
    
    # ---------------------------
# Stage 3: Build application
# ---------------------------
FROM base AS builder
WORKDIR /app

# Accept and export build argument
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}

# Copy dependencies and source code
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Create .env file for Vite build with the API URL
# This ensures the environment variable is available during the build process
RUN echo "VITE_API_URL=${VITE_API_URL}" > .env && \
    echo "Created .env file with VITE_API_URL=${VITE_API_URL}" && \
    cat .env

# Build Vite app
RUN npm run build
    
    # ---------------------------
    # Stage 4: Production image
    # ---------------------------
    FROM nginx:alpine AS runner
    WORKDIR /usr/share/nginx/html
    
    # Remove default nginx static files
    RUN rm -rf ./*
    
    # Copy built frontend from builder
    COPY --from=builder /app/dist .
    
    # Copy custom NGINX config (optional)
    COPY nginx.conf /etc/nginx/nginx.conf
    
    # Expose ports
    EXPOSE 80 3002
    
    # Run NGINX
    CMD ["nginx", "-g", "daemon off;"]
    