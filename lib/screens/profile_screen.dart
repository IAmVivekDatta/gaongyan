import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _ageController.text = user['age']?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _ageController.dispose();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) => Text(
                        userProvider.name ?? 'User Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) => Text(
                        userProvider.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final achievements = userProvider.achievements ?? [];
                  if (achievements.isEmpty) {
                    return const Center(
                      child: Text('No achievements yet'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = achievements[index];
                            return Card(
                              margin: const EdgeInsets.only(right: 16.0),
                              color: achievement['unlocked'] == 1 ? Colors.teal.shade50 : Colors.grey.shade200,
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      achievement['unlocked'] == 1 
                                          ? Icons.emoji_events
                                          : Icons.lock,
                                      color: achievement['unlocked'] == 1 
                                          ? Colors.teal 
                                          : Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      achievement['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: achievement['unlocked'] == 1
                                            ? Colors.teal.shade900
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.star,
                    title: 'Achievement Points',
                    value: '250',
                    color: Colors.teal,
                  ),
                  _buildInfoCard(
                    icon: Icons.book,
                    title: 'Completed Modules',
                    value: '3/12',
                    color: Colors.cyan,
                  ),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Learning Hours',
                    value: '15',
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    'Edit Profile',
                    Icons.edit,
                    () async {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final user = userProvider.user;
                      if (user == null) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Edit Profile'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'Name'),
                                ),
                                TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                ),
                                TextField(
                                  controller: _ageController,
                                  decoration: const InputDecoration(labelText: 'Age'),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await userProvider.updateUser(
                                    user['id'],
                                    {
                                      'name': _nameController.text,
                                      'email': _emailController.text,
                                      'age': int.tryParse(_ageController.text) ?? user['age'],
                                    },
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  _buildButton(
                    'Delete Profile',
                    Icons.delete,
                    () async {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final user = userProvider.user;
                      if (user == null) return;
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete Profile'),
                            content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  await userProvider.deleteUser(user['id']);
                                  if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);
                                  if (mounted) Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  _buildButton(
                    'Achievements',
                    Icons.emoji_events,
                    () {
                      Navigator.pushNamed(context, '/achievements');
                    },
                  ),
                  _buildButton(
                    'Certificates',
                    Icons.card_membership,
                    () {
                      Navigator.pushNamed(context, '/certificates');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
