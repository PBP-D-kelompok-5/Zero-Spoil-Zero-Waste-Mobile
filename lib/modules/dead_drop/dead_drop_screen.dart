import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import 'dead_drop_service.dart';
import 'models/food_listing.dart';
import 'dead_drop_detail_screen.dart';

class DeadDropScreen extends StatefulWidget {
  const DeadDropScreen({super.key});

  @override
  State<DeadDropScreen> createState() => _DeadDropScreenState();
}

class _DeadDropScreenState extends State<DeadDropScreen> {
  static const _statuses = <String, String>{
    'available': 'Tersedia',
    'reserved': 'Reservasi',
    'claimed': 'Riwayat klaim',
  };

  String _activeStatus = 'available';
  late Future<List<FoodListing>> _listings;

  @override
  void initState() {
    super.initState();
    _listings = _loadListings();
  }

  Future<List<FoodListing>> _loadListings() {
    final api = context.read<ApiClient>();
    return DeadDropService(api).fetchListings(status: _activeStatus);
  }

  void _selectStatus(String status) {
    if (status == _activeStatus) return;

    setState(() {
      _activeStatus = status;
      _listings = _loadListings();
    });
  }

  void _reload() {
    setState(() {
      _listings = _loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Dead Drop')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _statuses.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: _activeStatus == entry.key,
                    onSelected: (_) => _selectStatus(entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FoodListing>>(
              future: _listings,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Listing tidak bisa dimuat.'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _reload,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final listings = snapshot.data ?? [];
                if (listings.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada makanan ${_statuses[_activeStatus]!.toLowerCase()}.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(listing.foodName),
                        subtitle: Text(listing.pickupLocation),
                        trailing: Text(listing.statusLabel),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DeadDropDetailScreen(
                                listingId: listing.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
