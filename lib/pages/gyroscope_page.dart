import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../painters/sketch_painter.dart';

class GyroscopePage extends StatefulWidget {
  const GyroscopePage({super.key});

  @override
  State<GyroscopePage> createState() => _GyroscopePageState();
}

class _GyroscopePageState extends State<GyroscopePage> {
  bool _isSensorAvailable = false;
  bool _isListening = false;
  bool _isFirstPoint = true;
  List<Point> _points = [];
  Offset _currentPosition = Offset.zero;
  StreamSubscription<GyroscopeEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkSensorAvailability();
  }

  Future<void> _checkSensorAvailability() async {
    try {
      await gyroscopeEventStream().first.timeout(const Duration(seconds: 2));
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

    _subscription = gyroscopeEventStream().listen((event) {
      setState(() {
        // Calculate new position based on gyroscope data
        final dx = _currentPosition.dx + (event.y * 10);
        final dy = _currentPosition.dy + (event.x * 10);

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gyroscope Drawing'),
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
            child: Center(
              child: ElevatedButton(
                onPressed:
                    _isSensorAvailable
                        ? (_isListening ? _stopListening : _startListening)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(_isListening ? 'Stop' : 'Start'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
