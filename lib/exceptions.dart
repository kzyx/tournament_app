/// This file contains classes and/or functions relating to the exceptions
/// used in this project.

/// Exception thrown when input to a function is invalid
class InvalidInputException implements Exception {
  String cause;
  InvalidInputException(this.cause);
}