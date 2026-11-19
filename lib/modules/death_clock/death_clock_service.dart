import '../../core/api_client.dart';
import 'models/pantry_item.dart';

/// Pemanggilan web service Death Clock (`/api/death-clock/`).
/// Halaman cukup memanggil service ini; urusan HTTP, session, dan error ada di [ApiClient].
class DeathClockService {
  const DeathClockService(this._api);

  final ApiClient _api;

  /// Daftar bahan. Tanpa [status], server hanya mengirim bahan aktif (belum diolah).
  Future<List<PantryItem>> fetchItems({
    PantryStatus? status,
    String? category,
    String? storage,
    String? query,
  }) async {
    final data = await _api.get('/api/death-clock/items/', query: {
      'status': status?.code,
      'category': category,
      'storage': storage,
      'q': query?.trim(),
    });
    return PantryItem.listFromJson(data);
  }

  Future<PantryItem> fetchItem(int id) async {
    final data = await _api.get('/api/death-clock/items/$id/');
    return PantryItem.fromJson(data as Map<String, dynamic>);
  }
}
