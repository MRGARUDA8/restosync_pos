const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/dashboard-summary', reportController.getDashboardSummary);
router.get('/sales', reportController.getSalesReport);

module.exports = router;
