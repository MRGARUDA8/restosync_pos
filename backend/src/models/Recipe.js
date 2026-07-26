const mongoose = require('mongoose');

const recipeItemSchema = new mongoose.Schema({
  ingredientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Ingredient', required: true },
  quantityRequired: { type: Number, required: true, min: 0 } // Amount deducted per product unit
});

const recipeSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true, unique: true },
  ingredients: [recipeItemSchema],
  instructions: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Recipe', recipeSchema);
