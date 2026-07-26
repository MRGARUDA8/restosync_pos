require('dotenv').config();
const http = require('http');
const app = require('./app');
const connectDB = require('./config/db');
const { initSocket } = require('./config/socket');

// Express Trust Proxy Setting (Render & Rate Limiter Fix)
app.set('trust proxy', 1);

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  // Connect to MongoDB Atlas
  await connectDB();

  // Create HTTP Server
  const server = http.createServer(app);

  // Initialize Socket.IO Real-time Engine
  initSocket(server);

  server.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(` RestoSync Cloud POS Backend running on port ${PORT} `);
    console.log(` Environment: ${process.env.NODE_ENV || 'development'} `);
    console.log(` Web App UI: http://localhost:${PORT} `);
    console.log(`=======================================================`);
  });
};

startServer();