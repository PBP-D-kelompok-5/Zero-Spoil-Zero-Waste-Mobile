import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/death_clock/models/pantry_item.dart';
import 'package:zero_spoil_zero_waste_mobile/theme/app_theme.dart';

import 'fixtures.dart';

void main() {
  test('PantryItem.listFromJson membaca JSON dari serializer Django', () {
    final items = PantryItem.listFromJson(jsonDecode(pantryItemsJson));

    expect(items, hasLength(4));
    expect(items.map((item) => item.status), [
      PantryStatus.flatlining,
      PantryStatus.critical,
      PantryStatus.stable,
      PantryStatus.resurrected,
    ]);

    final susu = items[1];
    expect(susu.name, 'Susu UHT');
    expect(susu.quantityLabel, '2 liter');
    expect(susu.categoryLabel, 'Produk Olahan Susu');
    expect(susu.daysLeft, 2);
    expect(susu.notes, 'Buka segel kemarin');
    expect(susu.resurrectedAt, isNull);
    expect(susu.createdAt, isNotNull);

    final beras = items[2];
    expect(beras.expiryIsEstimate, isTrue);
    expect(beras.storageLabel, 'Rak dapur');

    final kaldu = items[3];
    expect(kaldu.isResurrected, isTrue);
    expect(kaldu.resurrectedAt, isNotNull);
  });

  test('PantryStatus sama dengan kode dan warna di situs', () {
    expect(PantryStatus.fromCode('CRITICAL'), PantryStatus.critical);
    expect(PantryStatus.critical.tone, PnTone.ember);
    expect(PantryStatus.flatlining.tone, PnTone.blood);
    expect(PantryStatus.resurrected.code, 'RESURRECTED');
  });
}
