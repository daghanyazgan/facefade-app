import 'package:flutter/material.dart';

class ProcessedPhotoPage extends StatefulWidget {
  final Map<String, dynamic>? photo;
  final String? processType;

  const ProcessedPhotoPage({
    super.key,
    this.photo,
    this.processType,
  });

  @override
  State<ProcessedPhotoPage> createState() => _ProcessedPhotoPageState();
}

class _ProcessedPhotoPageState extends State<ProcessedPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlenmiş Fotoğraf'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _sharePhoto,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 100, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'İşlenmiş Fotoğraf Önizlemesi',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _savePhoto,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reprocess,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Yeniden İşle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74B9FF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePhoto() {}
  void _savePhoto() {}
  void _reprocess() {}
} 