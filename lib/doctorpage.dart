import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sunhackshealthtech/resource.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  final ValueNotifier<bool> online = ValueNotifier(true);

  late final pages = <Widget>[
    HomePage(online: online),
    PatientsPage(onScanTap: _openQR),
    const QRScannerPage(),
    CalendarPage(),
    const ThreadsPage(),
    ProfilePage(online: online),
  ];

  void _openQR() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QRScannerPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner, size: 36), // Bigger center QR
            selectedIcon: Icon(Icons.qr_code_scanner, size: 36),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Appointment {
  Appointment({
    required this.patient,
    required this.reason,
    required this.time, // "09:00"
    required this.date, // date used for calendar
    this.completed = false,
  });

  final String patient;
  final String reason;
  final String time;
  final DateTime date;
  bool completed;
}

final _today = DateTime.now();

final List<Appointment> allAppointments = [
  Appointment(
    patient: 'David Mitchell',
    reason: 'Follow-up',
    time: '09:00',
    date: _today,
  ),
  Appointment(
    patient: 'Sarah Johnson',
    reason: 'Headache',
    time: '10:30',
    date: _today,
  ),
  Appointment(
    patient: 'James Carter',
    reason: 'Chest pain',
    time: '11:30',
    date: _today,
  ),
  Appointment(
    patient: 'Emily Wilson',
    reason: 'Consultation',
    time: '13:00',
    date: _today,
  ),
  Appointment(
    patient: 'Noah Kim',
    reason: 'Skin rash',
    time: '09:20',
    date: _today.subtract(const Duration(days: 1)),
    completed: true,
  ),
  Appointment(
    patient: 'Olivia Patel',
    reason: 'Diabetes review',
    time: '15:00',
    date: _today.subtract(const Duration(days: 2)),
    completed: true,
  ),
  Appointment(
    patient: 'Amelia Clark',
    reason: 'Check-up',
    time: '10:00',
    date: _today.add(const Duration(days: 1)),
  ),
  Appointment(
    patient: 'Liam Parker',
    reason: 'Back pain',
    time: '12:30',
    date: _today.add(const Duration(days: 3)),
  ),
];

class Thread {
  Thread(this.name, this.last, this.messages);
  final String name;
  final String last;
  final List<Message> messages;
}

class Message {
  Message(this.text, this.isMe, this.time);
  final String text;
  final bool isMe;
  final DateTime time;
}

