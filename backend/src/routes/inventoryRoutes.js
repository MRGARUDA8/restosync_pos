const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/ingredients', inventoryController.getIngredients);
router.post('/ingredients', authorize(['Admin', 'Manager']), inventoryController.createIngredient);
router.post('/stock-in', authorize(['Admin', 'Manager']), inventoryController.stockIn);
router.post('/wastage', authorize(['Admin', 'Manager', 'Cashier']), inventoryController.wasteTracking);
router.get('/low-stock', inventoryController.getLowStockAlerts);
router.get('/logs', inventoryController.getInventoryLogs);

module.exports = router;
