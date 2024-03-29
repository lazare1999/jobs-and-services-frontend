import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';


class JobsAndServicesInterceptor extends Interceptor {

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    var token = await getAccessToken();
    token = token ?? "";

    options.baseUrl = dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']!;
    options.headers[HttpHeaders.authorizationHeader] = "Bearer " + token;
    options.connectTimeout = 30000;

    return super.onRequest(options, handler);
  }

}