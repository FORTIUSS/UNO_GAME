import 'package:flutter/material.dart';
import 'package:uno_game/models/card_model.dart';

class AppConstants {
  // API Configuration
  static const String backendUrl = 'https://api.uno-game.com';
  static const String wsUrl = 'wss://api.uno-game.com';
  static const int connectionTimeout = 10000; // ms
  static const int maxReconnectAttempts = 5;

  // Game Configuration
  static const int minPlayersPerRoom = 2;
  static const int maxPlayersPerRoom = 10;
  static const int initialHandSize = 7;
  static const int standardDeckSize = 112;

  // UNO Rules
  static const int drawTwoValue = 2;
  static const int wildDrawFourValue = 4;
  static const int skipPointValue = 20;
  static const int reversePointValue = 20;
  static const int wildPointValue = 50;

  // UI Configuration
  static const double cardWidth = 100.0;
  static const double cardHeight = 140.0;
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration uiTransitionDuration = Duration(milliseconds: 200);

  // Room Configuration
  static const int roomCodeLength = 6;
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const Duration reconnectDuration = Duration(seconds: 5);

  // Scoring
  static const int maxCumulativeScore = 500;

  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String deviceIdKey = 'device_id';
  static const String lastSessionKey = 'last_session';
  static const String soundEnabledKey = 'sound_enabled';
  static const String hapticEnabledKey = 'haptic_enabled';
}

class ColorPalette {
  // UNO Card Colors
  static const Color unoRed = Color(0xFFEF3B3B);
  static const Color unoBlue = Color(0xFF3A7BD5);
  static const Color unoGreen = Color(0xFF00AA44);
  static const Color unoYellow = Color(0xFFFDD835);
  static const Color cardWhite = Color(0xFFFAFAFA);

  // Theme Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFCF6679);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF808080);

  static Color getColorForCardColor(CardColor cardColor) {
    switch (cardColor) {
      case CardColor.red:
        return unoRed;
      case CardColor.blue:
        return unoBlue;
      case CardColor.green:
        return unoGreen;
      case CardColor.yellow:
        return unoYellow;
      case CardColor.wild:
        return cardWhite;
    }
  }
}

class AppStrings {
  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String guestLogin = 'Continue as Guest';
  static const String googleSignIn = 'Sign in with Google';
  static const String appleSignIn = 'Sign in with Apple';

  // Game Screens
  static const String homeTitle = 'UNO Game';
  static const String quickPlay = 'Quick Play';
  static const String createRoom = 'Create Room';
  static const String joinRoom = 'Join Room';
  static const String playWithFriends = 'Play with Friends';

  // Game Actions
  static const String drawCard = 'Draw Card';
  static const String callUno = 'UNO!';
  static const String challenge = 'Challenge';
  static const String skipTurn = 'Skip';
  static const String pass = 'Pass';

  // Messages
  static const String waitingForPlayers = 'Waiting for players...';
  static const String gameStarting = 'Game starting...';
  static const String yourTurn = 'Your turn!';
  static const String playerTurn = 'Player\'s turn';
  static const String roundEnded = 'Round ended';
  static const String gameEnded = 'Game ended';
  static const String playerWon = ' won!';
  static const String connectionLost = 'Connection lost';
  static const String reconnecting = 'Reconnecting...';
}

class AppDurations {
  static const Duration cardFlip = Duration(milliseconds: 400);
  static const Duration cardPlay = Duration(milliseconds: 600);
  static const Duration cardDraw = Duration(milliseconds: 500);
  static const Duration turnChange = Duration(milliseconds: 800);
  static const Duration unoCallWindow = Duration(seconds: 5);
  static const Duration inactivityAlert = Duration(seconds: 30);
}

enum AppEnvironment { development, staging, production }

class AppConfig {
  static const AppEnvironment environment = AppEnvironment.production;

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isProduction => environment == AppEnvironment.production;

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = false;
  static const bool enableBotPlayers = false;
}
