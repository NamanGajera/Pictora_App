// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/utils/model/user_model.dart';
import '../../bloc/follow_section_bloc/follow_section_bloc.dart';
import 'discover_user_card.dart';

class DiscoverUserView extends StatelessWidget {
  const DiscoverUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowSectionBloc, FollowSectionState>(
      buildWhen: (previous, current) =>
          previous.showDiscoverUserOnProfile != current.showDiscoverUserOnProfile || previous.discoverUsers != current.discoverUsers,
      builder: (context, state) {
        final users = state.discoverUsers ?? [];

        if (users.isNotEmpty && state.showDiscoverUserOnProfile) {
          return SizedBox(
            height: 242,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(top: 12, bottom: 12, left: 10),
              itemCount: ((users.take(5)).length) + (users.length > 5 ? 1 : 0),
              itemBuilder: (context, index) {
                List<User> randomProfiles = [];
                if (index == 5 && users.length > 2) {
                  List<User> availableUsers = List.from(users);

                  availableUsers.shuffle();

                  randomProfiles = availableUsers.take(2).map((user) => user).toList();
                }

                final user = users[index];
                return DiscoverUserCard(
                  key: ValueKey("discover_${user.id}"),
                  user: user,
                  isLast: index == 5,
                  randomTwoUsers: randomProfiles,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 10),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
