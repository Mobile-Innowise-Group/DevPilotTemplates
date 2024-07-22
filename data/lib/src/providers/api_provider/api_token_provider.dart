import 'package:data/data.dart';

class ApiTokenProvider {
  final LocalDataProvider _localDataProvider;

  ApiTokenProvider({
    required LocalDataProvider localDataProvider,
  }) : _localDataProvider = localDataProvider;

  Future<String?> readAccessToken() async {
    return _localDataProvider.read(StorageConstants.accessTokenKey);
  }

  Future<void> writeAccessToken(String token) async {
    await _localDataProvider.write(
      key: StorageConstants.accessTokenKey,
      value: token,
    );
  }

  Future<String?> readRefreshToken() async {
    return _localDataProvider.read(StorageConstants.refreshTokenKey);
  }

  Future<void> writeRefreshToken(String token) async {
    await _localDataProvider.write(
      key: StorageConstants.refreshTokenKey,
      value: token,
    );
  }
}
