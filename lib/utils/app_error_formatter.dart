import 'dart:io';

class AppErrorFormatter {
  /// Checks if the error or message indicates an internet / network connectivity issue
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    if (error is SocketException) return true;

    final str = error.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('timeoutexception') ||
        str.contains('handshakeexception') ||
        str.contains('failed host lookup') ||
        str.contains('no address associated with hostname') ||
        str.contains('network is unreachable') ||
        str.contains('connection refused') ||
        str.contains('connection timed out') ||
        str.contains('connection closed') ||
        str.contains('software caused connection abort') ||
        str.contains('connection reset by peer') ||
        str.contains('unable to connect') ||
        str.contains('no internet');
  }

  /// Formats any error object into a clean, user-friendly string
  static String format(dynamic error, {String? defaultMessage}) {
    if (error == null) {
      return defaultMessage ?? 'Something went wrong. Please try again.';
    }

    if (isNetworkError(error)) {
      return 'No Internet Connection. Please check your mobile data or Wi-Fi connection and try again.';
    }

    String msg = error.toString().replaceFirst('Exception: ', '').trim();
    if (msg.isEmpty) {
      return defaultMessage ?? 'Something went wrong. Please try again.';
    }
    return msg;
  }

  /// Title to show on error screens
  static String getTitle(dynamic error, {String defaultTitle = 'Oops! Something went wrong'}) {
    if (isNetworkError(error)) {
      return 'No Internet Connection';
    }
    return defaultTitle;
  }
}
