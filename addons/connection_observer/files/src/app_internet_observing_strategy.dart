import 'package:http/http.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

import '../../core.dart';

class AppInternetObservingStrategy extends InternetObservingStrategy {
  @override
  Future<bool> get hasInternetConnection async {
    try {
      await get(Uri.parse(AppConstants.internetObservingUrl));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Duration? get initialDuration => AppConstants.internetObservingInterval;

  @override
  Duration get interval => AppConstants.internetObservingInterval;
}
