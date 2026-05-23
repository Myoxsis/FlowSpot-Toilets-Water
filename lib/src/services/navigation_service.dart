import 'package:url_launcher/url_launcher.dart';

import '../models/place.dart';

class NavigationService {
  const NavigationService();

  Future<bool> navigateToPlace(Place place) async {
    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );

    final geoUri = Uri.parse(
      'geo:${place.latitude},${place.longitude}?q=${place.latitude},${place.longitude}(${Uri.encodeComponent(place.name)})',
    );

    if (await canLaunchUrl(geoUri)) {
      return launchUrl(geoUri, mode: LaunchMode.externalApplication);
    }

    if (await canLaunchUrl(googleMapsUri)) {
      return launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
