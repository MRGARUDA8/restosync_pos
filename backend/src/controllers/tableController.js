const Table = require('../models/Table');
const { emitEvent } = require('../services/socketService');

exports.getTables = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const tables = await Table.find({ branchId }).sort({ tableNumber: 1 });
    return res.json({ success: true, count: tables.length, data: tables });
  } catch (error) {
    next(error);
  }
};

exports.createTable = async (req, res, next) => {
  try {
    const { tableNumber, capacity, section, branchId } = req.body;
    const table = await Table.create({
      tableNumber,
      capacity: capacity || 4,
      section: section || 'Main Dining',
      branchId: branchId || req.user?.branchId || 'branch-1'
    });
    return res.status(201).json({ success: true, data: table });
  } catch (error) {
    next(error);
  }
};

exports.updateTableStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, currentOrderId } = req.body;

    const table = await Table.findById(id);
    if (!table) return res.status(404).json({ success: false, message: 'Table not found.' });

    if (status) table.status = status;
    if (currentOrderId !== undefined) table.currentOrderId = currentOrderId;

    await table.save();
    emitEvent('table-updated', table, table.branchId);

    return res.json({ success: true, data: table });
  } catch (error) {
    next(error);
  }
};

exports.openTable = async (req, res, next) => {
  try {
    const { id } = req.params;
    const table = await Table.findByIdAndUpdate(
      id,
      { status: 'Occupied' },
      { new: true }
    );
    if (!table) return res.status(404).json({ success: false, message: 'Table not found.' });

    emitEvent('table-updated', table, table.branchId);
    return res.json({ success: true, message: `Table ${table.tableNumber} is now Occupied.`, data: table });
  } catch (error) {
    next(error);
  }
};

exports.closeTable = async (req, res, next) => {
  try {
    const { id } = req.params;
    const table = await Table.findByIdAndUpdate(
      id,
      { status: 'Available', currentOrderId: null, mergedWith: [] },
      { new: true }
    );
    if (!table) return res.status(404).json({ success: false, message: 'Table not found.' });

    emitEvent('table-updated', table, table.branchId);
    return res.json({ success: true, message: `Table ${table.tableNumber} is now Available.`, data: table });
  } catch (error) {
    next(error);
  }
};

exports.mergeTables = async (req, res, next) => {
  try {
    const { primaryTableId, secondaryTableNumbers } = req.body;
    const table = await Table.findById(primaryTableId);
    if (!table) return res.status(404).json({ success: false, message: 'Primary table not found.' });

    table.mergedWith = secondaryTableNumbers;
    table.status = 'Occupied';
    await table.save();

    // Mark secondary tables as occupied
    await Table.updateMany(
      { tableNumber: { $in: secondaryTableNumbers }, branchId: table.branchId },
      { status: 'Occupied' }
    );

    emitEvent('table-updated', table, table.branchId);
    return res.json({ success: true, message: 'Tables merged successfully.', data: table });
  } catch (error) {
    next(error);
  }
};

exports.splitTables = async (req, res, next) => {
  try {
    const { id } = req.params;
    const table = await Table.findById(id);
    if (!table) return res.status(404).json({ success: false, message: 'Table not found.' });

    const mergedList = [...table.mergedWith];
    table.mergedWith = [];
    await table.save();

    await Table.updateMany(
      { tableNumber: { $in: mergedList }, branchId: table.branchId },
      { status: 'Available' }
    );

    emitEvent('table-updated', table, table.branchId);
    return res.json({ success: true, message: 'Tables split successfully.', data: table });
  } catch (error) {
    next(error);
  }
};
