const express = require('express');
const router = express.Router();
const kotController = require('../controllers/kotController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/', kotController.getKots);
router.put('/:id/status', kotController.updateKotStatus);

module.exports = router;
