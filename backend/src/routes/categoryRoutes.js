const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/', categoryController.getCategories);
router.post('/', authorize(['Admin', 'Manager']), categoryController.createCategory);
router.put('/:id', authorize(['Admin', 'Manager']), categoryController.updateCategory);
router.delete('/:id', authorize(['Admin', 'Manager']), categoryController.deleteCategory);

module.exports = router;
