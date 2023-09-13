import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_weather/stream_weather.dart';
import 'package:http/http.dart' as http;

void main() {
  group('WeatherDataFactory', () {
    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
    });

    test('getCurrentWeatherByCoordinates returns a Weather object from cache', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "lat": 52.2435,
          "lon": 5.6343,
          "timezone": "Europe/Amsterdam",
          "timezone_offset": 7200,
          "current": {
              "dt": 1694604292,
              "sunrise": 1694581676,
              "sunset": 1694627968,
              "temp": 17.85,
              "feels_like": 17.88,
              "pressure": 1019,
              "humidity": 84,
              "dew_point": 15.11,
              "uvi": 3.64,
              "clouds": 95,
              "visibility": 10000,
              "wind_speed": 0.89,
              "wind_deg": 244,
              "wind_gust": 1.34,
              "weather": [
                  {
                      "id": 804,
                      "main": "Clouds",
                      "description": "overcast clouds",
                      "icon": "04d"
                  }
              ]
          }
      }''', 200);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      SharedPreferences.setMockInitialValues({
        'api_cache_timestamp_http://api.openweathermap.org/data/3.0/onecall?lat=52.0&lon=4.0&units=metric&exclude=minutely%2Chourly%2Cdaily%2Calerts&appid=fake_api_key':
            1694601475,
        'api_cache_http://api.openweathermap.org/data/3.0/onecall?lat=52.0&lon=4.0&units=metric&exclude=minutely%2Chourly%2Cdaily%2Calerts&appid=fake_api_key':
            '{"lat": 52.2435,"lon": 5.6343,"timezone": "Europe/Amsterdam","timezone_offset": 7200,"current": {"dt": 1694604292,"sunrise": 1694581676,"sunset": 1694627968,"temp": 17.85,"feels_like": 17.88,"pressure": 1019,"humidity": 84,"dew_point": 15.11,"uvi": 3.64,"clouds": 95,"visibility": 10000,"wind_speed": 0.89,"wind_deg": 244,"wind_gust": 1.34,"weather": [{"id": 804,"main": "Clouds","description": "overcast clouds","icon": "04d"}]}}',
      });
      dataFactory.setHttpClient(mockClient);
      final weather = await dataFactory.getCurrentWeatherByCoordinates(52.2434979, 5.6343227);
      const tWeather = Weather(lat: 52.2435, lon: 5.6343, timezone: "Europe/Amsterdam", timezoneOffset: 7200, data: [
        Datum(
            dt: 1694604292,
            sunrise: 1694581676,
            sunset: 1694627968,
            temp: 17.85,
            feelsLike: 17.88,
            pressure: 1019,
            humidity: 84,
            dewPoint: 15.11,
            uvi: 3.64,
            clouds: 95,
            visibility: 10000,
            windSpeed: 0.89,
            windDeg: 244,
            weather: [
              WeatherElement(
                id: 804,
                main: "Clouds",
                description: "overcast clouds",
                icon: "04d",
              ),
            ])
      ]);
      expect(weather, equals(tWeather));
    });

    test('getCurrentWeatherByCoordinates returns a Weather object from the API', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "lat": 52.2435,
          "lon": 5.6343,
          "timezone": "Europe/Amsterdam",
          "timezone_offset": 7200,
          "current": {
              "dt": 1694604292,
              "sunrise": 1694581676,
              "sunset": 1694627968,
              "temp": 17.85,
              "feels_like": 17.88,
              "pressure": 1019,
              "humidity": 84,
              "dew_point": 15.11,
              "uvi": 3.64,
              "clouds": 95,
              "visibility": 10000,
              "wind_speed": 0.89,
              "wind_deg": 244,
              "wind_gust": 1.34,
              "weather": [
                  {
                      "id": 804,
                      "main": "Clouds",
                      "description": "overcast clouds",
                      "icon": "04d"
                  }
              ]
          }
      }''', 200);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      final weather = await dataFactory.getCurrentWeatherByCoordinates(52.2434979, 5.6343227);
      const tWeather = Weather(lat: 52.2435, lon: 5.6343, timezone: "Europe/Amsterdam", timezoneOffset: 7200, data: [
        Datum(
            dt: 1694604292,
            sunrise: 1694581676,
            sunset: 1694627968,
            temp: 17.85,
            feelsLike: 17.88,
            pressure: 1019,
            humidity: 84,
            dewPoint: 15.11,
            uvi: 3.64,
            clouds: 95,
            visibility: 10000,
            windSpeed: 0.89,
            windDeg: 244,
            weather: [
              WeatherElement(
                id: 804,
                main: "Clouds",
                description: "overcast clouds",
                icon: "04d",
              ),
            ])
      ]);
      expect(weather, equals(tWeather));
    });

    test('getDatedWeatherByCoordinates encounters a failure from the API', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "cod": 401,
          "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
        }''', 401);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      try {
        // This should throw a WeatherGenericException
        await dataFactory.getDatedWeatherByCoordinates(52.2434979, 5.6343227, 1631414400);
        // If no exception is thrown, fail the test
        fail('Expected WeatherGenericException but got none.');
      } catch (error) {
        expect(error, isA<WeatherGenericException>());
      }
    });

    test('getCurrentWeatherByCoordinates encounters a failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "cod": 401,
          "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
        }''', 401);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      dataFactory.setHttpClient(mockClient);
      try {
        // This should throw a WeatherGenericException
        await dataFactory.getCurrentWeatherByCoordinates(52.2434979, 5.6343227);
        // If no exception is thrown, fail the test
        fail('Expected WeatherGenericException but got none.');
      } catch (error) {
        expect(error, isA<WeatherGenericException>());
      }
    });

    test('getDatedWeatherByCoordinates returns a Weather object', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
            "lat": 52.2435,
            "lon": 5.6343,
            "timezone": "Europe/Amsterdam",
            "timezone_offset": 7200,
            "data": [
                {
                    "dt": 1631414400,
                    "sunrise": 1631423228,
                    "sunset": 1631469637,
                    "temp": 14.67,
                    "feels_like": 14.65,
                    "pressure": 1017,
                    "humidity": 94,
                    "dew_point": 13.72,
                    "clouds": 72,
                    "wind_speed": 3.38,
                    "wind_deg": 226,
                    "weather": [
                        {
                            "id": 803,
                            "main": "Clouds",
                            "description": "broken clouds",
                            "icon": "04n"
                        }
                    ]
                }
            ]}''', 200);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      final weather = await dataFactory.getDatedWeatherByCoordinates(52.2434979, 5.6343227, 1631414400);
      const tWeather = Weather(lat: 52.2435, lon: 5.6343, timezone: "Europe/Amsterdam", timezoneOffset: 7200, data: [
        Datum(
            dt: 1631414400,
            sunrise: 1631423228,
            sunset: 1631469637,
            temp: 14.67,
            feelsLike: 14.65,
            pressure: 1017,
            humidity: 94,
            dewPoint: 13.72,
            clouds: 72,
            windSpeed: 3.38,
            windDeg: 226,
            weather: [
              WeatherElement(
                id: 803,
                main: "Clouds",
                description: "broken clouds",
                icon: "04n",
              )
            ])
      ]);
      expect(weather, equals(tWeather));
    });

    test('getDatedWeatherByCoordinates encounters a failure from the API', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "cod": 401,
          "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
        }''', 401);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      try {
        // This should throw a WeatherGenericException
        await dataFactory.getDatedWeatherByCoordinates(52.2434979, 5.6343227, 1631414400);
        // If no exception is thrown, fail the test
        fail('Expected WeatherGenericException but got none.');
      } catch (error) {
        expect(error, isA<WeatherGenericException>());
      }
    });

    test('getLocationByName returns Location object', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''[{
        "name": "Amsterdam",
        "lat": 52.3727598,
        "lon": 4.8936041,
        "country": "NL",
        "state": "North Holland"
        }]''', 200);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      final location = await dataFactory.getLocationByName('Amsterdam');
      const tLocation = Location(
        name: "Amsterdam",
        lat: 52.3727598,
        lon: 4.8936041,
        country: "NL",
      );
      expect(location, equals(tLocation));
    });

    test('getLocationByName encounters a failure from the API', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "cod": 401,
          "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
        }''', 401);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      try {
        // This should throw a WeatherGenericException
        await dataFactory.getLocationByName('Amsterdam');
        // If no exception is thrown, fail the test
        fail('Expected WeatherGenericException but got none.');
      } catch (error) {
        expect(error, isA<WeatherGenericException>());
      }
    });

    test('getLocationByCoordinates returns Location object', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''[{
        "name": "Amsterdam",
        "lat": 52.3727598,
        "lon": 4.8936041,
        "country": "NL",
        "state": "North Holland"
        }]''', 200);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      final location = await dataFactory.getLocationByCoordinates(52.3727598, 4.8936041);

      const tLocation = Location(
        name: "Amsterdam",
        lat: 52.3727598,
        lon: 4.8936041,
        country: "NL",
      );
      expect(location, equals(tLocation));
    });

    test('getLocationByCoordinates encounters a failure from the API', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "cod": 401,
          "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
        }''', 401);
      });

      final dataFactory = WeatherDataFactory('fake_api_key');
      dataFactory.setHttpClient(mockClient);
      try {
        // This should throw a WeatherGenericException
        await dataFactory.getLocationByCoordinates(52.3727598, 4.8936041);
        // If no exception is thrown, fail the test
        fail('Expected WeatherGenericException but got none.');
      } catch (error) {
        expect(error, isA<WeatherGenericException>());
      }
    });
  });

  group('Exceptions', () {
    test('WeatherGenericException toString returns error message', () {
      final exception = WeatherGenericException('Test error message');
      expect(exception.toString(), 'Test error message');
    });
  });
}
