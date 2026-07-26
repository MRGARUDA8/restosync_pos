const Customer = require('../models/Customer');

exports.getCustomers = async (req, res, next) => {
  try {
    const { search } = req.query;
    const filter = {};
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } }
      ];
    }
    const customers = await Customer.find(filter).sort({ createdAt: -1 });
    return res.json({ success: true, count: customers.length, data: customers });
  } catch (error) {
    next(error);
  }
};

exports.createCustomer = async (req, res, next) => {
  try {
    const { name, phone, email, address } = req.body;
    const existing = await Customer.findOne({ phone });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Customer with this phone number already exists.' });
    }

    const customer = await Customer.create({ name, phone, email, address });
    return res.status(201).json({ success: true, data: customer });
  } catch (error) {
    next(error);
  }
};

exports.updateCustomer = async (req, res, next) => {
  try {
    const customer = await Customer.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!customer) return res.status(404).json({ success: false, message: 'Customer not found.' });
    return res.json({ success: true, data: customer });
  } catch (error) {
    next(error);
  }
};