final threads = [
  Thread('Sarah Johnson', 'Thanks, doctor!', [
    Message(
      'Hi doctor, I still feel dizzy.',
      false,
      DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Message(
      'Take rest today, hydrate well.',
      true,
      DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    Message(
      'Thanks, doctor!',
      false,
      DateTime.now().subtract(const Duration(minutes: 27)),
    ),
  ]),
  Thread('David Mitchell', 'See you tomorrow at 9.', [
    Message(
      'Can we confirm my follow-up time?',
      false,
      DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Message(
      'See you tomorrow at 9.',
      true,
      DateTime.now().subtract(const Duration(hours: 3, minutes: 58)),
    ),
  ]),
];

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Text(text, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

Widget appointmentCard(Appointment a) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 300),
    builder: (context, v, child) => Transform.translate(
      offset: Offset(0, 16 * (1 - v)),
      child: Opacity(opacity: v, child: child),
    ),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(
          a.patient,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(a.reason),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(a.time, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (a.completed ? Colors.green : Colors.orange).withOpacity(
                  .12,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.completed ? 'Completed' : 'Upcoming',
                style: TextStyle(
                  color: a.completed ? Colors.green : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.online});
  final ValueNotifier<bool> online;

  @override
  Widget build(BuildContext context) {
    final todayItems = allAppointments.where((a) {
      final d = a.date;
      final n = DateTime.now();
      return d.year == n.year && d.month == n.month && d.day == n.day;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(online, context)),
          const SliverToBoxAdapter(child: SectionTitle("Today's Appointments")),
          SliverList.builder(
            itemCount: todayItems.length,
            itemBuilder: (_, i) => appointmentCard(todayItems[i]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('PRESCRIPTION'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('NOTE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SectionTitle('Emergency Alerts')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFFFFE1E4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Michael Brown',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Room 12'),
                  trailing: Wrap(
                    spacing: 4,
                    children: const [
                      Icon(Icons.call, color: Colors.red),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      // floatingActionButton: SizedBox(
      //   width: 60,
      //   height: 60,
      //   child: FloatingActionButton(
      //     backgroundColor: Colors.orange,
      //     onPressed: () async {
      //       // handle mic action here

      //     },
      //     child: const Icon(Icons.mic, size: 28),
      //   ),
      // ),
    );
  }

  Widget _header(ValueNotifier<bool> online, BuildContext context) {
    final username = Provider.of<resource>(
      context,
      listen: false,
    ).PresentWorkingUser;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF2D5D8A)),
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
      child: Row(
        children: [
          // 👇 Avatar updated with image from URL
          FutureBuilder<String?>(
            future: fetchUserProfileImageUrl(username),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 34,
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return CircleAvatar(
                  radius: 34,
                  backgroundImage: NetworkImage(snapshot.data!),
                );
              } else {
                return const CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage('assets/doctor.jpg'), // fallback
                );
              }
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Cardiology',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: online,
                  builder: (_, v, __) => Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: v ? Colors.greenAccent : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        v ? 'Online' : 'Offline',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: v,
                        onChanged: (nv) => online.value = nv,
                        activeColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> fetchUserProfileImageUrl(String username) async {
    const baseUrl = 'https://djangotestcase.s3.ap-south-1.amazonaws.com/';
    final extensions = ['jpg', 'jpeg', 'png'];

    for (String ext in extensions) {
      final url = '$baseUrl${username}profile.$ext';
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (_) {
        // continue trying other extensions
      }
    }
    return null;
  }
}

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key, required this.onScanTap});
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    final sorted = [...allAppointments]
      ..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, size: 26),
            onPressed: onScanTap,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (_, i) => appointmentCard(sorted[i]),
      ),
    );
  }
}

class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailPage({super.key, required this.patient});

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient: ${patient["name"]}")),
      backgroundColor: const Color(0xFFF6F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5D8A), Color(0xFF3E7FB2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: AssetImage("assets/patient.jpg"),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        patient["doctor"],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Hospital: ${patient["hospital"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Basic Info
            _card("Basic Info", [
              _row("Age", patient["age"].toString()),
              _row("Gender", patient["gender"]),
              _row("Blood Group", patient["bloodGroup"]),
              _row("Insurance", patient["insurance"]),
            ]),

            // Medical
            _card("Medical History", [
              _row("Conditions", (patient["conditions"] as List).join(", ")),
              _row("Allergies", (patient["allergies"] as List).join(", ")),
              _row("Medications", (patient["medications"] as List).join(", ")),
              _row("Last Visit", patient["lastVisit"]),
            ]),

            // Contact
            _card("Contact", [
              _row("Doctor", patient["doctor"]),
              _row("Emergency Contact", patient["emergencyContact"]),
              _row("Address", patient["address"]),
            ]),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                {
                  // Step 2: Fetch all device tokens
                  final tokenResponse = await http.get(
                    Uri.parse(
                      "http://13.203.219.206:8000/getsportsnotificationtoken/",
                    ),
                  );

                  if (tokenResponse.statusCode == 200) {
                    final data = jsonDecode(tokenResponse.body);
                    final List<dynamic> tokens = data['tokens'];

                    await http.post(
                      Uri.parse(
                        "http://13.203.219.206:8000/sendnotificationtoall/",
                      ),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "title": "Doctor Appointmnet",
                        "body": "Your Appointment Will be in 4pm 21st",
                      }),
                    );

                    print("🔔 Notifications sent to ${tokens.length} devices.");
                  } else {
                    print("⚠ Failed to fetch tokens: ${tokenResponse.body}");
                  }
                  Navigator.pop(context);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✔ Follow-up booked & Notified "),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text("Book Checkup"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              for (final code in capture.barcodes) {
                final value = code.rawValue;
                if (value == null) continue;

                try {
                  final decoded = jsonDecode(value);
                  if (decoded["type"] == "PatientAccess") {
                    final expiry = DateTime.parse(decoded["expiry"]);
                    if (DateTime.now().isAfter(expiry)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("⚠ QR Expired")),
                      );
                      return;
                    }

                    // Navigate to detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PatientDetailPage(patient: decoded["data"]),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Invalid QR format")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
          ),
          // Overlay
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selected = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    final items =
        allAppointments
            .where(
              (a) =>
                  a.date.year == selected.year &&
                  a.date.month == selected.month &&
                  a.date.day == selected.day,
            )
            .toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    final upcoming = items.where((a) => !a.completed).toList();
    final completed = items.where((a) => a.completed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _DateStrip(
            initial: selected,
            onChanged: (d) => setState(() => selected = d),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Selected: ${_fmtDate(selected)}')),
              Chip(label: Text('Upcoming: ${upcoming.length}')),
              Chip(label: Text('Completed: ${completed.length}')),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No appointments on this date.'))
                : ListView(
                    children: [
                      if (upcoming.isNotEmpty) const SectionTitle('Upcoming'),
                      ...upcoming.map(appointmentCard),
                      if (completed.isNotEmpty) const SectionTitle('Completed'),
                      ...completed.map(appointmentCard),
                      const SizedBox(height: 12),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.initial, required this.onChanged});
  final DateTime initial;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final end = now.add(const Duration(days: 14));
    final days = List<DateTime>.generate(
      end.difference(start).inDays + 1,
      (i) => DateTime(start.year, start.month, start.day + i),
    );

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: days.length,
        itemBuilder: (_, i) {
          final d = days[i];
          final selected =
              d.year == initial.year &&
              d.month == initial.month &&
              d.day == initial.day;
          return GestureDetector(
            onTap: () => onChanged(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.all(12),
              width: 70,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFF1F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    [
                      'Sun',
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                    ][d.weekday % 7],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ThreadsPage extends StatelessWidget {
  const ThreadsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final t = threads[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 250 + (i * 70)),
            builder: (_, v, child) => Transform.translate(
              offset: Offset(0, 18 * (1 - v)),
              child: Opacity(opacity: v, child: child),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  t.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  t.last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatPage(thread: t)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.thread});
  final Thread thread;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ctrl = TextEditingController();

  void _send() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.thread.messages.add(Message(text, true, DateTime.now()));
      ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        widget.thread.messages.add(Message('Noted 👍', false, DateTime.now()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = widget.thread.messages;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
            const SizedBox(width: 8),
            Text(widget.thread.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                return Align(
                  alignment: m.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 200),
                      builder: (_, v, child) => Transform.scale(
                        scale: .9 + .1 * v,
                        child: Opacity(opacity: v, child: child),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: m.isMe
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(m.isMe ? 16 : 4),
                            bottomRight: Radius.circular(m.isMe ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.online});
  final ValueNotifier<bool> online;

  // Fetch image URL from S3
  Future<String?> fetchUserProfileImageUrl(String username) async {
    const baseUrl = 'https://djangotestcase.s3.ap-south-1.amazonaws.com/';
    final extensions = ['jpg', 'jpeg', 'png'];

    for (String ext in extensions) {
      final url = '$baseUrl${username}profile.$ext';
      try {
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          return url;
        }
      } catch (_) {
        // continue checking other extensions
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    stat(String label, String value, IconData icon) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _cover(context, online)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      stat('Experience', '15 yrs', Icons.workspace_premium),
                      const SizedBox(width: 12),
                      stat('Patients', '1.2k', Icons.people_alt),
                      const SizedBox(width: 12),
                      stat('Rating', '4.9', Icons.star),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _card(
                    context,
                    'About Doctor',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv(
                          'Name',
                          Provider.of<resource>(
                            context,
                            listen: false,
                          ).PresentWorkingUser,
                        ),
                        _kv('Specialization', 'Cardiology'),
                        _kv('Age', '41'),
                        _kv('Education', 'MD, Harvard Medical School'),
                        _kv('Hospital', 'City Heart Center'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    'Contact',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Email', 'john.smith@hospital.com'),
                        _kv('Phone', '+1 555-0123'),
                        _kv('Address', '12 Medical Ave, Metro City'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cover section with top-left avatar
  Widget _cover(BuildContext context, ValueNotifier<bool> online) {
    final username = Provider.of<resource>(
      context,
      listen: false,
    ).PresentWorkingUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D5D8A), Color(0xFF3E7FB2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // 👇 Profile image from S3
          FutureBuilder<String?>(
            future: fetchUserProfileImageUrl(username),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 38,
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(snapshot.data!),
                );
              } else {
                return const CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage('assets/doctor.jpg'),
                );
              }
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Provider.of<resource>(
                    context,
                    listen: false,
                  ).PresentWorkingUser,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Cardiology',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: online,
                  builder: (_, v, __) => Chip(
                    label: Text(
                      v ? 'Online' : 'Offline',
                      style: const TextStyle(color: Colors.white),
                    ),
                    avatar: CircleAvatar(
                      backgroundColor: v ? Colors.green : Colors.red,
                    ),
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable animated card
  Widget _card(BuildContext context, String title, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (_, v, c) => Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: Opacity(opacity: v, child: c),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  /// Helper key-value widget
  static Widget _kv(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          "$key: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

class _kv extends StatelessWidget {
  _kv(this.k, this.v);
  final String k, v;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
