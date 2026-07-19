import 'package:flutter/material.dart';

class ApartmentEmptyState extends StatelessWidget {
  const ApartmentEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: Text('No apartments match your filters.')),
  );
}

class ApartmentErrorState extends StatelessWidget {
  const ApartmentErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
