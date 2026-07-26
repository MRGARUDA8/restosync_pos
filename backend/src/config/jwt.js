const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'restosync_super_secret_jwt_key_2026_prod';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'restosync_super_secret_refresh_key_2026_prod';
const JWT_EXPIRE = process.env.JWT_EXPIRE || '24h';
const JWT_REFRESH_EXPIRE = process.env.JWT_REFRESH_EXPIRE || '7d';

const generateTokens = (user) => {
  const payload = {
    id: user._id || user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    branchId: user.branchId
  };

  const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRE });
  const refreshToken = jwt.sign(payload, JWT_REFRESH_SECRET, { expiresIn: JWT_REFRESH_EXPIRE });

  return { accessToken, refreshToken };
};

const verifyAccessToken = (token) => {
  return jwt.verify(token, JWT_SECRET);
};

const verifyRefreshToken = (token) => {
  return jwt.verify(token, JWT_REFRESH_SECRET);
};

module.exports = {
  generateTokens,
  verifyAccessToken,
  verifyRefreshToken
};
