import 'dart:isolate';
import 'package:flutter/foundation.dart' as foundation;

/// A service for handling compute-intensive tasks in isolates
class ComputeService {
  /// Run a compute-intensive task in an isolate
  ///
  /// [computation] is the function to run in the isolate
  /// [message] is the input data for the computation
  static Future<R> compute<Q, R>(
    foundation.ComputeCallback<Q, R> computation,
    Q message,
  ) {
    return foundation.compute(computation, message);
  }

  /// Alternative to Flutter's compute that gives more control over isolates
  /// Useful for more complex scenarios or when you need to maintain an isolate
  static Future<R> runIsolateTask<Q, R>(
    Function(Q) isolateFunction,
    Q message,
  ) async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn<_IsolateData<Q>>(
      _isolateEntryPoint,
      _IsolateData<Q>(
        sendPort: receivePort.sendPort,
        function: isolateFunction,
        message: message,
      ),
    );

    final response = await receivePort.first as R;
    receivePort.close();
    isolate.kill();
    return response;
  }

  static void _isolateEntryPoint<Q>(_IsolateData<Q> data) {
    final result = data.function(data.message);
    data.sendPort.send(result);
  }
}

class _IsolateData<Q> {
  final SendPort sendPort;
  final Function function;
  final Q message;

  _IsolateData({
    required this.sendPort,
    required this.function,
    required this.message,
  });
}
