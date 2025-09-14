// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/config/router.dart';
import '../../../../core/utils/services/service.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../conversation.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    conversationBloc.add(GetConversationsEvent());
    SocketService().eventManager.eventStream('user_presence').listen(_userPresence);
    SocketService().eventManager.eventStream('user_typing').listen(_userPresence);
    logDebug(message: "Socket ID: ${SocketService().id}", tag: "Socket Service");
  }

  void _userPresence(dynamic data) {
    logDebug(message: "User Presence Data: $data", tag: "Socket Event");
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: CustomText(
          '$userName',
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => appRouter.pop(),
        ),
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        buildWhen: (previous, current) => previous.getConversationsDataApiStatus != current.getConversationsDataApiStatus,
        builder: (context, state) {
          if ((state.conversationsList ?? []).isEmpty) {
            return Center(
              child: CustomText(
                "No data found",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            );
          }
          return Column(
            children: [
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Search...",
                prefixIcon: Icons.search,
                controller: _searchController,
                constraints: const BoxConstraints(maxHeight: 42, minHeight: 42),
                contentPadding: EdgeInsets.zero,
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: (state.conversationsList ?? []).length,
                  itemBuilder: (context, index) {
                    final conversationData = state.conversationsList?[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoundProfileAvatar(
                          radius: 25,
                          userId: '',
                          imageUrl: conversationData?.otherUser?[0].userData?.profile?.profilePicture ?? '',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              CustomText(
                                conversationData?.otherUser?[0].userData?.fullName ?? '',
                                fontSize: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ).withPadding(const EdgeInsets.symmetric(horizontal: 10)),
    );
  }
}
