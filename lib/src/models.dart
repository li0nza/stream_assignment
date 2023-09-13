part of stream_weather;

class Weather extends Equatable {
  final double lat;
  final double lon;
  final String timezone;
  final int timezoneOffset;
  final List<Datum> data;

  const Weather({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneOffset,
    required this.data,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
        timezone: json["timezone"],
        timezoneOffset: json["timezone_offset"],
        /// this is definitely not ideal, but the API returns the same data
        /// in a different structure depending on the endpoint
        data: json["data"] == null
            ? List<Datum>.from([Datum.fromJson(json["current"])])
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  @override
  List<Object?> get props => [lat, lon, timezone, timezoneOffset, data];
}

class Datum extends Equatable {
  final int dt;
  final int sunrise;
  final int sunset;
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double dewPoint;
  final double? uvi;
  final int clouds;
  final int? visibility;
  final double windSpeed;
  final int windDeg;
  final List<WeatherElement> weather;

  const Datum({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    this.uvi,
    required this.clouds,
    this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        dt: json["dt"],
        sunrise: json["sunrise"],
        sunset: json["sunset"],
        temp: json["temp"]?.toDouble(),
        feelsLike: json["feels_like"]?.toDouble(),
        pressure: json["pressure"],
        humidity: json["humidity"],
        dewPoint: json["dew_point"]?.toDouble(),
        uvi: json["uvi"]?.toDouble(),
        clouds: json["clouds"],
        visibility: json["visibility"],
        windSpeed: json["wind_speed"]?.toDouble(),
        windDeg: json["wind_deg"],
        weather: List<WeatherElement>.from(json["weather"].map((x) => WeatherElement.fromJson(x))),
      );

  @override
  List<Object?> get props => [
        dt,
        sunrise,
        sunset,
        temp,
        feelsLike,
        pressure,
        humidity,
        dewPoint,
        uvi,
        clouds,
        visibility,
        windSpeed,
        windDeg,
        weather,
      ];
}

class WeatherElement extends Equatable {
  final int id;
  final String main;
  final String description;
  final String icon;

  const WeatherElement({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherElement.fromJson(Map<String, dynamic> json) => WeatherElement(
        id: json["id"],
        main: json["main"],
        description: json["description"],
        icon: json["icon"],
      );

  @override
  List<Object?> get props => [id, main, description, icon];
}

class Location extends Equatable {
  final String name;
  final double lat;
  final double lon;
  final String country;

  const Location({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json["name"],
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
        country: json["country"],
      );

  @override
  List<Object?> get props => [name, lat, lon, country];
}
