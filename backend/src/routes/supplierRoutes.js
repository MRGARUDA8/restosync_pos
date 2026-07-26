const express = require('express');
const router = express.Router();
const supplierController = require('../controllers/supplierController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/', supplierController.getSuppliers);
router.post('/', authorize(['Admin', 'Manager']), supplierController.createSupplier);
router.put('/:id', authorize(['Admin', 'Manager']), supplierController.updateSupplier);
router.delete('/:id', authorize(['Admin', 'Manager']), supplierController.deleteSupplier);

module.exports = router;
