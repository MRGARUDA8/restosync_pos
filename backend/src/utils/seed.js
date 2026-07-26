// Google DNS Override to fix "querySrv ECONNREFUSED" issues
try {
  require('dns').setServers(['8.8.8.8', '8.8.4.4', '1.1.1.1']);
} catch (e) {
  // Fallback if DNS setting isn't supported in current node environment
}

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Restaurant = require('../models/Restaurant');
const Table = require('../models/Table');
const Category = require('../models/Category');
const Product = require('../models/Product');
const Ingredient = require('../models/Ingredient');
const Recipe = require('../models/Recipe');
const Order = require('../models/Order');
const Kot = require('../models/Kot');
const Bill = require('../models/Bill');
const Setting = require('../models/Setting');

const seedData = async () => {
  try {
    // Falls back to direct Atlas connection string if process.env.MONGO_URI is missing
    const connStr = process.env.MONGO_URI || 'mongodb+srv://spinadmin:AmanPass1234@cluster0.uabkidw.mongodb.net/restosync?retryWrites=true&w=majority';

    await mongoose.connect(connStr);
    console.log('[Seed] Connected to MongoDB for database seeding...');

    // Clear existing data
    await User.deleteMany({});
    await Restaurant.deleteMany({});
    await Table.deleteMany({});
    await Category.deleteMany({});
    await Product.deleteMany({});
    await Ingredient.deleteMany({});
    await Recipe.deleteMany({});
    await Order.deleteMany({});
    await Kot.deleteMany({});
    await Bill.deleteMany({});
    await Setting.deleteMany({});

    console.log('[Seed] Cleared old collection data.');

    // 1. Create Restaurant & 2 Branches
    await Restaurant.create({
      name: 'RestoSync Gourmet Diner',
      currency: 'INR',
      currencySymbol: '₹',
      taxRate: 5,
      branches: [
        { branchId: 'branch-1', name: 'Downtown Branch', address: '123 Main Street', phone: '+91 9876543210', gstin: '22AAAAA0000A1Z5' },
        { branchId: 'branch-2', name: 'Uptown Branch', address: '456 Commercial Avenue', phone: '+91 9876543211', gstin: '22AAAAA0000A1Z6' }
      ]
    });

    // 2. Create Default Users for Roles
    const admin = await User.create({ name: 'Admin User', email: 'admin@restosync.com', password: 'adminpassword', role: 'Admin', branchId: 'branch-1' });
    const cashier = await User.create({ name: 'Rahul Cashier', email: 'cashier@restosync.com', password: 'cashierpassword', role: 'Cashier', branchId: 'branch-1' });
    const kitchen = await User.create({ name: 'Chef Suresh', email: 'kitchen@restosync.com', password: 'kitchenpassword', role: 'Kitchen Staff', branchId: 'branch-1' });

    console.log('[Seed] Created default users: admin@restosync.com, cashier@restosync.com, kitchen@restosync.com');

    // 3. Create Tables for Floor Plan
    const tables = await Table.insertMany([
      { tableNumber: 'T1', capacity: 2, section: 'Main Dining', status: 'Available', branchId: 'branch-1' },
      { tableNumber: 'T2', capacity: 4, section: 'Main Dining', status: 'Occupied', branchId: 'branch-1' },
      { tableNumber: 'T3', capacity: 4, section: 'Main Dining', status: 'Available', branchId: 'branch-1' },
      { tableNumber: 'T4', capacity: 6, section: 'Family Section', status: 'Reserved', branchId: 'branch-1' },
      { tableNumber: 'T5', capacity: 2, section: 'Patio Outdoor', status: 'Available', branchId: 'branch-1' }
    ]);

    // 4. Create Categories
    const categories = await Category.insertMany([
      { name: 'Burgers & Wraps', description: 'Gourmet handcrafted burgers', icon: 'lunch_dining', sortOrder: 1 },
      { name: 'Pizzas', description: 'Wood-fired sourdough pizzas', icon: 'local_pizza', sortOrder: 2 },
      { name: 'Beverages & Drinks', description: 'Cold brews, shakes, and mocktails', icon: 'local_bar', sortOrder: 3 },
      { name: 'Desserts', description: 'Freshly baked cakes & ice creams', icon: 'cake', sortOrder: 4 }
    ]);

    // 5. Create Ingredients for Recipe Engine
    const ingredients = await Ingredient.insertMany([
      { name: 'Burger Bun', unit: 'pcs', currentStock: 150, lowStockThreshold: 20, costPerUnit: 8, branchId: 'branch-1' },
      { name: 'Cheese Slice', unit: 'pcs', currentStock: 200, lowStockThreshold: 30, costPerUnit: 5, branchId: 'branch-1' },
      { name: 'Chicken Patty', unit: 'pcs', currentStock: 80, lowStockThreshold: 15, costPerUnit: 45, branchId: 'branch-1' },
      { name: 'Veg Patty', unit: 'pcs', currentStock: 100, lowStockThreshold: 20, costPerUnit: 25, branchId: 'branch-1' },
      { name: 'Pizza Dough', unit: 'pcs', currentStock: 60, lowStockThreshold: 10, costPerUnit: 30, branchId: 'branch-1' },
      { name: 'Mozzarella Cheese', unit: 'grams', currentStock: 5000, lowStockThreshold: 1000, costPerUnit: 0.5, branchId: 'branch-1' },
      { name: 'Tomato Sauce', unit: 'ml', currentStock: 8000, lowStockThreshold: 1500, costPerUnit: 0.2, branchId: 'branch-1' }
    ]);

    // 6. Create Products
    const products = await Product.insertMany([
      { name: 'Classic Cheese Burger', categoryId: categories[0]._id, price: 180, gstRate: 5, isVeg: false, description: 'Juicy patty with cheddar' },
      { name: 'Veg Delight Burger', categoryId: categories[0]._id, price: 140, gstRate: 5, isVeg: true, description: 'Crispy veg patty with lettuce' },
      { name: 'Margherita Pizza', categoryId: categories[1]._id, price: 290, gstRate: 5, isVeg: true, description: 'Classic mozzarella & fresh basil' },
      { name: 'Iced Coffee', categoryId: categories[2]._id, price: 120, gstRate: 5, isVeg: true, description: 'Chilled espresso with cream' },
      { name: 'Chocolate Lava Cake', categoryId: categories[3]._id, price: 150, gstRate: 5, isVeg: true, description: 'Warm gooey chocolate center' }
    ]);

    // 7. Create Recipe Mappings
    await Recipe.create({
      productId: products[0]._id,
      ingredients: [
        { ingredientId: ingredients[0]._id, quantityRequired: 1 },
        { ingredientId: ingredients[1]._id, quantityRequired: 1 },
        { ingredientId: ingredients[2]._id, quantityRequired: 1 }
      ],
      instructions: 'Toast bun, grill patty, add cheese slice.'
    });

    await Recipe.create({
      productId: products[2]._id,
      ingredients: [
        { ingredientId: ingredients[4]._id, quantityRequired: 1 },
        { ingredientId: ingredients[5]._id, quantityRequired: 150 },
        { ingredientId: ingredients[6]._id, quantityRequired: 100 }
      ],
      instructions: 'Stretch dough, spread sauce, add mozzarella and bake at 300C.'
    });

    // 8. Create Default Settings
    await Setting.create({
      restaurantName: 'RestoSync Gourmet Diner',
      headerText: 'Welcome to RestoSync Gourmet Diner',
      footerText: 'Thank you for dining with us! Come back soon.',
      defaultGstRate: 5,
      branchId: 'branch-1'
    });

    console.log('[Seed] Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('[Seed Error]', error);
    process.exit(1);
  }
};

seedData();