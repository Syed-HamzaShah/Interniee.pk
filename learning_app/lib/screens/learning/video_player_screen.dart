import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/lesson_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final LessonModel lesson;

  const VideoPlayerScreen({super.key, required this.lesson});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubePlayerController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      print('Initializing video player for lesson: ${widget.lesson.title}');
      print('Video URL: ${widget.lesson.videoUrl}');

      if (widget.lesson.videoUrl == null || widget.lesson.videoUrl!.isEmpty) {
        print('Video URL is null or empty');
        setState(() {
          _error = 'Video URL not available';
          _isLoading = false;
        });
        return;
      }

      // Validate URL format
      final uri = Uri.tryParse(widget.lesson.videoUrl!);
      if (uri == null || (!uri.scheme.startsWith('http'))) {
        setState(() {
          _error = 'Invalid video URL format';
          _isLoading = false;
        });
        return;
      }

      // Check if this is a YouTube URL
      if (_isYouTubeUrl(widget.lesson.videoUrl!)) {
        // Extract YouTube video ID
        final videoId = _extractYouTubeVideoId(widget.lesson.videoUrl!);
        print('Extracted YouTube video ID: $videoId');

        if (videoId == null || videoId.isEmpty) {
          setState(() {
            _error = 'Invalid YouTube URL';
            _isLoading = false;
          });
          return;
        }

        try {
          // Initialize YouTube player
          _youtubePlayerController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: true,
              controlsVisibleAtStart: true,
              hideControls: false,
              disableDragSeek: false,
              loop: false,
              isLive: false,
            ),
          );

          // Add listener for video state changes
          _youtubePlayerController!.addListener(_youtubeVideoListener);

          setState(() {
            _isLoading = false;
            _isInitialized = true;
            _error = null;
          });
        } catch (youtubeError) {
          print('YouTube player initialization error: $youtubeError');
          setState(() {
            _error = 'Failed to initialize YouTube player: $youtubeError';
            _isLoading = false;
          });
        }
        return;
      }

      // For non-YouTube videos, use standard video player
      _videoPlayerController = VideoPlayerController.networkUrl(uri);

      // Add error listener before initialization
      _videoPlayerController!.addListener(_videoErrorListener);

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showOptions: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryGreen,
          handleColor: AppTheme.primaryGreen,
          backgroundColor: AppTheme.darkBorder,
          bufferedColor: AppTheme.textSecondary,
        ),
        placeholder: Container(
          color: AppTheme.darkBackground,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading video...'),
              ],
            ),
          ),
        ),
        autoInitialize: true,
      );

      // Add listener for position changes
      _videoPlayerController!.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _totalDuration = _videoPlayerController!.value.duration;
      });
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _error = 'Failed to load video: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _videoListener() {
    if (_videoPlayerController != null && mounted) {
      setState(() {
        _currentPosition = _videoPlayerController!.value.position;
        _isPlaying = _videoPlayerController!.value.isPlaying;
      });
    }
  }

  void _youtubeVideoListener() {
    if (_youtubePlayerController != null && mounted) {
      setState(() {
        _isPlaying = _youtubePlayerController!.value.isPlaying;
        _currentPosition = _youtubePlayerController!.value.position;
        // YouTube doesn't expose total duration directly in all states,
        // but we can get it from metadata when available
        if (_youtubePlayerController!.metadata.duration.inSeconds > 0) {
          _totalDuration = _youtubePlayerController!.metadata.duration;
        }
      });
    }
  }

  void _videoErrorListener() {
    if (_videoPlayerController != null && mounted) {
      final error = _videoPlayerController!.value.errorDescription;
      if (error != null) {
        setState(() {
          _error = 'Video playback error: $error';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: AppTheme.getHeadingStyle(fontSize: 16),
        ),
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _toggleFullScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player
          Expanded(flex: 3, child: _buildVideoPlayer()),

          // Lesson content
          Expanded(flex: 2, child: _buildLessonContent()),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Check if this is a YouTube URL
    final isYouTube =
        widget.lesson.videoUrl != null &&
        _isYouTubeUrl(widget.lesson.videoUrl!);

    // Show loading state
    if (_isLoading) {
      return Container(
        color: AppTheme.darkBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading video...',
                style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Show YouTube Player for YouTube videos (if initialized successfully)
    if (isYouTube &&
        _isInitialized &&
        _youtubePlayerController != null &&
        _error == null) {
      return Container(
        color: AppTheme.darkBackground,
        child: YoutubePlayer(
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primaryGreen,
          progressColors: ProgressBarColors(
            playedColor: AppTheme.primaryGreen,
            handleColor: AppTheme.primaryGreen,
            backgroundColor: AppTheme.darkBorder,
            bufferedColor: AppTheme.textSecondary.withOpacity(0.5),
          ),
          onReady: () {
            print('YouTube player is ready');
          },
          onEnded: (metadata) {
            print('Video ended');
            // Optionally auto-mark as completed
          },
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Container(
        color: AppTheme.darkBackground,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.statusOverdue,
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                Text(
                  'Video Error',
                  style: AppTheme.getHeadingStyle(fontSize: 20),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  _error!,
                  style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _initializeVideoPlayer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _openVideoInBrowser,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open in Browser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (widget.lesson.videoUrl != null) ...[
                  const SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video URL:',
                          style: AppTheme.getCaptionStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          widget.lesson.videoUrl!,
                          style: AppTheme.getCaptionStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Show regular video player for non-YouTube videos
    if (!isYouTube && _isInitialized && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    // Fallback loading state
    return Container(
      color: AppTheme.darkBackground,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLessonContent() {
    return Container(
      color: AppTheme.darkSurface,
      child: SingleChildScrollView(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson title and progress
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.lesson.title,
                    style: AppTheme.getHeadingStyle(fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSmall,
                    vertical: AppTheme.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    '${widget.lesson.duration} min',
                    style: AppTheme.getCaptionStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            // Video progress
            _buildVideoProgress(),

            const SizedBox(height: AppTheme.spacingMedium),

            // Lesson description
            Text(
              widget.lesson.description,
              style: AppTheme.getBodyStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // Video controls
            _buildVideoControls(),

            const SizedBox(height: AppTheme.spacingLarge),

            // Lesson attachments
            if (widget.lesson.attachments.isNotEmpty) ...[
              Text(
                'Attachments',
                style: AppTheme.getSubheadingStyle(fontSize: 16),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildAttachments(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoProgress() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: AppTheme.getCaptionStyle(fontSize: 12),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: AppTheme.getCaptionStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXSmall),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.darkBorder,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildVideoControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isPlaying ? _pauseVideo : _playVideo,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? 'Pause' : 'Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _markAsCompleted,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark Complete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachments() {
    return Column(
      children: widget.lesson.attachments
          .map(
            (attachment) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(
                    attachment.split('/').last,
                    style: AppTheme.getBodyStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.download),
                  onTap: () => _downloadAttachment(attachment),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  void _playVideo() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.play();
    } else {
      _videoPlayerController?.play();
    }
  }

  void _pauseVideo() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.pause();
    } else {
      _videoPlayerController?.pause();
    }
  }

  void _toggleFullScreen() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.toggleFullScreenMode();
    } else {
      _chewieController?.enterFullScreen();
    }
  }

  void _markAsCompleted() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );

    if (authProvider.userModel != null) {
      await learningProvider.updateLessonProgress(
        userId: authProvider.userModel!.id,
        courseId: widget.lesson.courseId,
        lessonId: widget.lesson.id,
        progress: 1.0,
        timeSpent: _currentPosition.inSeconds,
        isCompleted: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson marked as completed!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _downloadAttachment(String url) {
    // TODO: Implement file download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download feature coming soon!')),
    );
  }

  void _openVideoInBrowser() async {
    if (widget.lesson.videoUrl != null) {
      final uri = Uri.parse(widget.lesson.videoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the video URL'),
              backgroundColor: AppTheme.statusOverdue,
            ),
          );
        }
      }
    }
  }

  bool _isYouTubeUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('m.youtube.com');
  }

  String? _extractYouTubeVideoId(String url) {
    // Use the youtube_player_flutter package's built-in method
    return YoutubePlayer.convertUrlToId(url);
  }
}
