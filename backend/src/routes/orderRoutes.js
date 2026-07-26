const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.post('/', orderController.createOrder);
router.get('/', orderController.getOrders);
router.get('/:id', orderController.getOrderById);
router.put('/:id/items', orderController.updateOrderItems);
router.post('/:id/hold', orderController.holdOrder);
router.post('/:id/resume', orderController.resumeOrder);
router.post('/:id/cancel', orderController.cancelOrder);

module.exports = router;
