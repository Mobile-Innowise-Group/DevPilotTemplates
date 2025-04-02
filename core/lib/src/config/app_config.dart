enum Flavor {
  dev,
}

class AppConfig {
  final Flavor flavor;
  final String httpBaseUrl;
  final String webSocketBaseUrl;

  AppConfig({
    required this.flavor,
    required this.httpBaseUrl,
    required this.webSocketBaseUrl,
  });

  factory AppConfig.fromFlavor(Flavor flavor) {
    String httpBaseUrl;
    String webSocketBaseUrl;

    switch (flavor) {
      case Flavor.dev:
        httpBaseUrl = '';
        webSocketBaseUrl = '';
        break;
    }

    return AppConfig(
      flavor: flavor,
      httpBaseUrl: httpBaseUrl,
      webSocketBaseUrl: webSocketBaseUrl,
    );
  }
}
