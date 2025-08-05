// Simple Node.js proxy server to handle CORS
// Install: npm install http-proxy-middleware express cors
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// Enable CORS for all origins
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Proxy API requests to your server
app.use('/api', createProxyMiddleware({
  target: 'https://nextgenerationaustria.at/political-app-api',
  changeOrigin: true,
  secure: true,
  logLevel: 'debug'
}));

// Serve Flutter web app
app.use('/', express.static('build/web'));

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log('API requests will be forwarded to: https://nextgenerationaustria.at/political-app-api');
});
