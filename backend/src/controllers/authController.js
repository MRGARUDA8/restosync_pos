const User = require('../models/User');
const { generateTokens, verifyRefreshToken } = require('../config/jwt');

exports.register = async (req, res, next) => {
  try {
    const { name, email, password, role, phone, branchId } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'Email already registered.' });
    }

    const user = await User.create({ name, email, password, role, phone, branchId });
    const tokens = generateTokens(user);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully.',
      data: {
        user: { id: user._id, name: user.name, email: user.email, role: user.role, branchId: user.branchId },
        ...tokens
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }

    const user = await User.findOne({ email });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });
    }

    if (!user.isActive) {
      return res.status(403).json({ success: false, message: 'Account is deactivated. Contact Admin.' });
    }

    const tokens = generateTokens(user);

    return res.json({
      success: true,
      message: 'Login successful.',
      data: {
        user: { id: user._id, name: user.name, email: user.email, role: user.role, branchId: user.branchId },
        ...tokens
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'Refresh token required.' });
    }

    const decoded = verifyRefreshToken(refreshToken);
    const user = await User.findById(decoded.id);
    if (!user || !user.isActive) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token or inactive user.' });
    }

    const tokens = generateTokens(user);
    return res.json({ success: true, data: tokens });
  } catch (error) {
    return res.status(401).json({ success: false, message: 'Invalid or expired refresh token.' });
  }
};

exports.logout = async (req, res) => {
  return res.json({ success: true, message: 'Logout successful.' });
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User with this email does not exist.' });
    }
    // Return standard password reset instructions
    return res.json({
      success: true,
      message: 'Password reset request received. Contact system admin or check support instructions.'
    });
  } catch (error) {
    next(error);
  }
};
