import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/review.dart';

class QuickReviewSheet extends StatefulWidget {
  const QuickReviewSheet({super.key, required this.place});

  final Place place;

  @override
  State<QuickReviewSheet> createState() => _QuickReviewSheetState();
}

class _QuickReviewSheetState extends State<QuickReviewSheet> {
  double _rating = 4;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentController = TextEditingController();

  List<String> get _availableTags {
    if (widget.place.type == PlaceType.toilet) {
      return ['Open', 'Clean', 'Toilet paper', 'No queue', 'Paid', 'Baby changing', 'Accessible', 'Needs cleaning', 'Closed'];
    }

    return ['Working', 'Bottle-friendly', 'Good pressure', 'Clean', 'Fresh taste', 'Low pressure', 'Broken'];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final fallbackComment = widget.place.type == PlaceType.toilet
        ? 'Quick toilet check submitted.'
        : 'Quick fountain check submitted.';

    Navigator.of(context).pop(
      Review(
        authorName: 'You',
        comment: _commentController.text.trim().isEmpty ? fallbackComment : _commentController.text.trim(),
        rating: _rating,
        minutesAgo: 0,
        tags: _selectedTags.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick review', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(widget.place.name),
            const SizedBox(height: 16),
            Text('Rating: ${_rating.toStringAsFixed(1)}/5'),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 8,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 8),
            Text('What did you notice?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    if (selected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Optional comment',
                hintText: 'Example: clean, open, but no paper',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Submit review and earn +5 pts'),
            ),
          ],
        ),
      ),
    );
  }
}
