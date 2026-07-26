const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/', productController.getProducts);
router.post('/', authorize(['Admin', 'Manager']), productController.createProduct);
router.put('/:id', authorize(['Admin', 'Manager']), productController.updateProduct);
router.patch('/:id/toggle', authorize(['Admin', 'Manager', 'Cashier']), productController.toggleAvailability);
router.delete('/:id', authorize(['Admin', 'Manager']), productController.deleteProduct);

module.exports = router;
