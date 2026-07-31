const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const mongoose = require('mongoose');
const morgan = require('morgan');
const dotenv = require('dotenv');

dotenv.config();
const app = express();
const server = http.createServer(app);

// Allow configurable CORS origin for Render / production deployments.
const FRONTEND_URL = process.env.FRONTEND_URL || '*';
const io = new Server(server, {
  cors: {
    origin: FRONTEND_URL,
    methods: ['GET', 'POST'],
  },
});

const syncRouter = require('./routes/sync');

app.use(cors({ origin: FRONTEND_URL }));
app.use(express.json());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use('/sync', syncRouter);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', name: 'Hacky Pizza POS Backend' });
});

io.on('connection', (socket) => {
  console.log('Socket connected:', socket.id);
  socket.on('order_update', (payload) => {
    io.emit('order_update', payload);
  });
  socket.on('disconnect', () => {
    console.log('Socket disconnected:', socket.id);
  });
});

// MongoDB connection (MongoDB Atlas recommended). Provide via MONGO_URI env var.
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/hacky_pizza_pos';

async function connectWithRetry(uri) {
  try {
    // Mongoose v6+ no longer needs useNewUrlParser etc but keep robust handling
    await mongoose.connect(uri);
    console.log('Connected to MongoDB');
  } catch (err) {
    console.error('MongoDB connection error, retrying in 5s...', err);
    setTimeout(() => connectWithRetry(uri), 5000);
  }
}

connectWithRetry(mongoUri);

const port = process.env.PORT || 4000;

const listener = server.listen(port, () => {
  console.log(`Hacky Pizza POS backend listening on port ${port}`);
});

// Graceful shutdown for Render and other PaaS platforms
function shutdown() {
  console.log('Shutting down server...');
  listener.close(() => {
    mongoose.connection.close(false, () => {
      console.log('MongoDb connection closed.');
      process.exit(0);
    });
  });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
