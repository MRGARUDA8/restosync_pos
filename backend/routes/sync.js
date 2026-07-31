const express = require('express');
const router = express.Router();
const { syncInvoice, getSyncStatus } = require('../controllers/syncController');

router.post('/invoices', syncInvoice);
router.get('/status', getSyncStatus);

module.exports = router;
