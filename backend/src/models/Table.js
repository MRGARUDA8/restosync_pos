const mongoose = require('mongoose');

const tableSchema = new mongoose.Schema({
  tableNumber: { type: String, required: true },
  capacity: { type: Number, default: 4 },
  section: { type: String, default: 'Main Dining' },
  status: { 
    type: String, 
    enum: ['Available', 'Occupied', 'Reserved'], 
    default: 'Available' 
  },
  currentOrderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', default: null },
  mergedWith: [{ type: String }],
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

tableSchema.index({ tableNumber: 1, branchId: 1 }, { unique: true });

module.exports = mongoose.model('Table', tableSchema);
