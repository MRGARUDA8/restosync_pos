const Supplier = require('../models/Supplier');

exports.getSuppliers = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const suppliers = await Supplier.find({ branchId }).sort({ name: 1 });
    return res.json({ success: true, count: suppliers.length, data: suppliers });
  } catch (error) {
    next(error);
  }
};

exports.createSupplier = async (req, res, next) => {
  try {
    const { name, contactPerson, phone, email, address, gstin, branchId } = req.body;
    const supplier = await Supplier.create({
      name,
      contactPerson,
      phone,
      email,
      address,
      gstin,
      branchId: branchId || req.user?.branchId || 'branch-1'
    });
    return res.status(201).json({ success: true, data: supplier });
  } catch (error) {
    next(error);
  }
};

exports.updateSupplier = async (req, res, next) => {
  try {
    const supplier = await Supplier.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!supplier) return res.status(404).json({ success: false, message: 'Supplier not found.' });
    return res.json({ success: true, data: supplier });
  } catch (error) {
    next(error);
  }
};

exports.deleteSupplier = async (req, res, next) => {
  try {
    await Supplier.findByIdAndDelete(req.params.id);
    return res.json({ success: true, message: 'Supplier deleted successfully.' });
  } catch (error) {
    next(error);
  }
};
