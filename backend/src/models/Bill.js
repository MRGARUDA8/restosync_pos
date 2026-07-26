const mongoose = require('mongoose');

const billSchema = new mongoose.Schema({
  billNumber: { type: String, required: true, unique: true },
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  orderNumber: { type: String, required: true },
  tableNumber: { type: String, default: '' },
  subTotal: { type: Number, required: true },
  gstTax: { type: Number, required: true },
  discount: { type: Number, default: 0 },
  roundOff: { type: Number, default: 0 },
  grandTotal: { type: Number, required: true },
  paymentMethod: { 
    type: String, 
    enum: ['Cash', 'UPI', 'Card', 'Split'], 
    default: 'Cash' 
  },
  paymentDetails: [{
    method: { type: String, enum: ['Cash', 'UPI', 'Card'] },
    amount: Number
  }],
  isPaid: { type: Boolean, default: true },
  branchId: { type: String, default: 'branch-1' },
  billedBy: { type: String, default: 'Cashier' }
}, { timestamps: true });

billSchema.index({ branchId: 1, createdAt: -1 });

module.exports = mongoose.model('Bill', billSchema);
