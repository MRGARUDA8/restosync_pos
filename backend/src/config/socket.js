const { Server } = require('socket.io');

let io = null;

const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST', 'PUT', 'DELETE']
    }
  });

  io.on('connection', (socket) => {
    console.log(`[Socket.IO] Client connected: ${socket.id}`);

    socket.on('join:branch', (branchId) => {
      socket.join(`branch:${branchId}`);
      console.log(`[Socket.IO] ${socket.id} joined branch:${branchId}`);
    });

    socket.on('disconnect', () => {
      console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
    });
  });

  return io;
};

const getIO = () => {
  if (!io) {
    console.warn('[Socket.IO Warning] Socket.IO instance requested before initialization.');
  }
  return io;
};

module.exports = { initSocket, getIO };
