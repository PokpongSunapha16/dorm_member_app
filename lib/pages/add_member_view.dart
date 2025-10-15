import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AddMemberView extends StatefulWidget {
  const AddMemberView({super.key});

  @override
  State<AddMemberView> createState() => _AddMemberViewState();
}

class _AddMemberViewState extends State<AddMemberView> {
  final pb = PocketBase('http://127.0.0.1:8090');
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final roomController = TextEditingController();
  final phoneController = TextEditingController();
  final rentController = TextEditingController();
  String status = 'active';

  Future<void> addMember() async {
    if (_formKey.currentState!.validate()) {
      await pb
          .collection('members')
          .create(
            body: {
              'name': nameController.text,
              'room_number': roomController.text,
              'phone': phoneController.text,
              'rent_fee': double.parse(rentController.text),
              'status': status,
            },
          );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มสมาชิกใหม่')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสมาชิก'),
                validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              TextFormField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'หมายเลขห้อง'),
                validator: (v) => v!.isEmpty ? 'กรุณากรอกห้อง' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
              ),
              TextFormField(
                controller: rentController,
                keyboardType: TextInputType.number,
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
                onPressed: addMember,
                child: const Text('บันทึกสมาชิก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
