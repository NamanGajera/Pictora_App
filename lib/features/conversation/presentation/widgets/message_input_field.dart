import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/app_constants.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/constants/colors.dart';
import 'package:pictora/core/utils/model/user_model.dart';
import 'package:pictora/features/conversation/bloc/conversation_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    messageInputController = TextEditingController();

    messageInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    messageInputController.dispose();
    super.dispose();
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
