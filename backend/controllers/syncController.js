const { SyncLog } = require('../models');

exports.syncInvoice = async (req, res) => {
  try {
    const invoiceData = req.body;
    const syncLog = new SyncLog({
      type: 'invoice',
      payload: invoiceData,
      status: 'synced',
      createdAt: new Date(),
    });
    await syncLog.save();
    return res.status(200).json({ status: 'synced', invoice: invoiceData });
  } catch (error) {
    console.error('Sync invoice error:', error);
    return res.status(500).json({ status: 'failed', error: String(error) });
  }
};

exports.getSyncStatus = async (req, res) => {
  try {
    return res.json({ status: 'ready' });
  } catch (error) {
    return res.status(500).json({ status: 'failed', error: String(error) });
  }
};
