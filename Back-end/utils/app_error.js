'use strict';

class AppError extends Error {
  constructor(type, message, details = null) {
    super(message);
    this.type = type;
    this.details = details;
  }

  static validation(message, details = null) {
    return new AppError('VALIDATION', message, details);
  }

  static conflict(message, details = null) {
    return new AppError('CONFLICT', message, details);
  }
}

module.exports = AppError;
