FROM registry.redhat.io/ubi8/nodejs-16:latest

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
