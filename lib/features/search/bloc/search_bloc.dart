import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/enums.dart';
import 'package:pictora/core/utils/services/custom_logger.dart';
import 'package:pictora/data/hiveModel/user_hive_model.dart';
import 'package:pictora/data/hiveModel/user_mapper.dart';
import 'package:pictora/data/repository/repository.dart';
import '../../../core/database/hive_boxes.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/utils/helper/helper_function.dart';
import '../../../core/utils/helper/theme_helper.dart';
import '../../../data/model/user_model.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Repository repository;
  SearchBloc(this.repository) : super(SearchState()) {
    on<SearchUserEvent>(_searchUser, transformer: sequential());
    on<ShowSearchUserList>(_showSearchUser, transformer: sequential());
  }

  Future<void> _searchUser(SearchUserEvent event, Emitter<SearchState> emit) async {
    try {
      if (event.query.isEmpty) {
        emit(state.copyWith(searchUserList: []));
        logDebug(message: "Search is empty");
        final cachedUsers = await getCachedUsers();
        final List<User> userData = cachedUsers.map((u) => u.toEntity()).toList();
        logDebug(message: "user data ${userData.length}");
        emit(state.copyWith(cachedUserList: userData));
        return;
      }
      emit(state.copyWith(searchUserApiStatus: ApiStatus.loading));
      final usersData = await repository.searchUsers({
        "query": event.query,
      });

      emit(state.copyWith(searchUserApiStatus: ApiStatus.success, searchUserList: usersData.data ?? []));
    } catch (error, stackTrace) {
      emit(state.copyWith(searchUserApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void _showSearchUser(ShowSearchUserList event, Emitter<SearchState> emit) {
    emit(state.copyWith(showSearchUser: event.showSearchUser));
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<SearchState> emit) {
    handleError(
      error: error,
      stackTrace: stackTrace,
      emit: emit,
      stateCopyWith: (statusCode, errorMessage) => state.copyWith(
        statusCode: statusCode,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<List<UserHiveModel>> getCachedUsers() async {
    final box = await HiveService.openBox<UserHiveModel>(HiveBoxes.searchUsers);
    return box.values.toList();
  }

  Future<void> clearCache() async {
    await HiveService.clearBox<UserHiveModel>(HiveBoxes.searchUsers);
  }
}
