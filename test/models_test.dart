import 'package:barcelona_trip_2026/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsing profilo e stato', () {
    final user = UserProfile.fromJson({'id': '1', 'name': 'Nicola', 'role': 'admin'});
    expect(user.isAdmin, isTrue);
    expect(user.name, 'Nicola');

    final state = EntityState.fromJson({
      'profile_id': '1',
      'entity_type': 'place',
      'entity_key': 'sagrada',
      'completed': true,
      'favorite': false,
      'rating': 5,
    });
    expect(state.compoundKey, '1:place:sagrada');
    expect(state.rating, 5);
  });
}
