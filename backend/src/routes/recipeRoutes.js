const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/product/:productId', recipeController.getRecipeByProduct);
router.post('/save', authorize(['Admin', 'Manager']), recipeController.saveRecipe);

module.exports = router;
