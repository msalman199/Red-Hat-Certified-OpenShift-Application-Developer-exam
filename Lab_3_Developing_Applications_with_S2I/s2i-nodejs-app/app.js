const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

// Middleware to parse JSON
app.use(express.json());

// Root route
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to S2I Node.js Application - Updated Version!',
        version: '2.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        update: 'Added new features and improved performance'
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// API endpoint
app.get('/api/info', (req, res) => {
    res.json({
        application: 'S2I Demo App',
        technology: 'Node.js with Express',
        build_method: 'Source-to-Image (S2I)',
        author: 'OpenShift Developer'
    });
});

// Start server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
