/// Normalizes a deployment base path so it starts and ends with a slash.
String normalizeBasePath(String value) {
  var basePath = value.trim();
  if (basePath.isEmpty || basePath == '/') {
    return '/';
  }

  if (!basePath.startsWith('/')) {
    basePath = '/$basePath';
  }

  if (!basePath.endsWith('/')) {
    basePath = '$basePath/';
  }

  return basePath;
}

/// Builds a documentation route relative to [basePath].
String docsRoute(String basePath, String route) {
  final normalizedBasePath = normalizeBasePath(basePath);

  if (route.isEmpty || route == '/') {
    return normalizedBasePath;
  }

  final normalizedRoute = route.startsWith('/') ? route.substring(1) : route;
  return '$normalizedBasePath$normalizedRoute';
}
