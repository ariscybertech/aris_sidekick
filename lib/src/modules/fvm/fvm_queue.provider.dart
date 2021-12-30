import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvm/fvm.dart';
import 'package:i18next/i18next.dart';

import 'package:state_notifier/state_notifier.dart';

import '../../modules/common/dto/release.dto.dart';
import '../../modules/common/utils/notify.dart';
import '../projects/project.dto.dart';
import '../projects/projects.provider.dart';
import '../settings/settings.provider.dart';
import 'fvm.provider.dart';

class FvmQueue {
  QueueItem activeItem;
  final Queue<QueueItem> queue;
  FvmQueue({@required this.activeItem, @required this.queue});

  bool get isEmpty {
    return queue.isEmpty;
  }

  QueueItem get next {
    activeItem = queue.removeFirst();
    return activeItem;
  }

  FvmQueue update() {
    return FvmQueue(activeItem: activeItem, queue: queue);
  }
}

class QueueItem {
  final ReleaseDto version;
  final QueueAction action;
  QueueItem({this.version, this.action});
}

enum QueueAction {
  setupOnly,
  install,
  installAndSetup,
  channelUpgrade,
  remove,
  setGlobal,
}

/// Releases Provider
final fvmQueueProvider = StateNotifierProvider<FvmQueueState, FvmQueue>((ref) {
  return FvmQueueState(ref: ref);
});

/// State of the FVM Queue
class FvmQueueState extends StateNotifier<FvmQueue> {
  /// Constructor
  FvmQueueState({@required this.ref}) : super(null) {
    state = FvmQueue(activeItem: null, queue: Queue());
  }

  /// Provider ref to be used later
  final ProviderReference ref;

  /// Retrieve FVM Settings
  FvmSettings get settings {
    return ref.read(settingsProvider).fvm;
  }

  ///  Adds install action to queue
  void install(BuildContext context, ReleaseDto version,
      {bool skipSetup}) async {
    skipSetup ??= settings.skipSetup;
    final action =
        skipSetup ? QueueAction.install : QueueAction.installAndSetup;

    await _addToQueue(context, version, action: action);
  }

  /// Adds setup action to queue
  void setup(BuildContext context, ReleaseDto version) {
    _addToQueue(context, version, action: QueueAction.setupOnly);
  }

  /// adds upgrade action to queue
  void upgrade(BuildContext context, ReleaseDto version) {
    _addToQueue(context, version, action: QueueAction.channelUpgrade);
  }

  /// Adds remove action to queue
  void remove(BuildContext context, ReleaseDto version) {
    _addToQueue(context, version, action: QueueAction.remove);
  }

  /// Adds set global action to queue
  void setGlobal(BuildContext context, ReleaseDto version) {
    _addToQueue(context, version, action: QueueAction.setGlobal);
  }

  /// Runs queue
  void runQueue(BuildContext context) async {
    try {
      final queue = state.queue;
      final activeItem = state.activeItem;
      // No need to run if empty
      if (queue.isEmpty) return;
      // If currently installing a version
      if (activeItem != null) return;
      // Gets next item of the queue
      final item = state.next;
      // Update queue
      state = state.update();

      // Run through actions
      switch (item.action) {
        case QueueAction.install:
          await FVMClient.install(item.version.name);
          notify(
            I18Next.of(context).t(
              'modules:fvm.versionItemversionnameHasBeenInstalled',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        case QueueAction.setupOnly:
          await FVMClient.setup(item.version.name);
          notify(
            I18Next.of(context).t(
              'modules:fvm.versionItemversionnameHasFinishedSetup',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        case QueueAction.installAndSetup:
          await FVMClient.install(item.version.name);
          await FVMClient.setup(item.version.name);
          notify(
            I18Next.of(context).t(
              'modules:fvm.versionItemversionnameHasBeenInstalled',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        case QueueAction.channelUpgrade:
          await FVMClient.upgradeChannel(item.version.cache);
          notify(
            I18Next.of(context).t(
              'modules:fvm.channelItemversionnameHasBeenUpgraded',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        case QueueAction.remove:
          await FVMClient.remove(item.version.name);
          notify(
            I18Next.of(context).t(
              'modules:fvm.versionItemversionnameHasBeenRemoved',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        case QueueAction.setGlobal:
          await FVMClient.setGlobalVersion(item.version.cache);
          notify(
            I18Next.of(context).t(
              'modules:fvm.versionItemversionnameHasBeenSetAsGlobal',
              variables: {
                'itemVersionName': item.version.name,
              },
            ),
          );
          break;
        default:
          break;
      }
    } on Exception catch (e) {
      notifyError(e.toString());
    }

    // Set active item to null
    state.activeItem = null;
    // Run update on cache
    await ref.read(fvmCacheProvider.notifier).reloadState();
    // Update queue
    state = state.update();

    // Run queue again
    runQueue(context);
  }

  /// Pins a releae to a project
  Future<void> pinVersion(
      BuildContext context, FlutterProject project, String version) async {
    await FVMClient.pinVersion(project, version);
    await ref.read(projectsProvider.notifier).reload(project);
    notify(
      I18Next.of(context).t(
        'modules:fvm.versionVersionPinnedToProjectname',
        variables: {
          'version': version,
          'projectName': project.name,
        },
      ),
    );
  }

  Future<void> _addToQueue(BuildContext context, ReleaseDto version,
      {QueueAction action}) async {
    state.queue.add(QueueItem(version: version, action: action));
    state = state.update();
    runQueue(context);
  }
}
