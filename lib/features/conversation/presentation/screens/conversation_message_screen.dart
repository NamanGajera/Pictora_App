import 'package:flutter/material.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/extensions/widget_extension.dart';
import 'package:pictora/features/conversation/presentation/widgets/message_input_field.dart';
import 'package:pictora/features/conversation/presentation/widgets/message_screen_app_bar.dart';
import 'package:pictora/features/conversation/presentation/widgets/messages_view.dart';

import '../../../../core/utils/services/service.dart';
import '../../conversation.dart';

class ConversationMessageScreen extends StatefulWidget {
  final ConversationData? conversationData;
  const ConversationMessageScreen({
    super.key,
    required this.conversationData,
  });

  @override
  State<ConversationMessageScreen> createState() => _ConversationMessageScreenState();
}

class _ConversationMessageScreenState extends State<ConversationMessageScreen> {
  @override
  void initState() {
    super.initState();
    SocketService().emit("join_conversation", {"conversationId": widget.conversationData?.id});
    conversationBloc.add(GetConversationMessagesEvent(body: {
      "conversationId": widget.conversationData?.id,
      "skip": 0,
      "take": 40,
    }));
  }

  @override
  void dispose() {
    super.dispose();
    logDebug(message: "Dispose Called ==>>>");
    SocketService().emit("leave_conversation", {"conversationId": widget.conversationData?.id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MessageScreenAppBar(conversationData: widget.conversationData),
      bottomSheet: MessageInputField(
        conversationId: widget.conversationData?.id,
      ),
      body: MessagesView(
        conversationData: widget.conversationData,
      ).withPadding(const EdgeInsets.only(bottom: 50)),
    );
  }
}

class ConversationMessageScreenDataModel {
  final ConversationData? conversationData;
  const ConversationMessageScreenDataModel({
    required this.conversationData,
  });
}
