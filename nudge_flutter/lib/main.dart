import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:nudge_client/nudge_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

var client = Client('https://my-nudge.api.serverpod.space/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    scheduleWaterNotification();
  } catch (e) {
    debugPrint("Butler Error: $e");
  }

  runApp(const MyApp());
}

Future<void> scheduleWaterNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'water_channel',
    'Water Alerts',
    importance: Importance.max,
    priority: Priority.high,
  );
  await flutterLocalNotificationsPlugin.periodicallyShow(
    0,
    'Hydration Check',
    'Stay hydrated, Sir.',
    RepeatInterval.everyMinute,
    const NotificationDetails(android: androidDetails),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<NudgeData> _nudges = [];
  XFile? _capsuleImage;

  @override
  void initState() {
    super.initState();
    _fetchNudges();
    _loadCapsuleImage();
    requestAlarmPermissions();
  }

  Future<void> _loadCapsuleImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString('saved_capsule_path');
    if (path != null) {
      setState(() => _capsuleImage = XFile(path));
    }
  }

  Future<void> _pickCapsuleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_capsule_path', image.path);
      setState(() => _capsuleImage = image);
    }
  }

  Future<void> requestAlarmPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleWarrantyReminder({
    required String item,
    required int years,
  }) async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(days: (years * 365) - 30));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      item.hashCode,
      '🛡️ WARRANTY ALERT',
      'Sir, the warranty for $item expires in 30 days.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'warranty_expiry',
          'Warranty Expiry',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> triggerDemoWarrantyAlert(String itemName) async {
    await flutterLocalNotificationsPlugin.show(
      999,
      '🛡️ BUTLER: URGENT ARCHIVE ALERT',
      'Sir, the warranty for $itemName expires in 30 days.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'demo_vault_channel',
          'Vault Demo',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.amber,
        ),
      ),
    );
  }

  Future<void> scheduleTaskAlarm({
    required String title,
    required int minutesFromNow,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      '🚨 BUTLER: ACTION REQUIRED',
      'Sir, $title ',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks',
          'Butler Tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _fetchNudges() async {
    try {
      var result = await client.nudgeData.getAll();
      setState(() => _nudges = result);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _startGhostMode(String activity, int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GhostOverlay(activity: activity, minutes: minutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    NudgeData? capsule;
    try {
      capsule = _nudges.firstWhere((n) => n.category == 'CAPSULE');
    } catch (_) {
      capsule = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NUDGE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.amberAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WarrantyVaultPage(
                  nudges: _nudges,
                  onTriggerDemo: triggerDemoWarrantyAlert,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🚀 CONTEXT RECOVERY CARD
          if (capsule != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263238), Colors.black],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.history_edu,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "CONTEXT RECOVERY",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Sir, you stopped here. Not only do I have your notes, but I've kept a visual snapshot of your environment so you can pick up exactly where you left off.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Last Note: ${capsule.title}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_capsuleImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_capsuleImage!.path),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('saved_capsule_path');
                      await client.nudgeData.delete(capsule!);
                      setState(() => _capsuleImage = null);
                      await _fetchNudges();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                      foregroundColor: Colors.cyanAccent,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text(
                      "RESUME MISSION",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Talk to Butler...",
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.add_a_photo,
                    color: _capsuleImage != null
                        ? Colors.greenAccent
                        : Colors.amber,
                  ),
                  onPressed: _pickCapsuleImage,
                ),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  String responseString = await client.nudgeData.create(val);
                  Map<String, dynamic> analysis = jsonDecode(responseString);
                  _textController.clear();
                  await _fetchNudges();

                  int parseDelay(dynamic input, int defaultValue) {
                    final cleanValue = input.toString().replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    return int.tryParse(cleanValue) ?? defaultValue;
                  }

                  if (analysis['type'] == 'ASSET') {
                    int years = parseDelay(analysis['delay'], 1);
                    await scheduleWarrantyReminder(
                      item: analysis['val'],
                      years: years,
                    );
                    messenger.showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.amber,
                        content: Text('Vault Updated.'),
                      ),
                    );
                  } else if (analysis['type'] == 'TASK') {
                    int mins = parseDelay(analysis['delay'], 5);
                    await scheduleTaskAlarm(
                      title: analysis['val'],
                      minutesFromNow: mins,
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Butler: "Alarm set for $mins mins."'),
                      ),
                    );
                  } else if (analysis['type'] == 'GHOST') {
                    int mins = parseDelay(analysis['delay'], 25);
                    _startGhostMode(analysis['val'], mins);
                  } else if (analysis['type'] == 'CAPSULE') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Butler: "Work state frozen."'),
                      ),
                    );
                  }
                  // 🤖 THE INTEL CHATBOT HANDLER
                  else if (analysis['type'] == 'INTEL') {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          245,
                          246,
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        content: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.amberAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Butler: "${analysis['val']}"',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _nudges.length,
              itemBuilder: (context, index) {
                var nudge = _nudges[index];
                if (nudge.category == 'CAPSULE') return const SizedBox.shrink();

                return Dismissible(
                  key: Key(nudge.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent.withOpacity(0.1),
                    child: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                    ),
                  ),
                  onDismissed: (_) async =>
                      await client.nudgeData.delete(nudge),
                  child: Card(
                    color: nudge.category == 'INTEL'
                        ? Colors.blueGrey.withOpacity(0.05)
                        : Colors.white10,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        nudge.category == 'ASSET'
                            ? Icons.inventory_2
                            : nudge.category == 'INTEL'
                            ? Icons.forum_rounded
                            : Icons.notifications_active,
                        color: nudge.category == 'INTEL'
                            ? Colors.indigoAccent
                            : Colors.cyanAccent,
                      ),
                      title: Text(
                        nudge.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(nudge.category),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WarrantyVaultPage extends StatelessWidget {
  final List<NudgeData> nudges;
  final Function(String) onTriggerDemo;
  const WarrantyVaultPage({
    super.key,
    required this.nudges,
    required this.onTriggerDemo,
  });

  @override
  Widget build(BuildContext context) {
    final assets = nudges.where((n) => n.category == 'ASSET').toList();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🛡️ ASSET ARCHIVE'),
        backgroundColor: Colors.amber.withOpacity(0.1),
      ),
      body: assets.isEmpty
          ? const Center(child: Text("Vault Empty, Sir."))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 25,
                  headingRowColor: WidgetStateProperty.all(
                    Colors.amber.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'ASSET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'EST. EXPIRY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ACTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                  rows: assets.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text("${(item.id ?? 0) % 5 + 2026}-01-29")),
                        DataCell(
                          InkWell(
                            onTap: () => onTriggerDemo(item.title),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "TEST NUDGE",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

class GhostOverlay extends StatelessWidget {
  final String activity;
  final int minutes;
  const GhostOverlay({
    super.key,
    required this.activity,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_fix_high,
              color: Colors.purpleAccent,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "GHOST FOCUS ACTIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Mission: $activity",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TweenAnimationBuilder<Duration>(
              duration: Duration(minutes: minutes),
              tween: Tween(
                begin: Duration(minutes: minutes),
                end: Duration.zero,
              ),
              builder: (BuildContext context, Duration value, Widget? child) {
                final min = value.inMinutes;
                final sec = value.inSeconds % 60;
                return Text(
                  '$min:${sec.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w100,
                  ),
                );
              },
              onEnd: () => Navigator.pop(context),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.3),
              ),
              child: const Text("Break Focus"),
            ),
          ],
        ),
      ),
    );
  }
}
