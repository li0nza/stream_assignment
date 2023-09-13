part of stream_weather;

/// Widget showing current temperature, location, coordinates, feels like and an icon.
///
/// Requires a [WeatherDataFactory], `lat`, `lon`, and `unitOfMeasure`
///
/// Fetches [Weather] and [Location] objects to display data
class CurrentWeatherByCoordinates extends StatefulWidget {
  final WeatherDataFactory _dataFactory;
  final double _lat;
  final double _lon;
  final String _unitOfMeasure;

  const CurrentWeatherByCoordinates(
    this._dataFactory,
    this._lat,
    this._lon,
    this._unitOfMeasure, {
    super.key,
  });

  @override
  State<CurrentWeatherByCoordinates> createState() => _CurrentWeatherByCoordinatesState();
}

class _CurrentWeatherByCoordinatesState extends State<CurrentWeatherByCoordinates> {
  late Weather _weather;
  late Location _location;

  /// Initial state will always be loading
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    /// Fetch data on load
    _updateData();
  }

  @override
  void didUpdateWidget(CurrentWeatherByCoordinates oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If state has updated, check whether `lat`, `lon`, `timeStamp`, `unitOfMeasure` has changed.
    /// Also, if an error has occured, allow the refresh
    if (oldWidget._lat != widget._lat ||
        oldWidget._lon != widget._lon ||
        oldWidget._unitOfMeasure != widget._unitOfMeasure ||
        _error == true) {
      ///Reset state to show `loading`
      setState(() {
        _loading = true;
      });

      ///Fetch new data to update values after state has changed
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

    return _WeatherCard(context, _weather, _location, widget._unitOfMeasure, updateData: () => _updateData());
  }

  /// Function used to update the data displayed on the widget. Calls both `getCurrentWeatherByCoordinates`
  /// and `getLocationByCoordinates` and sets their respective parameters then forces a refresh with `setState`
  ///
  /// On failure it sets `loading` and `error` parameters and updates the state
  Future<void> _updateData() async {
    try {
      _weather = await widget._dataFactory.getCurrentWeatherByCoordinates(
        widget._lat,
        widget._lon,
        unitOfMeasure: widget._unitOfMeasure,
      );
      _location = await widget._dataFactory.getLocationByCoordinates(
        widget._lat,
        widget._lon,
      );
      setState(() {
        /// Clear loading and error states
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        /// Clear loading state and show error state
        _loading = false;
        _error = true;
      });
    }
  }
}

/// Widget showing current temperature, location, coordinates, feels like and an icon.
///
/// Requires a [WeatherDataFactory], `lat`, `lon`, and `unitOfMeasure`
///
/// Fetches [Weather] and [Location] objects to display data
class CurrentWeatherByName extends StatefulWidget {
  final WeatherDataFactory _dataFactory;
  final String _name;
  final String _unitOfMeasure;

  const CurrentWeatherByName(
    this._dataFactory,
    this._name,
    this._unitOfMeasure, {
    super.key,
  });

  @override
  State<CurrentWeatherByName> createState() => _CurrentWeatherByNameState();
}

class _CurrentWeatherByNameState extends State<CurrentWeatherByName> {
  late Weather _weather;
  late Location _location;

  /// Initial state will always be loading
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    /// Fetch data on load
    _updateData();
  }

  @override
  void didUpdateWidget(CurrentWeatherByName oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If state has updated, check whether `lat`, `lon`, `timeStamp`, `unitOfMeasure` has changed.
    /// Also, if an error has occured, allow the refresh
    if (oldWidget._name != widget._name || oldWidget._unitOfMeasure != widget._unitOfMeasure || _error == true) {
      ///Reset state to show `loading`
      setState(() {
        _loading = true;
      });

      ///Fetch new data to update values after state has changed
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

    return _WeatherCard(context, _weather, _location, widget._unitOfMeasure, updateData: () => _updateData());
  }

  /// Function used to update the data displayed on the widget. Calls both `getCurrentWeatherByName`
  /// and `getLocationByCoordinates` and sets their respective parameters then forces a refresh with `setState`
  ///
  /// On failure it sets `loading` and `error` parameters and updates the state
  Future<void> _updateData() async {
    try {
      _location = await widget._dataFactory.getLocationByName(
        widget._name,
      );
      _weather = await widget._dataFactory.getCurrentWeatherByCoordinates(
        _location.lat,
        _location.lon,
        unitOfMeasure: widget._unitOfMeasure,
      );
      setState(() {
        /// Clear loading and error states
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        /// Clear loading state and show error state
        _loading = false;
        _error = true;
      });
    }
  }
}

/// Widget showing temperature, location, coordinates, time and date, feels like and an icon.
///
/// Requires a [WeatherDataFactory], `lat`, `lon`, `timeStamp` and `unitOfMeasure`
///
/// Fetches [Weather] and [Location] objects to display data
class DatedWeatherByCoordinates extends StatefulWidget {
  final WeatherDataFactory _dataFactory;
  final double _lat;
  final double _lon;
  final int _timeStamp;
  final String _unitOfMeasure;

  const DatedWeatherByCoordinates(
    this._dataFactory,
    this._lat,
    this._lon,
    this._timeStamp,
    this._unitOfMeasure, {
    super.key,
  });

  @override
  State<DatedWeatherByCoordinates> createState() => _DatedWeatherByCoordinatesState();
}

