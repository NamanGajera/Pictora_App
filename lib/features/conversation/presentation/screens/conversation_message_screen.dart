import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/router.dart';
import '../../../../core/utils/services/service.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
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
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                RoundProfileAvatar(
                  radius: 18,
                  userId: '',
                  imageUrl: widget.conversationData?.otherUser?[0].userData?.profile?.profilePicture ?? '',
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<ConversationBloc, ConversationState>(
                    buildWhen: (previous, current) => previous.onlineUserIds != current.onlineUserIds,
                    builder: (context, state) {
                      final bool isOnline = (state.onlineUserIds ?? []).contains(widget.conversationData?.otherUser?[0].userId);
                      if(!isOnline){
                        return SizedBox.shrink();
                      }
                      return Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: const Color(0XFF3EB838),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CustomText(
              widget.conversationData?.title ?? widget.conversationData?.otherUser?[0].userData?.fullName ?? '',
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 18,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => appRouter.pop(),
        ),
      ),
    );
  }
}

class ConversationMessageScreenDataModel {
  final ConversationData? conversationData;
  const ConversationMessageScreenDataModel({
    required this.conversationData,
  });
}
