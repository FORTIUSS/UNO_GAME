import 'package:flutter/material.dart';
import 'package:uno_game/utils/constants.dart';

class AppUtils {
  /// Generate a random room code
  static String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < AppConstants.roomCodeLength; i++) {
      code += chars[(random + i * 7) % chars.length];
    }
    
    return code;
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Format timestamp to readable date
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Validate email
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  /// Validate room code
  static bool isValidRoomCode(String code) {
    final regex = RegExp(r'^[A-Z0-9]{${AppConstants.roomCodeLength}}$');
    return regex.hasMatch(code);
  }

  /// Get card suit emoji representation
  static String getCardEmoji(String cardType) {
    switch (cardType) {
      case 'skip':
        return '⊘';
      case 'reverse':
        return '↩';
      case 'draw_two':
        return '+2';
      case 'wild':
        return '○';
      case 'wild_draw_four':
        return '+4';
      default:
        return '•';
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorPalette.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorPalette.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorPalette.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class PlatformUtils {
  /// Get platform specific device info
  static Future<Map<String, String>> getDeviceInfo() async {
    // This would use device_info_plus in production
    return {
      'os': 'android', // or 'ios'
      'version': '1.0.0',
      'model': 'device',
    };
  }

  /// Check platform
  static bool isAndroid() {
    // Would check real platform in production
    return true;
  }

  static bool isIOS() {
    return !isAndroid();
  }
}

class ValidationUtils {
  /// Validate player name
  static String? validatePlayerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Player name cannot be empty';
    }
    if (value.length < 2) {
      return 'Player name must be at least 2 characters';
    }
    if (value.length > 20) {
      return 'Player name must be less than 20 characters';
    }
    return null;
  }

  /// Validate room name
  static String? validateRoomName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Room name cannot be empty';
    }
    if (value.length < 3) {
      return 'Room name must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Room name must be less than 30 characters';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate custom rule text
  static String? validateCustomRule(String? value) {
    if (value == null || value.isEmpty) {
      return 'Rule cannot be empty';
    }
    if (value.length > 100) {
      return 'Rule must be less than 100 characters';
    }
    return null;
  }
}

class ColorUtils {
  /// Get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = (0.299 * backgroundColor.red +
        0.587 * backgroundColor.green +
        0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Lighten color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

class StringUtils {
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Truncate string
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Format number with separators
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match match) => ',',
    );
  }
}
