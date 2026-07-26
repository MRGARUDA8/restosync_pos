const mongoose = require('mongoose');

const kotItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  quantity: { type: Number, required: true },
  notes: { type: String, default: '' }
});

const kotSchema = new mongoose.Schema({
  kotNumber: { type: String, required: true },
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  tableNumber: { type: String, default: '' },
  orderType: { type: String, default: 'Dine In' },
  items: [kotItemSchema],
  status: { 
    type: String, 
    enum: ['New', 'Preparing', 'Ready', 'Served'], 
    default: 'New' 
  },
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

kotSchema.index({ branchId: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model('Kot', kotSchema);
