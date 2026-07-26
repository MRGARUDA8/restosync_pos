const mongoose = require('mongoose');

const branchSchema = new mongoose.Schema({
  branchId: { type: String, required: true },
  name: { type: String, required: true },
  address: { type: String, default: '' },
  phone: { type: String, default: '' },
  gstin: { type: String, default: '' }
});

const restaurantSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  logoUrl: { type: String, default: '' },
  currency: { type: String, default: 'INR' },
  currencySymbol: { type: String, default: '₹' },
  taxRate: { type: Number, default: 5 }, // Default GST rate %
  branches: {
    type: [branchSchema],
    validate: [val => val.length <= 2, 'RestoSync POS supports a maximum of 2 branches.']
  }
}, { timestamps: true });

module.exports = mongoose.model('Restaurant', restaurantSchema);
