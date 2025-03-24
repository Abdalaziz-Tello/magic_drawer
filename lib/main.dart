import 'package:flutter/material.dart';
import 'pages/accelerometer_page.dart';
import 'pages/gyroscope_page.dart';
import 'pages/magnetometer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Visualizer')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Sensor Pages',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Accelerometer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccelerometerPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Gyroscope'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GyroscopePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Magnetometer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MagnetometerPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Select a sensor from the drawer to visualize its data'),
      ),
    );
  }
}
