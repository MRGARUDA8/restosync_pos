const mongoose = require('mongoose');

const supplierSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  contactPerson: { type: String, default: '' },
  phone: { type: String, required: true },
  email: { type: String, default: '' },
  address: { type: String, default: '' },
  gstin: { type: String, default: '' },
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

module.exports = mongoose.model('Supplier', supplierSchema);
