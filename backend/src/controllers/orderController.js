const Order = require('../models/Order');
const Kot = require('../models/Kot');
const Table = require('../models/Table');
const { emitEvent } = require('../services/socketService');

exports.createOrder = async (req, res, next) => {
  try {
    const { orderType, tableNumber, items, kitchenNotes, branchId } = req.body;
    const branch = branchId || req.user?.branchId || 'branch-1';

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Order must contain at least one item.' });
    }

    // Generate Order Number
    const orderCount = await Order.countDocuments({ branchId: branch });
    const orderNumber = `ORD-${Date.now().toString().slice(-4)}-${orderCount + 1}`;

    let subTotal = 0;
    let taxAmount = 0;

    const formattedItems = items.map(item => {
      const lineTotal = item.price * item.quantity;
      const lineTax = (lineTotal * (item.gstRate || 5)) / 100;
      subTotal += lineTotal;
      taxAmount += lineTax;
      return {
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        notes: item.notes || '',
        gstRate: item.gstRate || 5
      };
    });

    const grandTotal = Math.round(subTotal + taxAmount);

    const order = await Order.create({
      orderNumber,
      orderType: orderType || 'Dine In',
      tableNumber: tableNumber || '',
      items: formattedItems,
      subTotal,
      taxAmount,
      grandTotal,
      kitchenNotes: kitchenNotes || '',
      branchId: branch,
      createdBy: req.user?.name || 'Cashier'
    });

    // Mark table Occupied if Dine In
    if (orderType === 'Dine In' && tableNumber) {
      await Table.findOneAndUpdate(
        { tableNumber, branchId: branch },
        { status: 'Occupied', currentOrderId: order._id }
      );
    }

    // Auto-create KOT for Kitchen Display System
    const kotCount = await Kot.countDocuments({ branchId: branch });
    const kotNumber = `KOT-${Date.now().toString().slice(-4)}-${kotCount + 1}`;

    const kot = await Kot.create({
      kotNumber,
      orderId: order._id,
      tableNumber: tableNumber || 'Takeaway',
      orderType: orderType || 'Dine In',
      items: formattedItems.map(i => ({ name: i.name, quantity: i.quantity, notes: i.notes })),
      status: 'New',
      branchId: branch
    });

    // Real-time Socket.IO broadcasts
    emitEvent('order-created', order, branch);
    emitEvent('kot-created', kot, branch);

    return res.status(201).json({
      success: true,
      message: 'Order created successfully.',
      data: { order, kot }
    });
  } catch (error) {
    next(error);
  }
};

exports.getOrders = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const { status, tableNumber } = req.query;

    const filter = { branchId };
    if (status) filter.status = status;
    if (tableNumber) filter.tableNumber = tableNumber;

    const orders = await Order.find(filter).sort({ createdAt: -1 });
    return res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    next(error);
  }
};

exports.getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });
    return res.json({ success: true, data: order });
  } catch (error) {
    next(error);
  }
};

exports.updateOrderItems = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { items, kitchenNotes } = req.body;

    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });

    let subTotal = 0;
    let taxAmount = 0;

    const formattedItems = items.map(item => {
      const lineTotal = item.price * item.quantity;
      const lineTax = (lineTotal * (item.gstRate || 5)) / 100;
      subTotal += lineTotal;
      taxAmount += lineTax;
      return {
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        notes: item.notes || '',
        gstRate: item.gstRate || 5
      };
    });

    order.items = formattedItems;
    order.subTotal = subTotal;
    order.taxAmount = taxAmount;
    order.grandTotal = Math.round(subTotal + taxAmount);
    if (kitchenNotes) order.kitchenNotes = kitchenNotes;

    await order.save();
    emitEvent('order-updated', order, order.branchId);

    return res.json({ success: true, message: 'Order updated successfully.', data: order });
  } catch (error) {
    next(error);
  }
};

exports.holdOrder = async (req, res, next) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, { status: 'Hold' }, { new: true });
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });

    emitEvent('order-updated', order, order.branchId);
    return res.json({ success: true, message: 'Order put on hold.', data: order });
  } catch (error) {
    next(error);
  }
};

exports.resumeOrder = async (req, res, next) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, { status: 'Open' }, { new: true });
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });

    emitEvent('order-updated', order, order.branchId);
    return res.json({ success: true, message: 'Order resumed.', data: order });
  } catch (error) {
    next(error);
  }
};

exports.cancelOrder = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });

    order.status = 'Cancelled';
    await order.save();

    // Free table if occupied
    if (order.tableNumber) {
      await Table.findOneAndUpdate(
        { tableNumber: order.tableNumber, branchId: order.branchId },
        { status: 'Available', currentOrderId: null }
      );
    }

    emitEvent('order-cancelled', order, order.branchId);
    return res.json({ success: true, message: 'Order cancelled.', data: order });
  } catch (error) {
    next(error);
  }
};
