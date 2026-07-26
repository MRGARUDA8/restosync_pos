const mongoose = require('mongoose');

const inventoryLogSchema = new mongoose.Schema({
  ingredientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Ingredient', required: true },
  type: { 
    type: String, 
    enum: ['Stock In', 'Stock Out', 'Recipe Deduction', 'Waste Tracking'], 
    required: true 
  },
  quantity: { type: Number, required: true },
  reason: { type: String, default: '' },
  performedBy: { type: String, default: 'System' },
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

module.exports = mongoose.model('InventoryLog', inventoryLogSchema);
