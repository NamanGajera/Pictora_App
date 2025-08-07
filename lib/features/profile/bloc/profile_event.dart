part of 'profile_bloc.dart';

class ProfileEvent {}

class GetUserDataEvent extends ProfileEvent {
  final String? userId;
  GetUserDataEvent({this.userId});
}
