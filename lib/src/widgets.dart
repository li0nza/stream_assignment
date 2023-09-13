part of stream_weather;

/// Base class used for our other widgets, requires a [WeatherDataFactory], `unitOfMeasure`,
/// `fetchWeatherData` function and optional `isCurrent` boolean to know when to display refresh button
class WeatherDataWidget extends StatefulWidget {
  final WeatherDataFactory dataFactory;
  final String unitOfMeasure;
  final Future<Weather> Function() fetchWeatherData;
  final bool isCurrent;

  const WeatherDataWidget({
    Key? key,
    required this.dataFactory,
    required this.unitOfMeasure,
    required this.fetchWeatherData,
    this.isCurrent = false,
  }) : super(key: key);

  @override
  State<WeatherDataWidget> createState() => _WeatherDataWidgetState();

  /// Method to check if the widget's properties have changed
  bool propertiesChanged(WeatherDataWidget oldWidget) {
    return false;
  }
}

class _WeatherDataWidgetState extends State<WeatherDataWidget> {
  late Weather _weather;
  late Location _location;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  @override
  void didUpdateWidget(WeatherDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.propertiesChanged(oldWidget) || _error) {
      setState(() {
        _loading = true;
      });
      _updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _loadingWidget();
    }
    if (_error) {
      return _errorWidget();
    }

    return _WeatherCard(
      context,
      _weather,
      _location,
      widget.unitOfMeasure,
      updateData: _updateData,
      isCurrent: widget.isCurrent
    );
  }

  Future<void> _updateData() async {
    try {
      final weatherData = await widget.fetchWeatherData();
      _weather = weatherData;
      _location = await widget.dataFactory.getLocationByCoordinates(
        weatherData.lat,
        weatherData.lon,
      );
      setState(() {
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }
}

/// Widget to display the current weather using coordinates
///
/// Requires `lat` and `lon`
class CurrentWeatherByCoordinates extends WeatherDataWidget {
  final double lat;
  final double lon;

  CurrentWeatherByCoordinates({
    super.key,
    required WeatherDataFactory dataFactory,
    required this.lat,
    required this.lon,
    required String unitOfMeasure,
  }) : super(
          dataFactory: dataFactory,
          unitOfMeasure: unitOfMeasure,
          fetchWeatherData: () => dataFactory.getCurrentWeatherByCoordinates(lat, lon, unitOfMeasure: unitOfMeasure),
          isCurrent: true,
        );

  @override
  bool propertiesChanged(WeatherDataWidget oldWidget) {
    /// check `lat`, `lon` and `unitOfMeasure` to see if state updated and new data needs to be fetched.
    if (oldWidget is CurrentWeatherByCoordinates) {
      return lat != oldWidget.lat || lon != oldWidget.lon || unitOfMeasure != oldWidget.unitOfMeasure;
    }
    return false;
  }
}

/// Widget to display the current weather using a name
///
/// Requires `name`
class CurrentWeatherByName extends WeatherDataWidget {
  final String name;

  CurrentWeatherByName({
    super.key,
    required WeatherDataFactory dataFactory,
    required this.name,
    required String unitOfMeasure,
  }) : super(
          dataFactory: dataFactory,
          unitOfMeasure: unitOfMeasure,
          fetchWeatherData: () => _fetchCurrentWeatherByName(dataFactory, name, unitOfMeasure),
          isCurrent: true,
        );

  @override
  bool propertiesChanged(WeatherDataWidget oldWidget) {
    /// check `name` and `unitOfMeasure` to see if state updated and new data needs to be fetched.
    if (oldWidget is CurrentWeatherByName) {
      return name != oldWidget.name || unitOfMeasure != oldWidget.unitOfMeasure;
    }
    return false;
  }

  static Future<Weather> _fetchCurrentWeatherByName(
      WeatherDataFactory dataFactory, String name, String unitOfMeasure) async {
    final location = await dataFactory.getLocationByName(name);
    return await dataFactory.getCurrentWeatherByCoordinates(location.lat, location.lon, unitOfMeasure: unitOfMeasure);
  }
}

/// Widget to display weather using coordinates for a given datetime
///
/// Requires `lat` and `lon` and `timeStamp`
class DatedWeatherByCoordinates extends WeatherDataWidget {
  final double lat;
  final double lon;
  final int timeStamp;

  DatedWeatherByCoordinates({
    super.key,
    required WeatherDataFactory dataFactory,
    required this.lat,
    required this.lon,
    required this.timeStamp,
    required String unitOfMeasure,
  }) : super(
          dataFactory: dataFactory,
          unitOfMeasure: unitOfMeasure,
          fetchWeatherData: () => dataFactory.getDatedWeatherByCoordinates(lat, lon, (timeStamp / 1000).floor(),
              unitOfMeasure: unitOfMeasure),
        );

  @override
  bool propertiesChanged(WeatherDataWidget oldWidget) {
    /// check `lat`, `lon`, `timeStamp` and `unitOfMeasure` to see if state updated and new data needs to be fetched.
    if (oldWidget is DatedWeatherByCoordinates) {
      return lat != oldWidget.lat || lon != oldWidget.lon || timeStamp != oldWidget.timeStamp || unitOfMeasure != oldWidget.unitOfMeasure;
    }
    return false;
  }
}

/// Widget to display the weather using a name for a given datetime
///
/// Requires `name` and `timeStamp`
class DatedWeatherByName extends WeatherDataWidget {
  final String name;
  final int timeStamp;

  DatedWeatherByName({super.key,
    required WeatherDataFactory dataFactory,
    required this.name,
    required this.timeStamp,
    required String unitOfMeasure,
  }) : super(
          dataFactory: dataFactory,
          unitOfMeasure: unitOfMeasure,
          fetchWeatherData: () => _fetchDatedWeatherByName(dataFactory, name, timeStamp, unitOfMeasure),
        );

  @override
  /// Chec
  bool propertiesChanged(WeatherDataWidget oldWidget) {
    /// check `name`, `timeStamp` and `unitOfMeasure` to see if state updated and new data needs to be fetched.
    if (oldWidget is DatedWeatherByName) {
      return name != oldWidget.name || timeStamp != oldWidget.timeStamp || unitOfMeasure != oldWidget.unitOfMeasure;
    }
    return false;
  }

  static Future<Weather> _fetchDatedWeatherByName(
      WeatherDataFactory dataFactory, String name, int timeStamp, String unitOfMeasure) async {
    final location = await dataFactory.getLocationByName(name);
    return await dataFactory.getDatedWeatherByCoordinates(location.lat, location.lon, (timeStamp / 1000).floor(),
        unitOfMeasure: unitOfMeasure);
  }
}

/// Basic loading widget
Widget _loadingWidget() {
  return const Card(
    margin: EdgeInsets.all(12),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          CircularProgressIndicator(),
          Text('Loading...'),
        ],
      ),
    ),
  );
}

