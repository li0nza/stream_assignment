part of stream_weather;

/// Exposes functions to fetch data from the weather API
// TODO: think of a better name for this class, as it's not really a factory
class WeatherDataFactory {
  final String _apiKey;
  final String _baseUrl = 'api.openweathermap.org';

  late http.Client _httpClient;

  WeatherDataFactory(this._apiKey) {
    _httpClient = http.Client();
  }

  /// Allow manually setting the client for testing purposes
  /// TODO: refactor so this is not needed
  setHttpClient(client) {
    _httpClient = client;
  }

  /// Fetch current weather at a location using `latitude` and `longitude``
  ///
  /// `unitOfMeasure` can be specified. defaults to `metric`, `imperial` also accepted.
  ///
  /// Returns a [Weather] object
  ///
  /// API documentation available at: https://openweathermap.org/api/one-call-3#history
  Future<Weather> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude, {
    String unitOfMeasure = 'metric',
  }) async {
    dynamic jsonResponse = await _sendWeatherRequest(
      lat: latitude,
      lon: longitude,
      unitOfMeasure: unitOfMeasure,
    );
    return Weather.fromJson(jsonResponse!);
  }

  /// Fetch current weather at a location using `latitude`, `longitude` and `timeStamp`
  ///
  /// `unitOfMeasure` can be specified. defaults to `metric`, `imperial` also accepted.
  ///
  /// Returns a [Weather] object
  ///
  /// API documentation available at: https://openweathermap.org/api/one-call-3#history
  Future<Weather> getDatedWeatherByCoordinates(
    double latitude,
    double longitude,
    int timeStamp, {
    String unitOfMeasure = 'metric',
  }) async {
    try {
      dynamic jsonResponse = await _sendDatedWeatherRequest(
        lat: latitude,
        lon: longitude,
        timeStamp: timeStamp,
        unitOfMeasure: unitOfMeasure,
      );
      return Weather.fromJson(jsonResponse!);
    } catch (error) {
      throw WeatherGenericException(error.toString());
    }
  }

  /// Fetches a [Location] using a `name` (ie: `Amsterdam`, `Amstelveen` ,`London`)
  ///
  /// Returns a [Location] object
  ///
  /// API documentation available at: https://openweathermap.org/api/geocoding-api
  Future<Location> getLocationByName(String name) async {
    dynamic jsonResponse = await _sendGeoRequest(name: name);
    if (jsonResponse.isEmpty) return const Location(country: 'Unknown', lat: 0, lon: 0, name: 'Unknown');
    return Location.fromJson(jsonResponse![0]);
  }

  /// Fetches a location using `latitude` and `longitude`
  ///
  /// Returns a [Location] object
  ///
  /// API documentation available at: https://openweathermap.org/api/geocoding-api
  Future<Location> getLocationByCoordinates(double lat, double lon) async {
    dynamic jsonResponse = await _sendGeoRequest(lat: lat, lon: lon);
    if (jsonResponse.isEmpty) return const Location(country: 'Unknown', lat: 0, lon: 0, name: 'Unknown');
    return Location.fromJson(jsonResponse![0]);
  }

  /// Helper function to do the API calls to the geo provider
  /// Accepts a `lat` and `lon` or `name`.
  Future<dynamic> _sendGeoRequest({String? name, double? lat, double? lon}) async {
    Uri uri;

    /// if `name` is provided, use the `direct` API endpoint, else use `reverse` with the `lat` and `lon`
    if (name != null) {
      uri = _buildUrl('geo/1.0/direct', {
        'q': name,
        'limit': '1',
        'appid': _apiKey,
      });
    } else {
      uri = _buildUrl('geo/1.0/reverse', {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'limit': '1',
        'appid': _apiKey,
      });
    }

    return _doRequest(uri);
  }

  /// Helper function to do API calls to the weather provider
  /// Requires a `lat` and `lon` and `unitOfMeasure`
  Future<dynamic> _sendWeatherRequest({
    required double lat,
    required double lon,
    required String unitOfMeasure,
  }) async {
    Uri uri = _buildUrl('data/3.0/onecall', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'units': unitOfMeasure,
      'exclude': 'minutely,hourly,daily,alerts',
      'appid': _apiKey,
    });
    return _doRequest(uri);
  }

  /// Helper function to do API calls to the weather provider
  /// Requires a `lat` and `lon`. Requires `timestamp` and `unitOfMeasure`
  Future<dynamic> _sendDatedWeatherRequest({
    required double lat,
    required double lon,
    required int timeStamp,
    required String unitOfMeasure,
  }) async {
    Uri uri = _buildUrl('data/3.0/onecall/timemachine', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'dt': timeStamp.toString(),
      'units': unitOfMeasure,
      'appid': _apiKey,
    });
    return _doRequest(uri);
  }

  /// Generic function to do http calls
  Future<dynamic> _doRequest(Uri uri) async {
    try {
      return await CacheService(_httpClient).fetchData(uri);
    } catch (error) {
      throw WeatherGenericException(error.toString());
    }
  }

  /// Helper function to add URL parameters to the [Uri]
  Uri _buildUrl(String url, Map<String, String> parameters) {
    Uri uri = Uri.http(_baseUrl, url, parameters);
    return uri;
  }
}
