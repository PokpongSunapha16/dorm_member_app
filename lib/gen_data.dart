import 'package:faker/faker.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models.dart';

Future<void> main() async {
  final pb = PocketBase('http://127.0.0.1:8090');
  final faker = Faker();

  for (int i = 0; i < 20; i++) {
    final member = Member(
      id: '',
      name: faker.person.name(),
      roomNumber: 'A${faker.randomGenerator.integer(50, min: 1)}',
      phone: faker.phoneNumber.us(),
      rentFee: faker.randomGenerator.integer(4000, min: 2000).toDouble(),
      status: faker.randomGenerator.boolean() ? 'active' : 'inactive',
    );

    await pb.collection('members').create(body: member.toJson());
    print('✅ เพิ่มสมาชิก: ${member.name} ห้อง ${member.roomNumber}');
  }

  print('\n🎉 สร้างข้อมูลจำลองเรียบร้อยแล้ว!');
}
