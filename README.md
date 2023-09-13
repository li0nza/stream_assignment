<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Simple weather widget that provides two widgets to be displayed, or exposes some functions if you only want data

## Features

- 2 Predefined widgets to display `current weather` using either `Coordinates` or `Name`
- 2 Predefined widgets to display weather for a `timestamp` using either `Coordinates` or `Name`
- Exposes 4 functions to fetch data only
- `Caches` data for 60 seconds

## Getting started
An API key from https://openweathermap.org/api will be needed, specifically for the https://openweathermap.org/api/one-call-3 endpoint

**The API returns data from 1st January 1979 till 4 days ahead of the current date.**

## Usage

Instantiate the dataFactory with API key from https://openweathermap.org/api
```dart
  final WeatherDataFactory _dataFactory = WeatherDataFactory('api_key_here');
```
Widgets can be used like:
```dart
CurrentWeatherByCoordinates(
  _dataFactory,
  _latitude,
  _longitude,
  _metric ? 'metric' : 'imperial',
),
CurrentWeatherByName(
  _dataFactory,
  _name,
  _metric ? 'metric' : 'imperial',
),
DatedWeatherByCoordinates(
  _dataFactory,
  _latitude,
  _longitude,
  _selectedDateTime.millisecondsSinceEpoch,
  _metric ? 'metric' : 'imperial',
),
DatedWeatherByName(
  _dataFactory,
  _name,
  _selectedDateTime.millisecondsSinceEpoch,
  _metric ? 'metric' : 'imperial',
),
```
If only data is desired, functions can be accesed by:
```dart
_dataFactory.getLocationByCoordinates(lat, lon); // -> returns Location data for the given Coordinates
_dataFactory.getLocationByName(name); // -> returns Location data for the given Name
_dataFactory.getCurrentWeatherByCoordinates(latitude, lonitude); // -> returns current Weather data fthe given Coordinates
_dataFactory.getDatedWeatherByCoordinates(latitude, lonitude, timeStamp); // -> returns Weather data for the given Coordinates
```

To fetch weather data for a named location, `getLocationByName` needs to be called first to find the coordinates and then `getDatedWeatherByCoordinates` and/or `getCurrentWeatherByCoordinates` can be used.
