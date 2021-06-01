import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import '../../constants/constants.dart';
import '../../utils/utils.dart';

const String METHOD_GET = "GET";
const String METHOD_POST = "POST";
const String METHOD_PUT = "PUT";
const String METHOD_DELETE = "DELETE";

class AppClients extends DioForNative {
  static AppClients? _instance;

  factory AppClients(
      {String baseUrl = AppEndpoint.BASE_URL, BaseOptions? options}) {
    if (_instance == null)
      _instance = AppClients._(baseUrl: baseUrl, options: options);
    if (options != null) _instance!.options = options;
    _instance!.options.baseUrl = baseUrl;
    return _instance!;
  }

  AppClients._({String baseUrl = AppEndpoint.BASE_URL, BaseOptions? options})
      : super(options) {
    this.interceptors.add(InterceptorsWrapper(
          onRequest: _requestInterceptor,
          onResponse: _responseInterceptor,
          onError: _errorInterceptor,
        ));
    this.options.baseUrl = baseUrl;
  }

  _requestInterceptor(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers
        .addEntries([MapEntry('Authorization', AppPref.accessToken)]);
    log("Header: ${options.headers}");
    switch (options.method) {
      case METHOD_GET:
        log("${options.method}: ${options.uri}\nParams: ${options.queryParameters}");
        break;
      case METHOD_POST:
        if (options.data is Map) {
          log("${options.method}: ${options.uri}\nParams: ${options.data}");
        } else if (options.data is FormData) {
          log("${options.method}: ${options.uri}\nParams: ${options.data.fields}");
        }
        break;
      default:
        break;
    }
    options.connectTimeout = AppEndpoint.connectionTimeout;
    options.receiveTimeout = AppEndpoint.receiveTimeout;
    handler.next(options);
  }

  _responseInterceptor(Response response, ResponseInterceptorHandler handler) {
    log("Response ${response.requestOptions.uri}: ${response.statusCode}\nData: ${response.data}");
    handler.next(response);
  }

  _errorInterceptor(DioError dioError, ErrorInterceptorHandler handler) {
    log("${dioError.type} - Error ${dioError.message}");
    handler.next(dioError);
  }
}
