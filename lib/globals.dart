import 'package:dio/dio.dart';
import 'package:jobs_and_services/app/authenticate/client/jobs_and_services_api_client.dart';

var jobsAndServicesClient = JobsAndServicesClient().getApiClient();
var dioDefault = Dio();