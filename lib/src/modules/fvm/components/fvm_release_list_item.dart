import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18next/i18next.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../selected_detail/selected_detail.provider.dart';
import '../dialogs/fvm_global_dialog.dart';
import 'fvm_release_actions.dart';
import 'fvm_release_status.dart';

/// FVM release list item
class FvmReleaseListItem extends StatelessWidget {
  /// Constructor
  const FvmReleaseListItem(
    this.release, {
    Key key,
  }) : super(key: key);

  /// Release
  final ReleaseDto release;
  @override
  Widget build(BuildContext context) {
    return SkListTile(
      leading: release.isChannel
          ? const Icon(MdiIcons.alphaCCircle)
          : const Icon(MdiIcons.alphaRCircle),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Subheading(release.name),
          const SizedBox(width: 20),
          release.isGlobal
              ? ActionChip(
                  label: Caption(
                      I18Next.of(context).t('modules:fvm.components.global')),
                  avatar: const Icon(MdiIcons.information, size: 20),
                  onPressed: () {
                    showGlobalInfoDialog(context);
                  },
                )
              : Container(),
          const Spacer(),
          FvmReleaseStatus(release),
        ],
      ),
      trailing: FvmReleaseActions(release),
      onTap: () {
        context.read(selectedDetailProvider).state = SelectedDetail(
          release: release,
        );
      },
    );
  }
}
