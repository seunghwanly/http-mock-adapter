import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/src/exceptions.dart';
import 'package:http_mock_adapter/src/logger/logger.dart';
import 'package:http_mock_adapter/src/matchers/http_matcher.dart';
import 'package:http_mock_adapter/src/mixins/mixins.dart';
import 'package:http_mock_adapter/src/response.dart';

/// [HttpClientAdapter] extension with data mocking and recording functionality.
class DioAdapter with Recording, RequestHandling implements HttpClientAdapter {
  /// State of [DioAdapter] that can be closed to prohibit functionality.
  bool _isClosed = false;

  @override
  final Dio dio;

  @override
  final HttpRequestMatcher matcher;

  @override
  late Logger logger;

  final bool printLogs;

  @override
  final bool failOnMissingMock = true;

  /// Constructs a [DioAdapter] and configures the passed [Dio] instance.
  DioAdapter({
    required this.dio,
    this.matcher = const FullHttpRequestMatcher(),
    this.printLogs = false,
  }) {
    dio.httpClientAdapter = this;
    logger = getLogger(printLogs);
  }

  /// [DioAdapter]`s [fetch] configuration intended to work with mock data.
  /// Returns a [Future<ResponseBody>] from [history] based on [RequestOptions].
  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    if (_isClosed) {
      logger.e('Cannot establish connection after [$runtimeType] got closed!');
      throw ClosedException(
        'Cannot establish connection after [$runtimeType] got closed!',
      );
    }

    await setDefaultRequestHeaders(dio, requestOptions);
    final response = await mockResponse(requestOptions) as MockResponse;

    // Waits for defined duration.
    if (response.delay != null) await Future.delayed(response.delay!);

    // Throws DioException if response type is MockDioException.
    if (isMockDioException(response)) throw response as DioException;

    return response as MockResponseBody;
  }

  /// Closes the [DioAdapter] by force.
  @override
  void close({bool force = false}) => _isClosed = true;
}
