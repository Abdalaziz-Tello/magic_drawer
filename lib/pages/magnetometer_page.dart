import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../painters/sketch_painter.dart';

class MagnetometerPage extends StatefulWidget {
  const MagnetometerPage({super.key});

  @override
  State<MagnetometerPage> createState() => _MagnetometerPageState();
}

class _MagnetometerPageState extends State<MagnetometerPage> {
  bool _isSensorAvailable = false;
  bool _isListening = false;
  bool _isFirstPoint = true;
  List<Point> _points = [];
  Offset _currentPosition = Offset.zero;
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _speedMultiplier = 0.1; // Reduced from 0.5 to 0.1 for slower movement

  @override
  void initState() {
    super.initState();
    _checkSensorAvailability();
  }

  Future<void> _checkSensorAvailability() async {
    try {
      await magnetometerEventStream().first.timeout(const Duration(seconds: 2));
      setState(() => _isSensorAvailable = true);
    } catch (e) {
      setState(() => _isSensorAvailable = false);
    }
  }

  void _startListening() {
    if (!_isSensorAvailable) return;

    setState(() {
      _isListening = true;
      _isFirstPoint = true;
      _points = [];
      _currentPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
    });

    _subscription = magnetometerEventStream().listen((event) {
      setState(() {
        // Calculate new position based on magnetometer data with speed control
        final dx = _currentPosition.dx + (event.y * _speedMultiplier);
        final dy = _currentPosition.dy + (event.x * _speedMultiplier);

        // Keep the position within bounds
        final newDx = dx.clamp(0.0, MediaQuery.of(context).size.width);
        final newDy = dy.clamp(0.0, MediaQuery.of(context).size.height);
        _currentPosition = Offset(newDx, newDy);

        // Add point to drawing
        if (_isFirstPoint) {
          _points.add(Point(_currentPosition, Colors.blue, 2.0));
          _isFirstPoint = false;
        } else {
          _points.add(Point(_currentPosition, Colors.blue, 2.0));
        }
      });
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    setState(() {
      _isListening = false;
      _currentPosition = Offset.zero;
    });
  }

  void _restartDrawing() {
    setState(() {
      _points.clear();
      _currentPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _isFirstPoint = true;
    });
  }

  void _adjustSpeed(double delta) {
    setState(() {
      _speedMultiplier = (_speedMultiplier + delta).clamp(0.01, 0.5);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magnetometer Drawing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: SketchPainter(
              points: _points,
              currentPosition: _isListening ? _currentPosition : null,
            ),
            size: Size.infinite,
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Speed control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _adjustSpeed(-0.05),
                      color: Colors.blue,
                    ),
                    Text(
                      'Speed: ${(_speedMultiplier * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _adjustSpeed(0.05),
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          _isSensorAvailable
                              ? (_isListening
                                  ? _stopListening
                                  : _startListening)
                              : null,
                      icon: Icon(_isListening ? Icons.stop : Icons.play_arrow),
                      label: Text(_isListening ? 'Stop' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isListening ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _restartDrawing,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
