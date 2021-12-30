import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../modules/common/dto/channel.dto.dart';
import '../../../modules/common/dto/master.dto.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../fvm_queue.provider.dart';
import 'fvm_master_status.dart';
import 'fvm_setup_button.dart';

/// Display status for a cache release
class FvmReleaseStatus extends StatelessWidget {
  /// Constructor
  const FvmReleaseStatus(
    this.release, {
    Key key,
  }) : super(key: key);

  /// Release
  final ReleaseDto release;
  @override
  Widget build(BuildContext context) {
    if (release == null) {
      return const SizedBox(height: 0);
    }

    // Will use for channel upgrade comparison
    var currentRelease = release.release?.version;
    var latestRelease = release.release?.version;

    // If pending setup
    if (release.needSetup) {
      return SetupButton(release: release);
    }

    // If it's channel set current release;
    if (release.isChannel) {
      final channel = release as ChannelDto;
      currentRelease = channel.sdkVersion;
    }

    // If channel version installed is not the same as current, or if its master
    if (currentRelease == latestRelease) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            MdiIcons.checkCircle,
            size: 20,
          ),
          SizedBox(width: release.isChannel ? 10 : 0),
          release.isChannel
              ? Text('$currentRelease')
              : const SizedBox(height: 0),
        ],
      );
    }

    // If version is master
    if (release is MasterDto) {
      return FvmMasterStatus(release);
    }

    // Default fallback
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(currentRelease),
        const SizedBox(width: 10),
        const Icon(MdiIcons.arrowRight, size: 15),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          icon: const Icon(MdiIcons.triangle, size: 15),
          label: Text(release.release?.version),
          onPressed: () {
            context.read(fvmQueueProvider.notifier).upgrade(context, release);
          },
        ),
      ],
    );
  }
}