/// Basic error widget
Widget _errorWidget() {
  return const Card(
    margin: EdgeInsets.all(12),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(
            Icons.error,
            size: 40,
          ),
          Text('Something went wrong...'),
        ],
      ),
    ),
  );
}

/// Standardised weather card used to display the data for the two weather widgets
///
/// Requires `context`, [Weather], [Location], `unitOfMeasure`.
///
/// Optional `updateData` and `isCurrent`
class _WeatherCard extends StatelessWidget {
  final BuildContext context;
  final Weather weather;
  final Location location;
  final String unitOfMeasure;
  final Future<void> Function()? updateData;
  final bool isCurrent;

  const _WeatherCard(this.context, this.weather, this.location, this.unitOfMeasure, {this.updateData, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    Datum data = weather.data[0];
    WeatherElement weatherData = data.weather[0];
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Latitude: ",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(weather.lat.toStringAsFixed(2)),
                    const Text(" | "),
                    Text(
                      "Longitude: ",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(weather.lon.toStringAsFixed(2)),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    location.name,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        "${data.temp.toStringAsFixed(1)}${_getUnitOfMeasureSymbol(unitOfMeasure)}",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${weatherData.icon}@4x.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
                Text(weatherData.main),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Feels like "),
                    Text(
                      "${data.feelsLike}${_getUnitOfMeasureSymbol(unitOfMeasure)}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _getDateTimeText(data.dt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
            if (isCurrent)
              Positioned(
                  right: 0, top: -4, child: IconButton(onPressed: () => updateData!(), icon: const Icon(Icons.refresh)))
          ],
        ),
      ),
    );
  }

  String _getDateTimeText(int timeStamp) {
    /// * 1000 because openWeather uses secondsSinceEpoch
    if (isCurrent) {
      return 'Last updated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000))}';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000));
  }

  //// Simple function converting `unitOfMeasure` from it's name to the symbol
  String _getUnitOfMeasureSymbol(String unitOfMeasure) {
    if (unitOfMeasure == 'metric') return '°C';
    return '°F';
  }
}
