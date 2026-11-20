import '../../core/api_client.dart';
import 'models/food_listing.dart';

class DeadDropService {
  const DeadDropService(this._api);

  final ApiClient _api;

  Future<List<FoodListing>> fetchListings({String? status}) async {
    final data = await _api.get(
      '/api/dead-drop/listings/',
      query: {'status': status},
    );

    return FoodListing.listFromJson(data);
  }

  Future<FoodListing> fetchListing(int id) async {
    final data = await _api.get('/api/dead-drop/listings/$id/');

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Expected a food listing object.');
    }

    return FoodListing.fromJson(data);
  }
}
