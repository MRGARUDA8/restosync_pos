const mongoose = require('mongoose');

const settingSchema = new mongoose.Schema({
  restaurantName: { type: String, default: 'RestoSync Cloud POS' },
  headerText: { type: String, default: 'Welcome to RestoSync' },
  footerText: { type: String, default: 'Thank you! Visit again.' },
  defaultGstRate: { type: Number, default: 5 },
  thermalPrinterIp: { type: String, default: '192.168.1.200' },
  thermalPrinterPort: { type: Number, default: 9100 },
  autoPrintKOT: { type: Boolean, default: true },
  currencySymbol: { type: String, default: '₹' },
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

module.exports = mongoose.model('Setting', settingSchema);
