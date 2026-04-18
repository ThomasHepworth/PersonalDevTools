# --- Stage 1: Build the static files ---
FROM node:lts-alpine AS builder
WORKDIR /app

# Install pnpm (pinned version; avoids flaky corepack registry lookups)
RUN npm install -g pnpm@9

# Copy & install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source & build
COPY . .
RUN pnpm run build

# --- Stage 2: Serve with Nginx ---
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80