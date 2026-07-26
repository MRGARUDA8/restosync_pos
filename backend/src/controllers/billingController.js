const Bill = require('../models/Bill');
const Order = require('../models/Order');
const Table = require('../models/Table');
const { deductIngredientsForOrder } = require('../services/recipeService');
const { generateBillPDF } = require('../services/pdfService');
const { emitEvent } = require('../services/socketService');

exports.generateBill = async (req, res, next) => {
  try {
    const { orderId, discount, paymentMethod, paymentDetails, branchId } = req.body;
    const branch = branchId || req.user?.branchId || 'branch-1';

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found.' });

    const discountAmount = Number(discount) || 0;
    const subTotal = order.subTotal;
    const gstTax = order.taxAmount;
    const rawTotal = subTotal + gstTax - discountAmount;
    const grandTotal = Math.round(rawTotal);
    const roundOff = Number((grandTotal - rawTotal).toFixed(2));

    const billCount = await Bill.countDocuments({ branchId: branch });
    const billNumber = `INV-${Date.now().toString().slice(-4)}-${billCount + 1}`;

    const bill = await Bill.create({
      billNumber,
      orderId: order._id,
      orderNumber: order.orderNumber,
      tableNumber: order.tableNumber,
      subTotal,
      gstTax,
      discount: discountAmount,
      roundOff,
      grandTotal,
      paymentMethod: paymentMethod || 'Cash',
      paymentDetails: paymentDetails || [{ method: paymentMethod || 'Cash', amount: grandTotal }],
      isPaid: true,
      branchId: branch,
      billedBy: req.user?.name || 'Cashier'
    });

    // Mark Order Completed
    order.status = 'Completed';
    order.discountAmount = discountAmount;
    order.grandTotal = grandTotal;
    await order.save();

    // Free Table if occupied
    if (order.tableNumber) {
      await Table.findOneAndUpdate(
        { tableNumber: order.tableNumber, branchId: branch },
        { status: 'Available', currentOrderId: null }
      );
    }

    // Trigger Automatic Recipe Engine Inventory Deduction!
    await deductIngredientsForOrder(order.items, branch);

    // Emit Real-time Events
    emitEvent('bill-generated', bill, branch);
    emitEvent('payment-completed', { billId: bill._id, grandTotal: bill.grandTotal }, branch);

    return res.status(201).json({
      success: true,
      message: 'Bill generated and payment completed successfully.',
      data: bill
    });
  } catch (error) {
    next(error);
  }
};

exports.getBills = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const bills = await Bill.find({ branchId }).sort({ createdAt: -1 }).limit(100);
    return res.json({ success: true, count: bills.length, data: bills });
  } catch (error) {
    next(error);
  }
};

exports.getBillById = async (req, res, next) => {
  try {
    const bill = await Bill.findById(req.params.id);
    if (!bill) return res.status(404).json({ success: false, message: 'Bill not found.' });
    return res.json({ success: true, data: bill });
  } catch (error) {
    next(error);
  }
};

exports.downloadBillPDF = async (req, res, next) => {
  try {
    const bill = await Bill.findById(req.params.id);
    if (!bill) return res.status(404).json({ success: false, message: 'Bill not found.' });

    const order = await Order.findById(bill.orderId);
    const billPayload = {
      ...bill.toObject(),
      items: order ? order.items : []
    };

    generateBillPDF(billPayload, res);
  } catch (error) {
    next(error);
  }
};
