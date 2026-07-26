const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  price: { type: Number, required: true, min: 0 },
  gstRate: { type: Number, default: 5 }, // GST %
  image: { type: String, default: '' },
  description: { type: String, default: '' },
  isAvailable: { type: Boolean, default: true },
  isVeg: { type: Boolean, default: true },
  sku: { type: String, default: '' }
}, { timestamps: true });

productSchema.index({ categoryId: 1, name: 1 });

module.exports = mongoose.model('Product', productSchema);
