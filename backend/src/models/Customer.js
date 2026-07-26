const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  phone: { type: String, required: true, unique: true, trim: true },
  email: { type: String, default: '' },
  loyaltyPoints: { type: Number, default: 0 },
  totalVisits: { type: Number, default: 0 },
  totalSpent: { type: Number, default: 0 },
  address: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Customer', customerSchema);
