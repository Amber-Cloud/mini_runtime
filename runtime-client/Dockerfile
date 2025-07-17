# Use the official Node.js image
FROM node:20-alpine

# Set the working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Install serve to serve the built application
RUN npm install -g serve

# Serve the built application
CMD ["serve", "-s", "dist", "-l", "3000"]