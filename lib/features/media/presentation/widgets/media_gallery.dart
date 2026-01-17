import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';
import 'package:field_link/features/media/domain/entities/media_entity.dart';

/// Widget that displays a media thumbnail with automatic URL refresh on expiration.
class MediaThumbnail extends StatefulWidget {
  final String mediaId;
  final BoxFit fit;

  const MediaThumbnail({
    super.key,
    required this.mediaId,
    this.fit = BoxFit.cover,
  });

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  String? _url;
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 1;

  @override
  void initState() {
    super.initState();
    _loadThumbnailUrl();
  }

  @override
  void didUpdateWidget(MediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId) {
      _retryCount = 0;
      _loadThumbnailUrl();
    }
  }

  Future<void> _loadThumbnailUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = await GetIt.instance<MediaRepository>().getThumbnailUrl(widget.mediaId);
      if (mounted) {
        setState(() {
          _url = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUrl() async {
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    await _loadThumbnailUrl();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_hasError || _url == null || _url!.isEmpty) {
      return const Center(child: Icon(Icons.error_outline));
    }

    return Image.network(
      _url!,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        // On network error (likely 403/404 from expired URL), try refreshing
        if (_retryCount < _maxRetries) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUrl());
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return const Center(child: Icon(Icons.broken_image_outlined));
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}

/// Grid gallery widget for displaying multiple media items.
class MediaGallery extends StatelessWidget {
  final List<String> mediaIds;
  final Function(String)? onMediaTap;

  const MediaGallery({
    super.key,
    required this.mediaIds,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaIds.length,
      itemBuilder: (context, index) {
        final mediaId = mediaIds[index];
        return GestureDetector(
          onTap: () => _openFullView(context, mediaId),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MediaThumbnail(mediaId: mediaId),
          ),
        );
      },
    );
  }

  void _openFullView(BuildContext context, String mediaId) {
    if (onMediaTap != null) {
      onMediaTap!(mediaId);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaFullViewPage(mediaId: mediaId),
      ),
    );
  }
}

/// Full-screen media viewer with URL refresh on expiration.
class MediaFullViewPage extends StatefulWidget {
  final String mediaId;

  const MediaFullViewPage({super.key, required this.mediaId});

  @override
  State<MediaFullViewPage> createState() => _MediaFullViewPageState();
}

class _MediaFullViewPageState extends State<MediaFullViewPage> {
  String? _url;
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 1;

  @override
  void initState() {
    super.initState();
    _loadDownloadUrl();
  }

  Future<void> _loadDownloadUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = await GetIt.instance<MediaRepository>().getDownloadUrl(widget.mediaId);
      if (mounted) {
        setState(() {
          _url = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUrl() async {
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    await _loadDownloadUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_hasError && _retryCount < _maxRetries)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshUrl,
              tooltip: 'Retry loading',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _url == null || _url!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Could not load image',
              style: TextStyle(color: Colors.white),
            ),
            if (_retryCount < _maxRetries) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _refreshUrl,
                icon: const Icon(Icons.refresh, color: Colors.white70),
                label: const Text('Retry', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ],
        ),
      );
    }

    return InteractiveViewer(
      child: Center(
        child: Image.network(
          _url!,
          errorBuilder: (context, error, stackTrace) {
            // On network error, try refreshing once
            if (_retryCount < _maxRetries) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUrl());
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
