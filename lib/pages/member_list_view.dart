import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models.dart';
import 'member_update_view.dart';
import 'add_member_view.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold),
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
          // ➕ เพิ่มสมาชิกใหม่
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

          // 🔄 รีเฟรชข้อมูล
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            label: 'รีเฟรชข้อมูล',
            backgroundColor: Colors.blue,
            onTap: fetchMembers,
          ),

          // 🧹 ล้างช่องค้นหา
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
            Expanded(
              child: GridView.builder(
                itemCount: filteredMembers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 🔹 ปรับเป็น “แถวละ 5 การ์ด”
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final isActive = member.status == 'active';
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberUpdateView(member: member),
                        ),
                      );
                      fetchMembers();
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isActive
                                ? [
                                    Colors.indigo.shade300,
                                    Colors.indigo.shade100,
                                  ]
                                : [Colors.grey.shade400, Colors.grey.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: isActive ? Colors.indigo : Colors.grey,
                              ),
                            ),
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ห้อง ${member.roomNumber}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${member.rentFee.toStringAsFixed(0)}฿',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'อยู่' : 'ย้ายออก',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => deleteMember(member.id),
                            ),
                          ],
                        ),
                      ),
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
