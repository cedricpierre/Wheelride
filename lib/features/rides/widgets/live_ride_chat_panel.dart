import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/surface_panel.dart';

class LiveRideChatPanel extends ConsumerStatefulWidget {
  const LiveRideChatPanel({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  ConsumerState<LiveRideChatPanel> createState() => _LiveRideChatPanelState();
}

class _LiveRideChatPanelState extends ConsumerState<LiveRideChatPanel> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    await ref.read(wheelRideControllerProvider.notifier).sendMessage(_message.text);
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);

    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(20),
                  children: const [
                    Text(
                      'Aucun historique. Les nouveaux messages apparaissent ici en direct.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.userId == state.user?.id;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color:
                              isMe ? AppTheme.neon : AppTheme.bubbleOther,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'Vous' : message.userName,
                              style: TextStyle(
                                color: isMe ? Colors.black87 : AppTheme.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat.Hm().format(message.createdAt),
                              style: TextStyle(
                                color: isMe ? Colors.black54 : AppTheme.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SurfacePanel(
                  borderRadius: 22,
                  child: TextField(
                    key: const Key('chat-message'),
                    controller: _message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.neon,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    AppIcons.send,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
