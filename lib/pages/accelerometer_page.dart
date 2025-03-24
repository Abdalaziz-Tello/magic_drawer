import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/sensor_checker.dart';
import '../painters/sketch_painter.dart';

class AccelerometerPage extends StatefulWidget {
  const AccelerometerPage({super.key});

  @override
  State<AccelerometerPage> createState() => _AccelerometerPageState();
}

class _AccelerometerPageState extends State<AccelerometerPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isSensorAvailable = false;
  bool _isListening = false;
  final List<Point> _points = [];
  Offset _currentPosition = Offset.zero;
  bool _isFirstPoint = true;

  @override
  void initState() {
    super.initState();
    _checkSensorAvailability();
  }

  Future<void> _checkSensorAvailability() async {
    final isAvailable = await SensorChecker.isAccelerometerAvailable();
    setState(() {
      _isSensorAvailable = isAvailable;
    });
  }

  void _startListening() {
    _currentPosition = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    _isFirstPoint = true;

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        // Calculate new position
        final newPosition =
            _currentPosition + Offset(event.x * 0.5, event.y * 0.5);

        // Keep within bounds
        final padding = 20.0;
        final maxWidth = MediaQuery.of(context).size.width - padding;
        final maxHeight = MediaQuery.of(context).size.height - padding;

        _currentPosition = Offset(
          newPosition.dx.clamp(padding, maxWidth),
          newPosition.dy.clamp(padding, maxHeight),
        );

        // Add point to drawing
        if (_isFirstPoint) {
          _points.add(
            Point(_currentPosition, Colors.blue.withOpacity(0.6), 2.0),
          );
          _isFirstPoint = false;
        } else {
          _points.add(
            Point(_currentPosition, Colors.blue.withOpacity(0.6), 2.0),
          );
        }
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _accelerometerSubscription?.cancel();
    setState(() {
      _isListening = false;
      _isFirstPoint = true;
    });
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
      _currentPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _isFirstPoint = true;
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          !_isSensorAvailable
              ? const Center(
                child: Text('Accelerometer not available on this device'),
              )
              : Stack(
                children: [
                  CustomPaint(
                    painter: SketchPainter(
                      points: _points,
                      currentPosition: _isListening ? _currentPosition : null,
                    ),
                    size: Size.infinite,
                    child: Container(color: Colors.white),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isListening ? _stopListening : _startListening,
                          icon: Icon(
                            _isListening ? Icons.stop : Icons.play_arrow,
                          ),
                          label: Text(_isListening ? 'Stop' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isListening ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearDrawing,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
