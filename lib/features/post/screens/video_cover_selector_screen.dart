import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pictora/router/router.dart';

class VideoCoverSelector extends StatelessWidget {
  final List<File> covers;
  final File videoFile;

  const VideoCoverSelector({
    super.key,
    required this.covers,
    required this.videoFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Video Cover'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: covers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => appRouter.pop(covers[index]),
            child: Image.file(covers[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}

class VideoCoverSelectorDataModel {
  final List<File> covers;
  final File videoFile;

  const VideoCoverSelectorDataModel({
    required this.covers,
    required this.videoFile,
  });
}
