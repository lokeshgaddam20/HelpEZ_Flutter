import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';
import 'package:bridgefy_example/presentation/screens/logs_screen.dart';
import 'package:bridgefy_example/presentation/screens/chat_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  final String? phone;
  final String? messages;
  const HomeScreen({super.key, this.name, this.phone, this.messages});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLogs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize Bridgefy when the app opens
      final sdkProvider = context.read<SdkProvider>();
      sdkProvider.initialized().then((_) {
        sdkProvider.start();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sdkProvider = context.watch<SdkProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This will close the Flutter app and return to the Expo app
            SystemNavigator.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name ?? 'Bridgefy',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.phone != null)
              Text(
                widget.phone!,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_rows_outlined),
            onPressed: () {
              setState(() {
                showLogs = !showLogs;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
                icon: sdkProvider.isStarted
                    ? const Icon(Icons.stop_circle)
                    : const Icon(Icons.check_circle),
                onPressed: () {
                  if (sdkProvider.isStarted) {
                    sdkProvider.stop();
                  } else {
                    sdkProvider.start();
                  }
                },
                label: Text(sdkProvider.isStarted ? 'Stop' : 'Start')),
          ),
        ],
      ),
      body: SafeArea(
        child: showLogs
            ? const LogsScreen()
            : ChatScreen(
                name: widget.name,
                phone: widget.phone,
                messages: widget.messages),
      ),
    );
  }
}
