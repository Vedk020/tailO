class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  factory LoginState.initial() => LoginState();

  factory LoginState.loading() => LoginState(isLoading: true);

  factory LoginState.error(String message) => LoginState(errorMessage: message);

  factory LoginState.success() => LoginState(isSuccess: true);
}
