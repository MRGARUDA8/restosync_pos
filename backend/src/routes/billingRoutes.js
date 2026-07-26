const express = require('express');
const router = express.Router();
const billingController = require('../controllers/billingController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.post('/generate', billingController.generateBill);
router.get('/history', billingController.getBills);
router.get('/:id', billingController.getBillById);
router.get('/:id/pdf', billingController.downloadBillPDF);

module.exports = router;
