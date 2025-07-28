part of 'auth_bloc.dart';

@immutable
class AuthEvent {}

class RegisterUserEvent extends AuthEvent {
  final Map<String, dynamic> body;
  RegisterUserEvent({required this.body});
}

class LoginUserEvent extends AuthEvent {
  final Map<String, dynamic> body;
  LoginUserEvent({required this.body});
}
