'use strict';

const STATUS_POR_TIPO = {
  VALIDATION: 400,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
};

class AppError extends Error {
  constructor(type, message, details = null) {
    super(message);
    this.type = type;
    this.details = details;
  }

  // Status HTTP correspondente ao tipo (default 400).
  get httpStatus() {
    return STATUS_POR_TIPO[this.type] || 400;
  }

  static validation(message, details = null) {
    return new AppError('VALIDATION', message, details);
  }

  static conflict(message, details = null) {
    return new AppError('CONFLICT', message, details);
  }

  static forbidden(message, details = null) {
    return new AppError('FORBIDDEN', message, details);
  }

  static notFound(message, details = null) {
    return new AppError('NOT_FOUND', message, details);
  }
}

module.exports = AppError;
