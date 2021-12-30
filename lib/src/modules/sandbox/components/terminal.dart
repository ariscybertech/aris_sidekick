import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fvm/fvm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../components/atoms/typography.dart';
import '../../../modules/common/dto/release.dto.dart';
import '../../../modules/common/utils/notify.dart';
import '../sandbox.provider.dart';

/// Sandbox terminal
class SandboxConsole extends HookWidget {
  /// Constructor
  const SandboxConsole({
    this.project,
    this.release,
    Key key,
  }) : super(key: key);

  /// Project
  final Project project;

  /// Release
  final ReleaseDto release;
  @override
  Widget build(BuildContext context) {
    final terminalState = useProvider(sandboxProvider);
    final terminal = useProvider(sandboxProvider.notifier);

    final textController = useTextEditingController();
    final scrollController = useScrollController();

    final currentCmdIdx = useState(0);

    final focus = useFocusNode();
    final keyListenerFocus = useFocusNode();

    final processing = terminalState.processing;

    void submitCmd(
      String value,
    ) async {
      try {
        /// Don't do anything if its empty
        if (value.isEmpty) return;
        // Reset command index
        currentCmdIdx.value = 0;
        // Add to the beginning of list
        textController.clear();
        await terminal.sendIsolate(
          value,
          release,
          project,
        );
        // Clear controller
        scrollController.jumpTo(0);
      } on Exception catch (e) {
        notifyError(e.toString());
      }
    }

    useEffect(() {
      /// Cannot modify state before render
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await terminal.reboot(release, project);
      });
      return;
    }, [release]);

    // ignore: missing_return
    useEffect(() {
      // Gain back focus
      if (!terminalState.processing) {
        focus.requestFocus();
      }
    }, [processing]);

    void moveCmdIndex(int step) {
      final cmds = terminalState.cmdHistory;
      final currentIdx = currentCmdIdx.value;
      final nextIdx = currentIdx + step;
      // Do not go through commands if its not empty
      // if its not next command and idx is 0
      // Check if it has command history

      if (textController.text.isNotEmpty &&
          textController.text != cmds[currentIdx]) {
        return;
      }

      // Get command from history
      final cmd = cmds[nextIdx];

      textController.text = cmd;

      // Set next index
      currentCmdIdx.value = nextIdx;

      // Trigger cursor move post frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        textController.selection = TextSelection.collapsed(
          offset: textController.text.length,
        );
      });
    }

    void handleKey(RawKeyEvent key) {
      if (key.runtimeType.toString() == 'RawKeyDownEvent') {
        if (key.data.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (terminalState.cmdHistory.length > currentCmdIdx.value) {
            moveCmdIndex(1);
          }
        }
        if (key.data.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (currentCmdIdx.value > 0) {
            moveCmdIndex(-1);
          }
        }
      }
    }

    return Column(
      children: [
        Expanded(
          child: CupertinoScrollbar(
            child: ListView.builder(
              controller: scrollController,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              itemCount: terminalState.lines.length,
              itemBuilder: (context, index) {
                final line = terminalState.lines[index];
                switch (line.type) {
                  case OutputType.stderr:
                    return ConsoleTextError(line.text);
                  case OutputType.info:
                    return ConsoleTextInfo(line.text);
                  case OutputType.stdout:
                    return ConsoleText(line.text);
                  default:
                    return Container();
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: RawKeyboardListener(
                  focusNode: keyListenerFocus,
                  onKey: handleKey,
                  child: TextField(
                    focusNode: focus,
                    enabled: !terminalState.processing,
                    controller: textController,
                    onSubmitted: submitCmd,
                    decoration: const InputDecoration(
                      icon: Icon(MdiIcons.chevronRight),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              terminalState.processing
                  ? SpinKitFadingFour(
                      color: Theme.of(context).colorScheme.secondary,
                      size: 15,
                    )
                  : Container()
            ],
          ),
        ),
      ],
    );
  }
}
