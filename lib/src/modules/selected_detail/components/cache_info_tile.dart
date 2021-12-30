import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:open_file/open_file.dart';

import '../../../components/atoms/group_tile.dart';
import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../common/dto/release.dto.dart';
import 'cache_date_display.dart';

/// Info about Fvm version
class FvmInfoTile extends StatelessWidget {
  /// Constructor
  const FvmInfoTile(
    this.release, {
    Key key,
  }) : super(key: key);

  /// Release
  final ReleaseDto release;

  @override
  Widget build(BuildContext context) {
    if (!release.isCached) {
      return const SizedBox(height: 0);
    }
    return SkGroupTile(
      title: Text(I18Next.of(context)
          .t('modules:selectedDetail.components.localCacheInformation')),
      children: [
        SkListTile(
          title: Text(I18Next.of(context)
              .t('modules:selectedDetail.components.createdDate')),
          trailing: CacheDateDisplay(release),
        ),
        const Divider(height: 0),
        SkListTile(
          title: Text(I18Next.of(context)
              .t('modules:selectedDetail.components.cacheLocation')),
          subtitle: Caption(release.cache.dir.path),
          trailing: IconButton(
            icon: const Icon(
              Icons.open_in_new,
              size: 20,
            ),
            onPressed: () async {
              await OpenFile.open(release.cache.dir.path);
            },
          ),
        ),
      ],
    );
  }
}
