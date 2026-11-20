import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import 'dead_drop_service.dart';
import 'models/food_listing.dart';

class DeadDropDetailScreen extends StatefulWidget {
  const DeadDropDetailScreen({super.key, required this.listingId});

  final int listingId;

  @override
  State<DeadDropDetailScreen> createState() => _DeadDropDetailScreenState();
}

class _DeadDropDetailScreenState extends State<DeadDropDetailScreen> {
  late Future<FoodListing> _listing;

  @override
  void initState() {
    super.initState();
    _listing = _loadListing();
  }

  Future<FoodListing> _loadListing() {
    final api = context.read<ApiClient>();
    return DeadDropService(api).fetchListing(widget.listingId);
  }

  void _reload() {
    setState(() {
      _listing = _loadListing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail makanan')),
      body: FutureBuilder<FoodListing>(
        future: _listing,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Detail makanan tidak bisa dimuat.'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final listing = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                listing.foodName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text('Kondisi dan deskripsi'),
              Text(listing.description),
              const SizedBox(height: 16),
              Text('Lokasi penjemputan'),
              Text(listing.pickupLocation),
              const SizedBox(height: 16),
              Text('Jadwal penjemputan'),
              Text(listing.pickupTime.toLocal().toString()),
              const SizedBox(height: 16),
              Text('Catatan titik temu'),
              Text(listing.pickupNotes),
              const SizedBox(height: 16),
              Text('Status: ${listing.statusLabel}'),
              Text('Dibagikan oleh: ${listing.owner}'),
            ],
          );
        },
      ),
    );
  }
}
