const express = require('express');
const router = express.Router();
const settingController = require('../controllers/settingController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/', settingController.getSettings);
router.put('/', authorize(['Admin']), settingController.updateSettings);

module.exports = router;
