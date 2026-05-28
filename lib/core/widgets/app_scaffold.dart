import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final String? backRoute;
  final Widget? fab;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.backRoute,
    this.fab,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (backRoute != null) {
                    context.go(backRoute!);
                  } else {
                    context.pop();
                  }
                },
              )
            : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton ?? fab,
    );
  }
}
