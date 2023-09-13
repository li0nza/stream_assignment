part of stream_weather;

/// Basic caching service used to prevent excessive calls to the weather API.
///
/// Requires an [http.Client]
class CacheService {
  final http.Client _httpClient;

  CacheService(this._httpClient);

  /// Fetches data from either [SharedPreferences] or the API using [http.Client]
  ///
  /// Requires a [Uri] and accepts an optional `ttlInSeconds` which defaults to 60 seconds
  Future<dynamic> fetchData(Uri uri, {int ttlInSeconds = 60}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'api_cache_$uri';
    final String cacheTimestampKey = 'api_cache_timestamp_$uri';

    /// Check if [SharedPreferences] contains keys for the cached uri and the timestamp, if not
    /// skip the cache and fetch data from API
    if (prefs.containsKey(cacheKey) && prefs.containsKey(cacheTimestampKey)) {
      final cachedTimestamp = prefs.getInt(cacheTimestampKey);
      if (cachedTimestamp != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final elapsedTime = currentTime - cachedTimestamp;

        /// if cache is still valid, return the cachedData
        if (elapsedTime <= ttlInSeconds) {
          final cachedData = prefs.getString(cacheKey);
          if (cachedData != null) {
            return json.decode(cachedData);
          }
        }
      }
    }

    try {
      final http.Response response = await _httpClient.get(uri);

      /// 200 means success, proceed as expected else throw [WeatherGenericException]
      if (response.statusCode == 200) {
        dynamic jsonBody = json.decode(response.body);
        /// Cache the response and its timestamp
        prefs.setString(cacheKey, response.body);
        prefs.setInt(cacheTimestampKey, DateTime.now().millisecondsSinceEpoch ~/ 1000);
        return jsonBody;
      }
      throw WeatherGenericException(response.body.toString());
    } catch (error) {
      throw WeatherGenericException(error.toString());
    }
  }
}
