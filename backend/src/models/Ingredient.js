const mongoose = require('mongoose');

const ingredientSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  unit: { type: String, required: true }, // e.g. kg, grams, pcs, liters, ml
  currentStock: { type: Number, default: 0, min: 0 },
  lowStockThreshold: { type: Number, default: 10 },
  costPerUnit: { type: Number, default: 0 },
  branchId: { type: String, default: 'branch-1' }
}, { timestamps: true });

ingredientSchema.index({ name: 1, branchId: 1 }, { unique: true });

module.exports = mongoose.model('Ingredient', ingredientSchema);
