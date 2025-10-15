import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models.dart';

class MemberUpdateView extends StatefulWidget {
  final Member member;
  const MemberUpdateView({super.key, required this.member});

  @override
  State<MemberUpdateView> createState() => _MemberUpdateViewState();
}

class _MemberUpdateViewState extends State<MemberUpdateView> {
  final pb = PocketBase('http://127.0.0.1:8090');
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController rentController;
  String status = 'active';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.member.name);
    phoneController = TextEditingController(text: widget.member.phone);
    rentController = TextEditingController(
      text: widget.member.rentFee.toString(),
    );
    status = widget.member.status;
  }

  Future<void> updateMember() async {
    await pb
        .collection('members')
        .update(
          widget.member.id,
          body: {
            'name': nameController.text,
            'phone': phoneController.text,
            'rent_fee': double.parse(rentController.text),
            'status': status,
          },
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลสมาชิก')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'ชื่อ'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'เบอร์โทร'),
            ),
            TextField(
              controller: rentController,
              decoration: const InputDecoration(labelText: 'ค่าห้องพัก'),
            ),
            DropdownButtonFormField(
              value: status,
              decoration: const InputDecoration(labelText: 'สถานะ'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('อยู่')),
                DropdownMenuItem(value: 'inactive', child: Text('ย้ายออก')),
              ],
              onChanged: (val) => setState(() => status = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateMember,
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
