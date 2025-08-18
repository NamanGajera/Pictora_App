import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/helper/custom_exception.dart';
import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../constants/constants.dart';
import '../constants/shared_pref_keys.dart';
import '../services/custom_logger.dart';
import 'shared_prefs_helper.dart';
import 'theme_helper.dart';

String formattedCount(int count) {
  return count > 1000 ? '${(count / 1000).toStringAsFixed(1)}K' : '$count';
}

void handleError<State>({
  required dynamic error,
  required dynamic stackTrace,
  required Emitter<State> emit,
  required State Function(int statusCode, String errorMessage) stateCopyWith,
}) {
  logError(message: 'Error => ${error.toString()} StackTrace=>> $stackTrace');

  final statusCode = _determineStatusCode(error);
  final message = error.toString();

  if (statusCode == 401) {
    if (!hasLogout) {
      hasLogout = true;
      logoutUser();
      ThemeHelper.showToastMessage(message);
    }
    return;
  }

  emit(stateCopyWith(statusCode, message));
}

int _determineStatusCode(dynamic error) {
  if (error is FetchDataException) return 500;
  if (error is UnAuthorizedException) return 401;
  if (error is DoesNotExistException) return 404;
  if (error is ServerValidationError) return 400;
  return 500;
}

void logoutUser() {
  appRouter.go(RouterName.login.path);

  SharedPrefsHelper().clear();

  accessToken = null;
}

Future<void> getUserData() async {
  userId = SharedPrefsHelper().getString(SharedPrefKeys.userId);
  userEmail = SharedPrefsHelper().getString(SharedPrefKeys.userEmail);
  userFullName = SharedPrefsHelper().getString(SharedPrefKeys.userFullName);
  userName = SharedPrefsHelper().getString(SharedPrefKeys.userName);
}
