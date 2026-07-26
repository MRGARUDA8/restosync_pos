const express = require('express');
const router = express.Router();
const tableController = require('../controllers/tableController');
const authenticate = require('../middleware/auth');
const authorize = require('../middleware/rbac');

router.use(authenticate);

router.get('/', tableController.getTables);
router.post('/', authorize(['Admin', 'Manager']), tableController.createTable);
router.put('/:id/status', tableController.updateTableStatus);
router.post('/:id/open', tableController.openTable);
router.post('/:id/close', tableController.closeTable);
router.post('/merge', tableController.mergeTables);
router.post('/:id/split', tableController.splitTables);

module.exports = router;
