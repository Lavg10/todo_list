import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<void> uploadAvatar(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final fileExt = file.path.split('.').last;
    final filePath = 'avatars/${user.id}.$fileExt';

    await supabase.storage
        .from('avatars')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    // Bust cache with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final publicUrl =
        "${supabase.storage.from('avatars').getPublicUrl(filePath)}?t=$timestamp";

    // Upsert profile with avatar_url
    await supabase.from('profiles').upsert({
      'id': user.id,
      'avatar_url': publicUrl,
    });
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile({
    required String fullName,
    String? address,
    String? contactNumber,
    int? age,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      if (address != null) 'address': address,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (age != null) 'age': age,
    });
  }
}
