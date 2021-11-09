import 'package:dio/dio.dart';
import 'jobs_and_services_api_interseptor.dart';

class JobsAndServicesClient {

  static final Dio _dio = Dio();

  Dio getApiClient() {
    _dio.interceptors.clear();
    _dio.interceptors.add(JobsAndServicesInterceptor());
    return _dio;
  }


}