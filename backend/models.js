const mongoose = require('mongoose');

const SyncLogSchema = new mongoose.Schema({
  type: { type: String, required: true },
  payload: { type: Object, required: true },
  status: { type: String, default: 'pending' },
  createdAt: { type: Date, default: Date.now },
});

const AuditLogSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  action: { type: String, required: true },
  reason: { type: String, default: '' },
  timestamp: { type: Date, default: Date.now },
});

module.exports = {
  SyncLog: mongoose.model('SyncLog', SyncLogSchema),
  AuditLog: mongoose.model('AuditLog', AuditLogSchema),
};
