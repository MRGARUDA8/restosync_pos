const Product = require('../models/Product');

exports.getProducts = async (req, res, next) => {
  try {
    const { categoryId, search, isAvailable } = req.query;
    const filter = {};
    if (categoryId) filter.categoryId = categoryId;
    if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';
    if (search) filter.name = { $regex: search, $options: 'i' };

    const products = await Product.find(filter).populate('categoryId', 'name').sort({ name: 1 });
    return res.json({ success: true, count: products.length, data: products });
  } catch (error) {
    next(error);
  }
};

exports.createProduct = async (req, res, next) => {
  try {
    const { name, categoryId, price, gstRate, image, description, isVeg, sku } = req.body;
    const product = await Product.create({
      name,
      categoryId,
      price,
      gstRate: gstRate !== undefined ? gstRate : 5,
      image,
      description,
      isVeg: isVeg !== undefined ? isVeg : true,
      sku
    });
    return res.status(201).json({ success: true, data: product });
  } catch (error) {
    next(error);
  }
};

exports.updateProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const product = await Product.findByIdAndUpdate(id, req.body, { new: true });
    if (!product) return res.status(404).json({ success: false, message: 'Product not found.' });
    return res.json({ success: true, data: product });
  } catch (error) {
    next(error);
  }
};

exports.toggleAvailability = async (req, res, next) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found.' });

    product.isAvailable = !product.isAvailable;
    await product.save();
    return res.json({ success: true, message: `Product availability updated to ${product.isAvailable}`, data: product });
  } catch (error) {
    next(error);
  }
};

exports.deleteProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    await Product.findByIdAndDelete(id);
    return res.json({ success: true, message: 'Product deleted successfully.' });
  } catch (error) {
    next(error);
  }
};
