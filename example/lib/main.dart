import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stream_weather/stream_weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 57, 50, 184),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          bodySmall: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      home: const MyHomePage(title: 'Weather Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Instantiate [WeatherDataFactory] with an API key, to be able to fetch weather related data
  final WeatherDataFactory _dataFactory = WeatherDataFactory('API_KEY_HERE');
  final GlobalKey<FormState> _coordsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final TextEditingController _latitudeController = TextEditingController(text: '52');
  final TextEditingController _longitudeController = TextEditingController(text: '4');
  final TextEditingController _nameController = TextEditingController(text: 'Amsterdam');

  DateTime _selectedDateTime = DateTime.now();
  double _latitude = 52;
  double _longitude = 4;
  String _name = 'Amsterdam';
  bool _metric = true;
  bool _coordsOrName = false;

  String? _validateLatitude(String? value) {
    if (value!.isEmpty) {
      return 'Latitude is required';
    }
    final latitude = double.tryParse(value);
    if (latitude == null || latitude < -90 || latitude > 90) {
      return 'Invalid latitude';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value!.isEmpty) {
      return 'Longitude is required';
    }
    final longitude = double.tryParse(value);
    if (longitude == null || longitude < -180 || longitude > 180) {
      return 'Invalid longitude';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 112),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Column(children: [
                          Switch(
                              value: _coordsOrName,
                              onChanged: (val) {
                                setState(() {
                                  _coordsOrName = val;
                                });
                              }),
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text('Coordinates / Name'),
                          ),
                        ]),
                      ),
                      _coordsOrName ? _nameDemo(context) : _coordsDemo(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime initialDate = DateTime.now();
          DateTime firstDate = initialDate.subtract(const Duration(days: 365 * 10));
          DateTime lastDate = initialDate.add(const Duration(days: 3));

          final DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );

          if (selectedDate == null) return;

          // ignore: use_build_context_synchronously
          final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );

          setState(() {
            _selectedDateTime = selectedTime == null
                ? selectedDate
                : DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
          });
        },
        child: const Icon(Icons.calendar_month),
      ),
    );
  }

  Column _coordsDemo(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _coordsFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    validator: _validateLatitude,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(-?\d*\.?\d{0,2})'))],
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    validator: _validateLongitude,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(-?\d*\.?\d{0,2})'))],
                  ),
                  const SizedBox(height: 20.0),
                  _unitOfMeasureWidget(),
                  ElevatedButton(
                    onPressed: () {
                      if (_coordsFormKey.currentState!.validate()) {
                        setState(() {
                          _latitude = double.parse(_latitudeController.text);
                          _longitude = double.parse(_longitudeController.text);
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// [DatedWeatherByCoordinates] usage
        const Text('Weather widget for current weather'),
        CurrentWeatherByCoordinates(
          _dataFactory,
          _latitude,
          _longitude,
          _metric ? 'metric' : 'imperial',
        ),
        const Text('Weather widget for a specific date'),
        DatedWeatherByCoordinates(
          _dataFactory,
          _latitude,
          _longitude,
          _selectedDateTime.millisecondsSinceEpoch,
          _metric ? 'metric' : 'imperial',
        ),
      ],
    );
  }

  Column _nameDemo(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _nameFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: _nameController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 20.0),
                  _unitOfMeasureWidget(),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameFormKey.currentState!.validate()) {
                        setState(() {
                          _name = _nameController.text;
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// [DatedWeatherByName] usage
        const Text('Weather widget for current weather'),
        CurrentWeatherByName(
          _dataFactory,
          _name,
          _metric ? 'metric' : 'imperial',
        ),
        const Text('Weather widget for a specific date'),
        DatedWeatherByName(
          _dataFactory,
          _name,
          _selectedDateTime.millisecondsSinceEpoch,
          _metric ? 'metric' : 'imperial',
        ),
      ],
    );
  }

  Widget _unitOfMeasureWidget() {
    return Row(
      children: [
        Switch(
            value: _metric,
            onChanged: (val) {
              setState(() {
                _metric = val;
              });
            }),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('(°F) Imperial / (°C) Metric'),
        )
      ],
    );
  }
}
