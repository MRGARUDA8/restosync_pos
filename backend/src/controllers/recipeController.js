const Recipe = require('../models/Recipe');
const Product = require('../models/Product');

exports.getRecipeByProduct = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const recipe = await Recipe.findOne({ productId }).populate('ingredients.ingredientId', 'name unit currentStock');
    if (!recipe) {
      return res.status(404).json({ success: false, message: 'No recipe mapping found for this product.' });
    }
    return res.json({ success: true, data: recipe });
  } catch (error) {
    next(error);
  }
};

exports.saveRecipe = async (req, res, next) => {
  try {
    const { productId, ingredients, instructions } = req.body;

    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found.' });

    let recipe = await Recipe.findOne({ productId });
    if (recipe) {
      recipe.ingredients = ingredients;
      if (instructions !== undefined) recipe.instructions = instructions;
      await recipe.save();
    } else {
      recipe = await Recipe.create({ productId, ingredients, instructions });
    }

    return res.status(200).json({
      success: true,
      message: `Recipe for '${product.name}' saved successfully.`,
      data: recipe
    });
  } catch (error) {
    next(error);
  }
};
