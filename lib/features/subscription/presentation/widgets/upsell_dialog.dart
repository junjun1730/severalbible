import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum UpsellTrigger { archiveLocked, contentExhausted, premiumScripture }

class UpsellDialog extends StatelessWidget {
  final UpsellTrigger trigger;

  const UpsellDialog({super.key, required this.trigger});

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;

    switch (trigger) {
      case UpsellTrigger.archiveLocked:
        title = 'Unlock Your History';
        message =
            'Upgrade to Premium to access your entire prayer note archive and reflect on your spiritual journey.';
        icon = Icons.history_edu;
        break;
      case UpsellTrigger.contentExhausted:
        title = 'Thirsting for More?';
        message =
            'Get unlimited access to daily scriptures and wisdom with our Premium plan.';
        icon = Icons.water_drop;
        break;
      case UpsellTrigger.premiumScripture:
        title = 'Exclusive Teachings';
        message =
            'This teaching is reserved for Premium members. Unlock deep insights today.';
        icon = Icons.star;
        break;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Maybe Later',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/premium');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Upgrade Now'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
