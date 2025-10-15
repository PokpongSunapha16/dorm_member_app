import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:motion_toast/motion_toast.dart'; // ✅ import เดียวพอ

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

      if (!mounted) return;

      // 🎉 Toast เท่ๆ (compatible กับ motion_toast 2.8+)
      MotionToast.success(
        title: const Text(
          "เพิ่มข้อมูลสำเร็จ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        description: const Text(
          "สมาชิกใหม่ถูกเพิ่มเรียบร้อยแล้ว!",
          style: TextStyle(color: Colors.white70),
        ),
        animationCurve: Curves.easeOutBack,
        toastDuration: const Duration(seconds: 3),
        dismissable: true,
      ).show(context); // ✅ ไม่มี position parameter แล้ว

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
                initialValue: status,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // 🔹 สีพื้นหลังปุ่ม
                  foregroundColor: Colors.white, // 🔹 สีข้อความให้เป็น “ขาว”
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'บันทึกสมาชิก',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // ✅ เผื่อกรณี theme override
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
