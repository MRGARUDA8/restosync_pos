const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
  action: { type: String, required: true },
  user: { type: String, required: true },
  role: { type: String, default: 'Cashier' },
  details: { type: String, default: '' },
  branchId: { type: String, default: 'branch-1' },
  ip: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('AuditLog', auditLogSchema);
