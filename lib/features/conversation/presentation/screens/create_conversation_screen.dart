import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../conversation.dart';

class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({super.key});

  @override
  State<CreateConversationScreen> createState() => _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  @override
  void initState() {
    super.initState();
    conversationBloc.add(GetUsersListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: CustomText(
          'New Message',
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
        builder: (context, state) {
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: state.usersList?.length ?? 0,
            itemBuilder: (context, index) {
              final User? user = state.usersList?[index];
              return InkWell(
                onTap: () async {},
                child: _buildUserTile(user),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 6);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(User? user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          RoundProfileAvatar(
            imageUrl: user?.profile?.profilePicture ?? '',
            radius: 23,
            userId: user?.id ?? '',
          ),
          SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userName ?? 'guest11',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user?.fullName ?? 'guest',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
