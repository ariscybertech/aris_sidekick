import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/dto/release.dto.dart';

/// Detail of release or projecct selected
class SelectedDetail {
  /// Constructor
  SelectedDetail({
    this.release,
    this.project,
  });

  /// Release selected
  ReleaseDto release;

  /// Project selected
  Project project;
}

/// Selected Release Provider
final selectedDetailProvider = StateProvider<SelectedDetail>((_) => null);
