// // ignore_for_file: unnecessary_null_comparison, prefer_const_declarations

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'base_url.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';

class NetWorkDataSource extends GetConnect {
  final String baseUrl;

  static bool _didLogStartupToken = false;

  NetWorkDataSource({String? baseUrl}) : baseUrl = baseUrl ?? BaseUrl.BASE_URL;

  @override
  void onInit() {
    httpClient.timeout = const Duration(seconds: Constrains.timeout30);

    if (!_didLogStartupToken) {
      _didLogStartupToken = true;
      final token = AppPref.getToken();
      // final refreshToken =
      //     AppPref.getToken();

      // Log the FULL tokens
      log('=============== AUTH ===============');
      log('Access Token: ${token ?? "<empty>"}');
      // log('Refresh Token: ${refreshToken ?? "<empty>"}');
      log('====================================');
    }

    httpClient.addRequestModifier<dynamic>((Request<dynamic> request) async {
      final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final normalizedPath =
          request.url.path.startsWith('/')
              ? request.url.path.substring(1)
              : request.url.path;

      final shouldAttachAuth =
          !(normalizedPath.endsWith('auth/login') ||
              normalizedPath.endsWith('auth/checkVersion'));

      if (shouldAttachAuth && !request.headers.containsKey('Authorization')) {
        final token = AppPref.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = token;
        }
      }

      if (request.url.hasScheme && request.url.host.isNotEmpty) {
        return request;
      }

      final newUrl = Uri.parse(normalizedBase).resolve(normalizedPath);
      final query = request.url.queryParameters;
      return request.copyWith(url: newUrl.replace(queryParameters: query));
    });

    super.onInit();
  }

  Map<String, String> _buildHeaders({
    Map<String, String>? headers,
    required bool attachAuth,
    required bool isJson,
  }) {
    final out = <String, String>{...?headers};

    if (attachAuth) {
      final token = AppPref.getToken();
      if (token != null && token.isNotEmpty) {
        out['Authorization'] = token;
      }
    }

    if (isJson) {
      out.putIfAbsent('Content-Type', () => 'application/json');
      out.putIfAbsent('Accept', () => 'application/json');
    }

    return out;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool attachAuth = true,
  }) async {
    final res = await post<dynamic>(
      path,
      body,
      headers: _buildHeaders(
        headers: headers,
        attachAuth: attachAuth,
        isJson: true,
      ),
      query: queryParameters,
      contentType: 'application/json',
    ).timeout(timeout ?? const Duration(seconds: Constrains.timeout30));

    if (!res.isOk) {
      final message = res.bodyString ?? res.statusText ?? '';
      throw HttpException('Request failed (${res.statusCode}): $message');
    }

    final decoded = res.body;
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool attachAuth = true,
  }) async {
    final formData = FormData(fields);
    final res = await post<dynamic>(
      path,
      formData,
      headers: _buildHeaders(
        headers: headers,
        attachAuth: attachAuth,
        isJson: false,
      ),
      query: queryParameters,
      contentType: 'multipart/form-data',
    ).timeout(timeout ?? const Duration(seconds: Constrains.timeout30));

    if (!res.isOk) {
      final message = res.bodyString ?? res.statusText ?? '';
      throw HttpException('Request failed (${res.statusCode}): $message');
    }

    final decoded = res.body;
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  Future<Map<String, dynamic>> postFormUrlEncoded(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool attachAuth = true,
  }) async {
    final body = fields.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final outHeaders = _buildHeaders(
      headers: headers,
      attachAuth: attachAuth,
      isJson: false,
    );
    outHeaders.putIfAbsent(
      'Content-Type',
      () => 'application/x-www-form-urlencoded',
    );
    outHeaders.putIfAbsent('Accept', () => 'application/json');

    final res = await post<dynamic>(
      path,
      body,
      headers: outHeaders,
      query: queryParameters,
      contentType: 'application/x-www-form-urlencoded',
    ).timeout(timeout ?? const Duration(seconds: Constrains.timeout30));

    if (!res.isOk) {
      final message = res.bodyString ?? res.statusText ?? '';
      throw HttpException('Request failed (${res.statusCode}): $message');
    }

    final decoded = res.body;
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  Future<Map<String, dynamic>> postMultipartWithFile(
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? filePath,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    bool attachAuth = true,
  }) async {
    final formData = FormData(<String, dynamic>{...fields});

    final normalizedFileField = fileField ?? 'file';
    if (filePath != null && filePath.isNotEmpty) {
      final f = File(filePath);
      if (await f.exists()) {
        formData.files.add(
          MapEntry(
            normalizedFileField,
            MultipartFile(
              f,
              filename:
                  f.uri.pathSegments.isNotEmpty
                      ? f.uri.pathSegments.last
                      : 'upload',
            ),
          ),
        );
      }
    }

    final res = await post<dynamic>(
      path,
      formData,
      headers: _buildHeaders(
        headers: headers,
        attachAuth: attachAuth,
        isJson: false,
      ),
      query: queryParameters,
      contentType: 'multipart/form-data',
    ).timeout(timeout ?? const Duration(seconds: Constrains.timeout30));

    if (!res.isOk) {
      final message = res.bodyString ?? res.statusText ?? '';
      throw HttpException('Request failed (${res.statusCode}): $message');
    }

    final decoded = res.body;
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }
}

class NetworkDataSource extends NetWorkDataSource {
  NetworkDataSource({super.baseUrl});
}

class ApiError implements Exception {
  final String? message;
  final int? statusCode;

  ApiError(this.message, this.statusCode);

  @override
  String toString() => 'ApiError: $message (Status code: $statusCode)';
}
