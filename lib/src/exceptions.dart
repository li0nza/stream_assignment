part of stream_weather;

/// Generic exception used to throw errors in the package
class WeatherGenericException implements Exception {
  final String _error;

  WeatherGenericException(this._error);

  @override
  String toString() => _error;
}
