const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from OpenShift BuildConfig Demo!</h1>
    <p>This application was built using OpenShift BuildConfig.</p>
    <p>Build version: ${process.env.BUILD_VERSION || 'development'}</p>
    <p>Current time: ${new Date().toISOString()}</p>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
