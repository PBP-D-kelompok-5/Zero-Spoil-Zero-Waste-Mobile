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
  late Future<List<FoodListing>> _listings;

  @override
  void initState() {
    super.initState();
    _listings = _loadListings();
  }

  Future<List<FoodListing>> _loadListings() {
    final api = context.read<ApiClient>();
    return DeadDropService(api).fetchListings(status: 'available');
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
      body: FutureBuilder<List<FoodListing>>(
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
            return const Center(
              child: Text('Belum ada makanan yang tersedia.'),
            );
          }

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(listing.foodName),
                  subtitle: Text(listing.pickupLocation),
                  trailing: Text(listing.statusLabel),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeadDropDetailScreen(listingId: listing.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
