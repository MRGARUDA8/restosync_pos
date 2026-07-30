const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
const MONGODB_URI = process.env.MONGODB_URI || '';

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', port: PORT });
});

app.get('/', (req, res) => {
  res.json({ message: 'Hacky Pizza POS backend is running.' });
});

async function connectDb() {
  if (!MONGODB_URI) {
    console.warn('MONGODB_URI is not configured; skipping MongoDB connection.');
    return;
  }

  try {
    await mongoose.connect(MONGODB_URI, {
      dbName: process.env.DB_NAME || 'hackypizza'
    });
    console.log('Connected to MongoDB');
  } catch (err) {
    console.error('MongoDB connection failed:', err);
    process.exit(1);
  }
}

connectDb().then(() => {
  app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
  });
});
