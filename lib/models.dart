import 'package:pocketbase/pocketbase.dart';

class Member {
  final String id;
  final String name;
  final String roomNumber;
  final String phone;
  final double rentFee;
  final String status;

  Member({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.phone,
    required this.rentFee,
    required this.status,
  });

  factory Member.fromRecord(RecordModel record) {
    return Member(
      id: record.id,
      name: record.data['name'] ?? '',
      roomNumber: record.data['room_number'] ?? '',
      phone: record.data['phone'] ?? '',
      rentFee: (record.data['rent_fee'] ?? 0).toDouble(),
      status: record.data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'room_number': roomNumber,
      'phone': phone,
      'rent_fee': rentFee,
      'status': status,
    };
  }
}
