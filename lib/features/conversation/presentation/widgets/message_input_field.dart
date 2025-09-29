import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/model/user_model.dart';
import 'package:pictora/core/utils/services/service.dart';
import 'package:pictora/features/conversation/conversation.dart';

class MessageInputField extends StatefulWidget {
  final String? conversationId;
  final String? receiverUserId;
  const MessageInputField({super.key, required this.conversationId, required this.receiverUserId});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  late TextEditingController messageInputController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    messageInputController = TextEditingController();
_focusNode.addListener(_handleFocusChange);
    messageInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    messageInputController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // When text field loses focus
      _emitTypingStop();
    }
  }

  void _emitTypingStart() {
    SocketService().emit("typing_start", {"conversationId": widget.conversationId});
  }

  void _emitTypingStop() {
    SocketService().emit("typing_stop", {"conversationId": widget.conversationId});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: messageInputController,
              onTap: _emitTypingStart,
              onTapOutside: (event) {
                _focusNode.unfocus();
              },
              onEditingComplete: () {
                _emitTypingStop();
              },
              decoration: InputDecoration(
                hintText: "Type a message...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.mic, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {},
                      child: const Icon(Icons.attachment, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (messageInputController.text.isNotEmpty)
            BlocBuilder<ConversationBloc, ConversationState>(
              buildWhen: (previous, current) => previous.conversationsList != current.conversationsList,
              builder: (context, state) {
                final conversationData = (state.conversationsList ?? []).firstWhere(
                  (con) => con.members?[0].userId == widget.receiverUserId,
                  orElse: () => ConversationData(),
                );
                return InkWell(
                  onTap: () {
                    final text = messageInputController.text.trim();
                    if (text.isEmpty) return;
                    conversationBloc.add(CreateMessageEvent(
                      conversationId: widget.conversationId ?? conversationData.id,
                      message: text,
                      receiverId: widget.receiverUserId,
                      senderData: User(
                        userName: userName,
                        id: userId,
                        profile: Profile(
                          profilePicture: userProfilePic,
                        ),
                        fullName: userFullName,
                      ),
                    ));
                    messageInputController.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
