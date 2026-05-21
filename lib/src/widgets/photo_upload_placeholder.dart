import 'package:flutter/material.dart';

class PhotoUploadPlaceholder extends StatelessWidget {
  const PhotoUploadPlaceholder({super.key, required this.photoCount});

  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera_outlined),
                const SizedBox(width: 8),
                Text('Photo uploads', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Users will be able to attach toilet or fountain photos to improve trust and verification.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('$photoCount attached')),
                const Chip(label: Text('Supabase Storage ready')),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Attach photo (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
