import 'package:url_launcher/url_launcher.dart';

class MapsService {
  Future<void> openCoordinates(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossibile aprire Google Maps.');
    }
  }

  Future<void> openAddress(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossibile aprire Google Maps.');
    }
  }
}
