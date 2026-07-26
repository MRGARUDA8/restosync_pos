const { getIO } = require('../config/socket');

const emitEvent = (eventName, data, branchId = 'branch-1') => {
  const io = getIO();
  if (io) {
    io.emit(eventName, data);
    io.to(`branch:${branchId}`).emit(eventName, data);
    console.log(`[Socket.IO Broadcast] Event '${eventName}' sent to branch '${branchId}'`);
  }
};

module.exports = { emitEvent };
