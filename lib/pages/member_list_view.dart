import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models.dart';
import 'member_update_view.dart';
import 'add_member_view.dart';
import 'package:motion_toast/motion_toast.dart';

class MemberListView extends StatefulWidget {
  const MemberListView({super.key});

  @override
  State<MemberListView> createState() => _MemberListViewState();
}

class _MemberListViewState extends State<MemberListView> {
  final pb = PocketBase('http://127.0.0.1:8090');
  List<Member> members = [];
  List<Member> filteredMembers = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final records = await pb.collection('members').getFullList();
    setState(() {
      members = records.map((r) => Member.fromRecord(r)).toList();
      filteredMembers = List.from(members);
    });
  }

  void filterMembers(String query) {
    setState(() {
      filteredMembers = members
          .where(
            (m) => m.name.toLowerCase().contains(query.toLowerCase().trim()),
          )
          .toList();
    });
  }

  Future<void> deleteMember(String id) async {
    await pb.collection('members').delete(id);
    if (!mounted) return;

    MotionToast.error(
      title: const Text(
        "ลบข้อมูลเรียบร้อย!",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      description: const Text(
        "สมาชิกถูกลบออกจากระบบแล้ว",
        style: TextStyle(color: Colors.white70),
      ),
      toastDuration: const Duration(seconds: 3),
      animationCurve: Curves.easeOutBack,
      dismissable: true,
    ).show(context);

    fetchMembers();
  }

  void clearSearch() {
    searchController.clear();
    filterMembers('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'PP SNP Dormitory VIP',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.3,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'เพิ่มสมาชิก',
            backgroundColor: Colors.green,
            onTap: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMemberView()),
              );
              if (added == true) fetchMembers();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            label: 'รีเฟรชข้อมูล',
            backgroundColor: Colors.blue,
            onTap: fetchMembers,
          ),
          SpeedDialChild(
            child: const Icon(Icons.cleaning_services),
            label: 'ล้างช่องค้นหา',
            backgroundColor: Colors.orange,
            onTap: clearSearch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 ช่องค้นหาชื่อสมาชิก
            TextField(
              controller: searchController,
              onChanged: filterMembers,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อสมาชิก...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ ใช้ ListView แทน Grid
            Expanded(
              child: ListView.builder(
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final isActive = member.status == 'active';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: isActive
                            ? Colors.indigo.shade200
                            : Colors.grey.shade400,
                        child: Icon(
                          Icons.person,
                          color: isActive ? Colors.indigo : Colors.white,
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('ห้อง: ${member.roomNumber}'),
                          Text(
                            'ค่าเช่า: ${member.rentFee.toStringAsFixed(0)}฿',
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'อยู่' : 'ย้ายออก',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteMember(member.id),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberUpdateView(member: member),
                          ),
                        );
                        fetchMembers();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
