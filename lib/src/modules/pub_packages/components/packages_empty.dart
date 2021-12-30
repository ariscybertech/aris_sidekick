import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../components/atoms/empty_dataset.dart';

/// Packages empty screen
class EmptyPackages extends StatelessWidget {
  /// Constructor
  const EmptyPackages({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyDataset(
      icon: const Icon(MdiIcons.package),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              I18Next.of(context)
                  .t('modules:pubPackages.components.noPackagesFound'),
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              I18Next.of(context).t(
                  'modules:pubPackages.components.youNeedToAddAFlutterProjectFirstPackageInformation'),
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
