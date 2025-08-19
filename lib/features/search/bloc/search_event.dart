part of 'search_bloc.dart';

class SearchEvent {}

class SearchUserEvent extends SearchEvent {
  final String query;
  SearchUserEvent({required this.query});
}

class ShowSearchUserList extends SearchEvent {
  final bool showSearchUser;
  ShowSearchUserList({required this.showSearchUser});
}
