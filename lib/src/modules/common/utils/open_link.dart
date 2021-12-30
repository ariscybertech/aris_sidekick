import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:i18next/i18next.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw I18Next.of(context).t(
      'modules:common.utils.couldNotLaunchUrl',
      variables: {'url': url},
    );
  }
}

Future<void> openPath(BuildContext context, String url) async {
  if (Platform.isWindows) {
    await Process.start(
        I18Next.of(context).t('modules:common.utils.start'), [url]);
  }

  if (Platform.isMacOS) {
    await Process.start(
        I18Next.of(context).t('modules:common.utils.open'), [url]);
  }
}

Future<void> openVsCode(BuildContext context, String url) async {
  final vsCodeUri = 'vscode://file/$url';
  return await openLink(context, vsCodeUri);
}

Future<void> openXcode(BuildContext context, String url) async {
  final workspaceUri = '$url/ios/Runner.xcworkspace';
  return await openPath(context, workspaceUri);
}
