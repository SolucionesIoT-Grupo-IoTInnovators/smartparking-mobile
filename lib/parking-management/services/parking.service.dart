import 'package:smartparking_mobile_application/shared/services/http-common.dart';

class ParkingService extends ApiClient {
  ParkingService() {
    resourceEndPoint = '/parkings';
  }
}