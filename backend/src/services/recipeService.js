const Recipe = require('../models/Recipe');
const Ingredient = require('../models/Ingredient');
const InventoryLog = require('../models/Inventory');
const { emitEvent } = require('./socketService');

const deductIngredientsForOrder = async (orderItems, branchId = 'branch-1') => {
  const deductionSummary = [];

  for (const item of orderItems) {
    const recipe = await Recipe.findOne({ productId: item.productId }).populate('ingredients.ingredientId');
    if (!recipe || !recipe.ingredients || recipe.ingredients.length === 0) {
      continue;
    }

    for (const rItem of recipe.ingredients) {
      const ingredient = await Ingredient.findById(rItem.ingredientId._id || rItem.ingredientId);
      if (!ingredient) continue;

      const totalDeduction = rItem.quantityRequired * item.quantity;
      ingredient.currentStock = Math.max(0, ingredient.currentStock - totalDeduction);
      await ingredient.save();

      // Log Inventory Movement
      await InventoryLog.create({
        ingredientId: ingredient._id,
        type: 'Recipe Deduction',
        quantity: totalDeduction,
        reason: `Auto-deducted for Product '${item.name}' (Qty: ${item.quantity})`,
        performedBy: 'Recipe Engine',
        branchId
      });

      deductionSummary.push({
        ingredient: ingredient.name,
        deducted: totalDeduction,
        remaining: ingredient.currentStock,
        unit: ingredient.unit
      });

      // Low Stock Alert Check
      if (ingredient.currentStock <= ingredient.lowStockThreshold) {
        emitEvent('inventory-updated', {
          alert: 'LOW_STOCK',
          ingredientId: ingredient._id,
          name: ingredient.name,
          currentStock: ingredient.currentStock,
          unit: ingredient.unit,
          threshold: ingredient.lowStockThreshold
        }, branchId);
      }
    }
  }

  // Broadcast overall inventory update event
  emitEvent('inventory-updated', {
    type: 'DEDUCTION_COMPLETE',
    deductions: deductionSummary
  }, branchId);

  return deductionSummary;
};

module.exports = { deductIngredientsForOrder };
