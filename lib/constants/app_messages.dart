/// Common validation messages
class ValidationMessages {
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidDate = 'Please enter a valid date';
  static const String fileTooLarge = 'File size must be less than 5MB';
  static const String unsupportedFileType = 'Unsupported file type';
  static const String noFileSelected = 'Please select a file';
}

/// Common UI constants
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int animationDuration = 300;
}

/// Common file type extensions
class FileExtensions {
  static const List<String> images = ['jpg', 'jpeg', 'png'];
  static const List<String> documents = ['pdf'];
  static const List<String> attachments = ['jpg', 'jpeg', 'png', 'pdf'];
}

/// Common loading states
class LoadingStates {
  static const String loading = 'Loading...';
  static const String submitting = 'Submitting...';
  static const String processing = 'Processing...';
  static const String uploading = 'Uploading...';
  static const String downloading = 'Downloading...';
  static const String saving = 'Saving...';
}

/// Common error messages
class ErrorMessages {
  static const String networkError =
      'Network connection failed. Please check your internet connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String unauthorizedError =
      'You are not authorized to perform this action.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String validationError =
      'Please check your input and try again.';
}

/// Common success messages
class SuccessMessages {
  static const String dataUpdated = 'Data updated successfully';
  static const String dataSaved = 'Data saved successfully';
  static const String emailSent = 'Email sent successfully';
  static const String passwordChanged = 'Password changed successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String operationCompleted = 'Operation completed successfully';
}
