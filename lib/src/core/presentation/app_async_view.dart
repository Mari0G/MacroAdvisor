import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    required this.value,
    required this.data,
    required this.error,
    this.loading,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T value) data;
  final Widget Function(BuildContext context, Object error) error;
  final WidgetBuilder? loading;

  @override
  Widget build(BuildContext context) => value.when(
    data: (result) => data(context, result),
    error: (failure, _) => error(context, failure),
    loading: () =>
        loading?.call(context) ??
        const Center(child: CircularProgressIndicator()),
  );
}