class _DatedWeatherByCoordinatesState extends State<DatedWeatherByCoordinates> {
  late Weather _weather;
  late Location _location;

  /// Initial state will always be loading
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    /// Fetch data on load
    _updateData();
  }

  @override
  void didUpdateWidget(DatedWeatherByCoordinates oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If state has updated, check whether `lat`, `lon`, `timeStamp`, `unitOfMeasure` has changed.
    /// Also, if an error has occured, allow the refresh
    if (oldWidget._lat != widget._lat ||
        oldWidget._lon != widget._lon ||
        oldWidget._timeStamp != widget._timeStamp ||
        oldWidget._unitOfMeasure != widget._unitOfMeasure ||
        _error == true) {
      ///Reset state to show `loading`
      setState(() {
        _loading = true;
      });

      ///Fetch new data to update values after state has changed
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

    return _WeatherCard(context, _weather, _location, widget._unitOfMeasure);
  }

  /// Function used to update the data displayed on the widget. Calls both `getDatedWeatherByCoordinates`
  /// and `getLocationByCoordinates` and sets their respective parameters then forces a refresh with `setState`
  ///
  /// On failure it sets `loading` and `error` parameters and updates the state
  Future<void> _updateData() async {
    try {
      _weather = await widget._dataFactory.getDatedWeatherByCoordinates(
        widget._lat,
        widget._lon,
        (widget._timeStamp / 1000).floor(),
        unitOfMeasure: widget._unitOfMeasure,
      );
      _location = await widget._dataFactory.getLocationByCoordinates(
        widget._lat,
        widget._lon,
      );
      setState(() {
        /// Clear loading and error states
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        /// Clear loading state and show error state
        _loading = false;
        _error = true;
      });
    }
  }
}

/// Widget showing temperature, location, coordinates, time and date, feels like and an icon.
///
/// Requires a [WeatherDataFactory], `name`, `timeStamp` and `unitOfMeasure`
///
/// Fetches [Weather] and [Location] objects to display data
class DatedWeatherByName extends StatefulWidget {
  final WeatherDataFactory _dataFactory;
  final String _name;
  final int _timeStamp;
  final String _unitOfMeasure;

  const DatedWeatherByName(
    this._dataFactory,
    this._name,
    this._timeStamp,
    this._unitOfMeasure, {
    super.key,
  });

  @override
  State<DatedWeatherByName> createState() => _DatedWeatherByNameState();
}

class _DatedWeatherByNameState extends State<DatedWeatherByName> {
  late Weather _weather;
  late Location _location;

  /// Initial state will always be loading
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    /// Fetch data on load
    _updateData();
  }

  @override
  void didUpdateWidget(DatedWeatherByName oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If state has updated, check whether `name`, `timeStamp`, `unitOfMeasure` has changed.
    /// Also, if an error has occured, allow the refresh
    if (oldWidget._name != widget._name ||
        oldWidget._timeStamp != widget._timeStamp ||
        oldWidget._unitOfMeasure != widget._unitOfMeasure ||
        _error == true) {
      ///Reset state to show `loading`
      setState(() {
        _loading = true;
      });

      ///Fetch new data to update values after state has changed
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

    return _WeatherCard(context, _weather, _location, widget._unitOfMeasure);
  }

  /// Function used to update the data displayed on the widget. Calls `getLocationByName` and after
  /// `getDatedWeatherByCoordinates` then forces a refresh with `setState`
  ///
  /// On failure it sets `loading` and `error` parameters and updates the state
  Future<void> _updateData() async {
    try {
      _location = await widget._dataFactory.getLocationByName(
        widget._name,
      );
      _weather = await widget._dataFactory.getDatedWeatherByCoordinates(
        _location.lat,
        _location.lon,
        (widget._timeStamp / 1000).floor(),
        unitOfMeasure: widget._unitOfMeasure,
      );
      setState(() {
        /// Clear loading and error states
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        /// Clear loading state and show error state
        _loading = false;
        _error = true;
      });
    }
  }
}

/// Standardised weather card used to display the data for the two weather widgets
///
/// Requires `context`, [Weather], [Location] and `unitOfMeasure`
class _WeatherCard extends StatelessWidget {
  final BuildContext context;
  final Weather weather;
  final Location location;
  final String unitOfMeasure;
  final Future<void> Function()? updateData;

  const _WeatherCard(this.context, this.weather, this.location, this.unitOfMeasure, {this.updateData});

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
            if (_isACurrentWidget())
              Positioned(
                  right: 0, top: -4, child: IconButton(onPressed: () => updateData!(), icon: const Icon(Icons.refresh)))
          ],
        ),
      ),
    );
  }

  String _getDateTimeText(int timeStamp) {
    // * 1000 because openWeather uses secondsSinceEpoch
    if (_isACurrentWidget()) {
      return 'Last updated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000))}';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000));
  }

  bool _isACurrentWidget() {
    if (updateData != null) return true;
    return false;
  }

  /// Simple function converting `unitOfMeasure` from it's name to the symbol
  String _getUnitOfMeasureSymbol(String unitOfMeasure) {
    if (unitOfMeasure == 'metric') return '°C';
    return '°F';
  }
}

/// Returns a basic widget to represent the `loading` state
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

/// Returns a basic widget to represent the `error` state
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
