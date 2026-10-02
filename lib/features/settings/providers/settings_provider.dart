import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification_models.dart';

enum AppLanguage {
  english('English'),
  hindi('Hindi (हिन्दी)'),
  tamil('Tamil (தமிழ்)'),
  telugu('Telugu (తెలుగు)');

  const AppLanguage(this.label);
  final String label;
}

class AppSettings {
  const AppSettings({
    this.language = AppLanguage.english,
    this.pushEnabled = true,
    this.disabledCategories = const <NotificationCategory>{},
    this.emailSummary = false,
    this.sound = true,
    this.vibration = true,
    this.biometricLock = false,
    this.twoFactor = false,
    this.shareLocation = true,
    this.analytics = true,
  });

  final AppLanguage language;
  final bool pushEnabled;
  final Set<NotificationCategory> disabledCategories;
  final bool emailSummary;
  final bool sound;
  final bool vibration;
  final bool biometricLock;
  final bool twoFactor;
  final bool shareLocation;
  final bool analytics;

  bool isCategoryEnabled(NotificationCategory c) =>
      !disabledCategories.contains(c);

  int get enabledCategoryCount =>
      NotificationCategory.values.length - disabledCategories.length;

  AppSettings copyWith({
    AppLanguage? language,
    bool? pushEnabled,
    Set<NotificationCategory>? disabledCategories,
    bool? emailSummary,
    bool? sound,
    bool? vibration,
    bool? biometricLock,
    bool? twoFactor,
    bool? shareLocation,
    bool? analytics,
  }) {
    return AppSettings(
      language: language ?? this.language,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      disabledCategories: disabledCategories ?? this.disabledCategories,
      emailSummary: emailSummary ?? this.emailSummary,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      biometricLock: biometricLock ?? this.biometricLock,
      twoFactor: twoFactor ?? this.twoFactor,
      shareLocation: shareLocation ?? this.shareLocation,
      analytics: analytics ?? this.analytics,
    );
  }
}

/// Session-only in Phase 1. Phase 2 persists these (local storage and
/// the user's server-side preferences).
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setLanguage(AppLanguage v) => state = state.copyWith(language: v);
  void setPush(bool v) => state = state.copyWith(pushEnabled: v);
  void setEmailSummary(bool v) => state = state.copyWith(emailSummary: v);
  void setSound(bool v) => state = state.copyWith(sound: v);
  void setVibration(bool v) => state = state.copyWith(vibration: v);
  void setBiometric(bool v) => state = state.copyWith(biometricLock: v);
  void setTwoFactor(bool v) => state = state.copyWith(twoFactor: v);
  void setShareLocation(bool v) => state = state.copyWith(shareLocation: v);
  void setAnalytics(bool v) => state = state.copyWith(analytics: v);

  void setCategory(NotificationCategory category, bool enabled) {
    final next = {...state.disabledCategories};
    if (enabled) {
      next.remove(category);
    } else {
      next.add(category);
    }
    state = state.copyWith(disabledCategories: next);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);