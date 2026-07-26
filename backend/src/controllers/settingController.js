const Setting = require('../models/Setting');
const Restaurant = require('../models/Restaurant');

exports.getSettings = async (req, res, next) => {
  try {
    const branchId = req.query.branchId || req.user?.branchId || 'branch-1';
    let setting = await Setting.findOne({ branchId });
    if (!setting) {
      setting = await Setting.create({ branchId });
    }
    const restaurant = await Restaurant.findOne() || { name: 'RestoSync POS', currencySymbol: '₹', taxRate: 5 };

    return res.json({
      success: true,
      data: {
        setting,
        restaurant
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.updateSettings = async (req, res, next) => {
  try {
    const branchId = req.body.branchId || req.user?.branchId || 'branch-1';
    let setting = await Setting.findOne({ branchId });
    if (!setting) {
      setting = new Setting({ branchId, ...req.body });
    } else {
      Object.assign(setting, req.body);
    }
    await setting.save();

    return res.json({ success: true, message: 'Settings updated successfully.', data: setting });
  } catch (error) {
    next(error);
  }
};
