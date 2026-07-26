const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const connStr = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/restosync_pos';
    const conn = await mongoose.connect(connStr);
    console.log(`[MongoDB] Connected: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error(`[MongoDB Error] ${error.message}`);
    // Non-fatal fallback for testing/demo without active DB connection
    return null;
  }
};

module.exports = connectDB;
