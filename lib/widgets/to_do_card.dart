import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/to_do_models.dart';

class TodoCard extends StatefulWidget {
  final TodoItem task;
  final Function(bool?) onCheckboxChanged;

  const TodoCard({required this.task, required this.onCheckboxChanged});

  @override
  _TodoCardState createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _thumbnailLoaded = false;

  @override
  void initState() {
    super.initState();
    _thumbnailLoaded = widget.task.thumbnailUrl != null && widget.task.thumbnailUrl!.isNotEmpty;
  }

  void _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Could not launch $url');
  }

  bool get _isVideoTask => _thumbnailLoaded && widget.task.url != null && widget.task.url!.isNotEmpty;

  void _showTextTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.teal.shade50, // Light teal background for consistency
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.task.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Description", widget.task.description),
              const SizedBox(height: 12),
              _buildDetailRow("Duration", widget.task.duration),
              const SizedBox(height: 12),
              _buildDetailRow("Category", widget.task.category),
              const SizedBox(height: 12),
              _buildDetailRow("Tags", widget.task.tags.join(", ")),
              const SizedBox(height: 12),
              _buildDetailRow("Completed", widget.task.isCompleted ? "Yes" : "No"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: Colors.teal.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? "N/A" : value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isVideoTask ? Colors.blue.shade500 : Colors.teal.shade400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            _isVideoTask ? bgColor.withOpacity(0.8) : bgColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: InkWell(
        onTap: _isVideoTask ? () => _launchURL(widget.task.url) : () => _showTextTaskDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(_isVideoTask ? 12 : 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail (only for video tasks)
              if (widget.task.thumbnailUrl != null && widget.task.thumbnailUrl!.isNotEmpty)
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.task.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _thumbnailLoaded = false);
                        });
                        return const SizedBox.shrink();
                      },
                      frameBuilder: (_, child, frame, __) {
                        if (frame != null && !_thumbnailLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _thumbnailLoaded = true);
                          });
                        }
                        return child;
                      },
                    ),
                  ),
                ),
              if (_isVideoTask) const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!_isVideoTask)
                          Icon(Icons.task_alt, size: 20, color: Colors.white70),
                        if (!_isVideoTask) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.task.title,
                            style: TextStyle(
                              fontSize: _isVideoTask ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: _isVideoTask ? 13 : 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      maxLines: _isVideoTask ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(_isVideoTask ? Icons.timer : Icons.schedule, widget.task.duration, _isVideoTask),
                        _buildChip(Icons.category, widget.task.category, _isVideoTask),
                        if (_isVideoTask) _buildChip(Icons.videocam, "Video", true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Checkbox(
                value: widget.task.isCompleted,
                onChanged: widget.onCheckboxChanged,
                activeColor: Colors.white,
                checkColor: bgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, bool isVideoTask) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isVideoTask ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(12),
        border: !isVideoTask ? Border.all(color: Colors.white70, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}