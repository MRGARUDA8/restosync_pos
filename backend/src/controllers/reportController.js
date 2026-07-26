const Bill = require('../models/Bill');
const Order = require('../models/Order');
const Table = require('../models/Table');
const Kot = require('../models/Kot');
const Ingredient = require('../models/Ingredient');
const { exportSalesReportExcel } = require('../services/excelService');

exports.getDashboardSummary = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    // Today's Sales & Orders
    const todaysBills = await Bill.find({
      branchId,
      createdAt: { $gte: startOfDay, $lte: endOfDay }
    });

    const todaysSales = todaysBills.reduce((sum, b) => sum + b.grandTotal, 0);
    const todaysOrdersCount = await Order.countDocuments({
      branchId,
      createdAt: { $gte: startOfDay, $lte: endOfDay }
    });

    // Active Tables
    const activeTables = await Table.countDocuments({ branchId, status: 'Occupied' });

    // Pending KOTs
    const pendingKots = await Kot.countDocuments({ branchId, status: { $in: ['New', 'Preparing'] } });

    // Low Stock Items
    const lowStockCount = await Ingredient.countDocuments({
      branchId,
      $expr: { $lte: ['$currentStock', '$lowStockThreshold'] }
    });

    // Top Selling Products Aggregation
    const topProducts = await Order.aggregate([
      { $match: { branchId, status: 'Completed' } },
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.name',
          totalQuantity: { $sum: '$items.quantity' },
          totalRevenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } }
        }
      },
      { $sort: { totalQuantity: -1 } },
      { $limit: 5 }
    ]);

    return res.json({
      success: true,
      data: {
        todaysSales,
        todaysOrdersCount,
        activeTables,
        pendingKots,
        lowStockCount,
        topProducts
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.getSalesReport = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    const { period, exportType } = req.query; // daily, weekly, monthly

    let startDate = new Date();
    if (period === 'weekly') {
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === 'monthly') {
      startDate.setDate(startDate.getDate() - 30);
    } else {
      startDate.setHours(0, 0, 0, 0); // Daily
    }

    const bills = await Bill.find({
      branchId,
      createdAt: { $gte: startDate }
    }).sort({ createdAt: -1 });

    if (exportType === 'excel') {
      return await exportSalesReportExcel(bills, res);
    }

    const totalRevenue = bills.reduce((acc, b) => acc + b.grandTotal, 0);
    const totalGst = bills.reduce((acc, b) => acc + b.gstTax, 0);
    const totalDiscount = bills.reduce((acc, b) => acc + b.discount, 0);

    return res.json({
      success: true,
      period: period || 'daily',
      summary: {
        totalBills: bills.length,
        totalRevenue,
        totalGst,
        totalDiscount
      },
      data: bills
    });
  } catch (error) {
    next(error);
  }
};
