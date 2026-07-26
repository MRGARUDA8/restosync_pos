const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, required: true, min: 1 },
  notes: { type: String, default: '' },
  gstRate: { type: Number, default: 5 }
});

const orderSchema = new mongoose.Schema({
  orderNumber: { type: String, required: true, unique: true },
  orderType: { 
    type: String, 
    enum: ['Dine In', 'Takeaway'], 
    default: 'Dine In' 
  },
  tableNumber: { type: String, default: '' },
  items: [orderItemSchema],
  status: { 
    type: String, 
    enum: ['Open', 'Hold', 'Completed', 'Cancelled'], 
    default: 'Open' 
  },
  subTotal: { type: Number, default: 0 },
  taxAmount: { type: Number, default: 0 },
  discountAmount: { type: Number, default: 0 },
  grandTotal: { type: Number, default: 0 },
  kitchenNotes: { type: String, default: '' },
  branchId: { type: String, default: 'branch-1' },
  createdBy: { type: String, default: 'Cashier' }
}, { timestamps: true });

orderSchema.index({ branchId: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model('Order', orderSchema);
