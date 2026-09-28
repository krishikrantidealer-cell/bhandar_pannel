# Multi-stage Dockerfile for Flutter Web on Render.com

# -----------------------------------------------------------
# Stage 1: Build Flutter Web App
# -----------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy full source tree
COPY . .

# Resolve packages & build web bundle
RUN flutter pub get
RUN flutter build web --release --pwa-strategy=none

# -----------------------------------------------------------
# Stage 2: Serve static files with high-performance Nginx Alpine
# -----------------------------------------------------------
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built web artifacts from stage 1
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
