const jwt = require('jsonwebtoken');
const users = require('../data/users.mock');

function login(req, res) {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ message: 'Email dan password wajib diisi' });
  }

  const user = users.find((u) => u.email === email && u.password === password);

  if (!user) {
    return res.status(401).json({ message: 'Email atau password salah' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
  );

  return res.json({
    message: 'Login berhasil',
    token,
    role: user.role,
  });
}

function getProfile(req, res) {
  return res.json({
    message: 'Token valid',
    user: req.user,
  });
}

module.exports = {
  login,
  getProfile,
};
