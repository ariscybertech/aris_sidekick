import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:i18next/i18next.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../components/atoms/typography.dart';
import '../../../components/molecules/list_tile.dart';
import '../../../modules/common/utils/open_link.dart';
import '../dto/pub_package.dto.dart';
import 'package_score_display.dart';

/// Package list item
class PackageListItem extends StatelessWidget {
  /// Constructor
  const PackageListItem(
    this.package, {
    Key key,
    this.position,
  }) : super(key: key);

  /// Detail of a package
  final PackageDetail package;

  /// Popular position of package
  final int position;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black26,
            child: Text(
              position.toString(),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          title: Text(package.name),
          subtitle: Text(
            package.description,
            maxLines: 2,
            style: Theme.of(context).textTheme.caption,
          ),
          trailing: PackageScoreDisplay(score: package.score),
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  Caption(
                    I18Next.of(context).t(
                      'modules:pubPackages.components.packageprojectscountProjects',
                      variables: {
                        'packageProjectsCount':
                            package.projectsCount.toString(),
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('·'),
                  const SizedBox(width: 10),
                  Caption(package.version),
                  Spacer(),
                  Tooltip(
                    message: I18Next.of(context)
                        .t('modules:pubPackages.components.details'),
                    child: IconButton(
                      iconSize: 20,
                      splashRadius: 20,
                      icon: const Icon(MdiIcons.informationOutline),
                      onPressed: () async {
                        await openLink(context, package.url);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('·'),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: I18Next.of(context)
                        .t('modules:pubPackages.components.changelog'),
                    child: IconButton(
                      iconSize: 20,
                      splashRadius: 20,
                      icon: const Icon(MdiIcons.textBox),
                      onPressed: () async {
                        await openLink(context, package.changelogUrl);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('·'),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: I18Next.of(context)
                        .t('modules:pubPackages.components.website'),
                    child: IconButton(
                      iconSize: 20,
                      splashRadius: 20,
                      icon: const Icon(MdiIcons.earth),
                      onPressed: () async {
                        await openLink(context, package.homepage);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
