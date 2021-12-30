import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../common/dto/release.dto.dart';

/// Cache date
class CacheDateDisplay extends HookWidget {
  /// Constructor
  const CacheDateDisplay(this.release, {Key key}) : super(key: key);

  /// Release
  final ReleaseDto release;
  @override
  Widget build(BuildContext context) {
    final cacheDirStat = useState<FileStat>(null);

    void setCacheDir() async {
      if (release != null && release.isCached == true) {
        cacheDirStat.value = await release.cache.dir.stat();
      }
    }

    useEffect(() {
      setCacheDir();
      return;
    }, [release]);

    if (cacheDirStat.value == null) {
      return const SizedBox(height: 0);
    }

    return Text(DateTimeFormat.format(
      cacheDirStat.value.changed,
      format: AmericanDateFormats.abbr,
    ));
  }
}
