class ApiRequestOptions {
  final bool useDefaultAuth;
  final bool useErrorHandler;

  const ApiRequestOptions({
    this.useDefaultAuth = true,
    this.useErrorHandler = true,
  });
}
