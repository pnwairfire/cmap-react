# Stage 1: Build the React application
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./
RUN apk add --no-cache python3 make g++
# Install dependencies (use ci for reproducible builds if lockfile is present, fallback to install)
RUN npm install --legacy-peer-deps

# Copy the rest of the application files
COPY . .

# Build the app
# Note: package.json has a build script that renames index.html to app.html
RUN NODE_OPTIONS=--openssl-legacy-provider npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built files from the build stage to Nginx's web root
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
