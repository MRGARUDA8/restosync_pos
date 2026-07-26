const Ingredient = require('../models/Ingredient');
const InventoryLog = require('../models/Inventory');
const { emitEvent } = require('../services/socketService');

exports.getIngredients = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const ingredients = await Ingredient.find({ branchId }).sort({ name: 1 });
    return res.json({ success: true, count: ingredients.length, data: ingredients });
  } catch (error) {
    next(error);
  }
};

exports.createIngredient = async (req, res, next) => {
  try {
    const { name, unit, currentStock, lowStockThreshold, costPerUnit, branchId } = req.body;
    const branch = branchId || req.user?.branchId || 'branch-1';

    const ingredient = await Ingredient.create({
      name,
      unit,
      currentStock: currentStock || 0,
      lowStockThreshold: lowStockThreshold || 10,
      costPerUnit: costPerUnit || 0,
      branchId: branch
    });

    return res.status(201).json({ success: true, data: ingredient });
  } catch (error) {
    next(error);
  }
};

exports.stockIn = async (req, res, next) => {
  try {
    const { ingredientId, quantity, costPerUnit, reason } = req.body;
    const ingredient = await Ingredient.findById(ingredientId);
    if (!ingredient) return res.status(404).json({ success: false, message: 'Ingredient not found.' });

    ingredient.currentStock += Number(quantity);
    if (costPerUnit) ingredient.costPerUnit = Number(costPerUnit);
    await ingredient.save();

    const log = await InventoryLog.create({
      ingredientId,
      type: 'Stock In',
      quantity: Number(quantity),
      reason: reason || 'Manual Stock Purchase / Entry',
      performedBy: req.user?.name || 'Admin',
      branchId: ingredient.branchId
    });

    emitEvent('inventory-updated', { type: 'STOCK_IN', ingredient }, ingredient.branchId);
    return res.json({ success: true, message: 'Stock added successfully.', data: { ingredient, log } });
  } catch (error) {
    next(error);
  }
};

exports.wasteTracking = async (req, res, next) => {
  try {
    const { ingredientId, quantity, reason } = req.body;
    const ingredient = await Ingredient.findById(ingredientId);
    if (!ingredient) return res.status(404).json({ success: false, message: 'Ingredient not found.' });

    ingredient.currentStock = Math.max(0, ingredient.currentStock - Number(quantity));
    await ingredient.save();

    const log = await InventoryLog.create({
      ingredientId,
      type: 'Waste Tracking',
      quantity: Number(quantity),
      reason: reason || 'Spoilage / Waste Log',
      performedBy: req.user?.name || 'Staff',
      branchId: ingredient.branchId
    });

    emitEvent('inventory-updated', { type: 'WASTAGE', ingredient }, ingredient.branchId);
    return res.json({ success: true, message: 'Wastage logged successfully.', data: { ingredient, log } });
  } catch (error) {
    next(error);
  }
};

exports.getLowStockAlerts = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const lowStockItems = await Ingredient.find({
      branchId,
      $expr: { $lte: ['$currentStock', '$lowStockThreshold'] }
    });

    return res.json({ success: true, count: lowStockItems.length, data: lowStockItems });
  } catch (error) {
    next(error);
  }
};

exports.getInventoryLogs = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const logs = await InventoryLog.find({ branchId })
      .populate('ingredientId', 'name unit')
      .sort({ createdAt: -1 })
      .limit(100);

    return res.json({ success: true, count: logs.length, data: logs });
  } catch (error) {
    next(error);
  }
};
