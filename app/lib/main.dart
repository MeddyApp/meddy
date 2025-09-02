import 'package:drift/drift.dart' as d;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:meddy/notifications.dart';
import 'package:meddy_core/meddy_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase(_openConnection());
  final medId = await db
      .into(db.medication)
      .insert(
        MedicationCompanion(
          name: const d.Value('Aspirin'),
          form: const d.Value('Pill'),
          strengthAmount: const d.Value(200),
          strengthUnit: const d.Value('mg'),
          shape: const d.Value('round'),
          color: const d.Value('#FFFFFF'),
          active: const d.Value(true),
        ),
      );

  print("MedID: $medId");

  await configureLocalTimeZone();
  final launchDetails = await initAsyncNotifications();
  final launchedViaNotification =
      launchDetails?.didNotificationLaunchApp ?? false;

  runApp(
    MyApp(
      title: !launchedViaNotification
          ? 'Meddy'
          : 'Meddy (launched via notification)',
    ),
  );
}

d.QueryExecutor _openConnection() {
  return driftDatabase(name: 'meddy', native: const DriftNativeOptions());
}

class MyApp extends StatelessWidget {
  final String title;

  const MyApp({super.key, required this.title});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
      ),
      home: MyHomePage(title: title),
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
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    () async {
      var permissionGranted = await isAndroidPermissionGranted();
      if (permissionGranted != true) {
        permissionGranted = await requestPermissions();
        print('Permission granted: $permissionGranted');
      }
    }();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              child: const Text('Schedule notification in the next minute'),
              onPressed: () async {
                await scheduleNotification();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
