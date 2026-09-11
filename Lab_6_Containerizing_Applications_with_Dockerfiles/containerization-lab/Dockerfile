# Use the official Node.js runtime as the base image
# Using specific version for reproducibility
FROM node:18-alpine

# Set metadata labels for better image management
LABEL maintainer="openshift-developer@example.com"
LABEL version="1.0.0"
LABEL description="Sample containerized Node.js application"

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application source code
COPY --chown=nodejs:nodejs . .

# Create necessary directories and set permissions
RUN mkdir -p /usr/src/app/logs && \
    chown -R nodejs:nodejs /usr/src/app

# Switch to non-root user
USER nodejs

# Expose the application port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080

# Define the command to run the application
CMD ["npm", "start"]
