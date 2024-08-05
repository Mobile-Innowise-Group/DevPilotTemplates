import 'package:core/src/services/app_internet_observing_strategy.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

abstract class NetworkService {
  static final InternetConnectivity _instance = InternetConnectivity(
    internetObservingStrategy: AppInternetObservingStrategy(),
  );

  static Future<bool> get hasConnection => _instance.hasInternetConnection;

  static Stream<bool> get observeConnection => _instance.observeInternetConnection;
}
