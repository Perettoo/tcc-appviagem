'use strict';

const secret = process.env.JWT_SECRET;
const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

if (!secret) {
  throw new Error('JWT_SECRET nao definido no .env');
}

module.exports = { secret, expiresIn };
