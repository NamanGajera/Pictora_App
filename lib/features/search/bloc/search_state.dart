part of 'search_bloc.dart';

class SearchState extends Equatable {
  final ApiStatus searchUserApiStatus;
  final List<User>? searchUserList;
  final List<User>? cachedUserList;
  final bool showSearchUser;
  final String? errorMessage;
  final int? statusCode;

  const SearchState({
    this.searchUserApiStatus = ApiStatus.initial,
    this.searchUserList,
    this.cachedUserList,
    this.showSearchUser = false,
    this.statusCode,
    this.errorMessage,
  });

  SearchState copyWith({
    ApiStatus? searchUserApiStatus,
    List<User>? searchUserList,
    List<User>? cachedUserList,
    bool? showSearchUser,
    String? errorMessage,
    int? statusCode,
  }) {
    return SearchState(
      searchUserApiStatus: searchUserApiStatus ?? this.searchUserApiStatus,
      searchUserList: searchUserList ?? this.searchUserList,
      showSearchUser: showSearchUser ?? this.showSearchUser,
      cachedUserList: cachedUserList ?? this.cachedUserList,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        searchUserApiStatus,
        searchUserList,
        showSearchUser,
        cachedUserList,
        errorMessage,
        statusCode,
      ];
}
