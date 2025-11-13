import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

/// AsyncValue 위젯 래퍼
/// PRD에서 AsyncValueWidget 패턴 강제 요구사항
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget Function()? loading;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: error ??
          (err, stack) => AppErrorWidget(
                message: err.toString(),
                onRetry: onRetry,
              ),
      loading: loading ?? (() => const AppLoadingWidget()),
    );
  }
}

