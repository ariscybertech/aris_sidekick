import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../fvm/flutter_config.service.dart';
import 'settings.dto.dart';
import 'settings.service.dart';

/// Settings provider
final settingsProvider =
    StateNotifierProvider<_SettingsStateNotifier, AllSettings>((ref) {
  return _SettingsStateNotifier(ref, initialState: AllSettings());
});

class _SettingsStateNotifier extends StateNotifier<AllSettings> {
  ProviderReference ref;
  _SettingsStateNotifier(
    this.ref, {
    AllSettings initialState,
  }) : super(initialState) {
    // Set initial settings from local storage
    _loadState();
  }

  Future<void> _checkAppSettingsChanges(SidekickSettings settings) async {
    final changed = settings != _prevState.sidekick;

    // Save sidekick settings changed
    if (changed) {
      await SettingsService.save(settings);
    }
  }

  Future<void> _checkAnalyticsChanges(FlutterSettings settings) async {
    final changed = settings != _prevState.flutter;
    // Return if nothing changed
    if (changed) {
      // Toggle analytics
      await FlutterConfigService.setFluterConfig(settings.toMap());
    }
  }

  Future<void> _checkFvmSettingsChanges(FvmSettings settings) async {
    final changed = settings != _prevState.fvm;
    if (changed) {
      await FVMClient.saveSettings(settings);
    }
  }

  AllSettings _prevState;

  Future<void> _loadState() async {
    /// Update app state right away
    final sidekickSettings = SettingsService.read();
    state = AllSettings(sidekick: sidekickSettings);

    //Go get async state
    final fvmSettings = await FVMClient.readSettings();
    final flutterSettings = await FlutterConfigService.getFlutterConfig();
    state = AllSettings(
      // Set state
      sidekick: sidekickSettings,
      fvm: fvmSettings,
      flutter: FlutterSettings.fromMap(flutterSettings),
    );

    /// First run if it's null set
    _prevState ??= state.copy();
  }

  /// Save settings
  Future<void> save(AllSettings settings) async {
    // Check for changes
    try {
      // Trigger refresh

      state = state.copy();
      await _checkFvmSettingsChanges(settings.fvm);
      await _checkAppSettingsChanges(settings.sidekick);
      await _checkAnalyticsChanges(settings.flutter);
      // Set previous state only after success
      _prevState = state.copy();
    } on Exception {
      // Revert settings in case of errors
      state = _prevState;
      rethrow;
    }
  }

  /// Reload settings
  Future<void> reload() async {
    return _loadState();
  }
}
