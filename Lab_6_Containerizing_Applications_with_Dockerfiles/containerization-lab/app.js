const express = require('express');
const app = express();
const port = 8080;

// Middleware to parse JSON
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Main application endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to the Containerized Application!',
        environment: process.env.NODE_ENV || 'development',
        hostname: require('os').hostname()
    });
});

// API endpoint for demonstration
app.get('/api/info', (req, res) => {
    res.json({
        application: 'Sample Containerized App',
        version: '1.0.0',
        author: 'OpenShift Developer',
        description: 'A simple Node.js application for containerization demonstration'
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`Application running on port ${port}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
