const Kot = require('../models/Kot');
const { emitEvent } = require('../services/socketService');

exports.getKots = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const { status } = req.query;

    const filter = { branchId };
    if (status) {
      filter.status = status;
    } else {
      // Default return active KOTs
      filter.status = { $ne: 'Served' };
    }

    const kots = await Kot.find(filter).sort({ createdAt: 1 });
    return res.json({ success: true, count: kots.length, data: kots });
  } catch (error) {
    next(error);
  }
};

exports.updateKotStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['New', 'Preparing', 'Ready', 'Served'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid KOT status.' });
    }

    const kot = await Kot.findById(id);
    if (!kot) return res.status(404).json({ success: false, message: 'KOT not found.' });

    kot.status = status;
    await kot.save();

    // Map Socket event names based on status transition
    const eventMap = {
      'Preparing': 'kot-preparing',
      'Ready': 'kot-ready',
      'Served': 'kot-served'
    };

    const eventName = eventMap[status] || 'kot-updated';
    emitEvent(eventName, kot, kot.branchId);

    return res.json({
      success: true,
      message: `KOT status updated to '${status}'.`,
      data: kot
    });
  } catch (error) {
    next(error);
  }
};
