import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:taggery/ui/components/text.dart';
import 'package:taggery/ui/components/toolbar.dart';

// TODO: make the stream for videoDurationIndicator only emit a value every second, except when the tab is changed (since it would
// otherwise take one second for the new position / length indication to show up). This can likely be done with stream_transform audit
// and a stream controller.

// TODO: fix issue where secondary indicator of timeline only moves correctly up till a certain point. 

// TODO: change animation to animated opacity instead.

/// A toolbar containing controls for video playback.
class VideoControls extends StatelessWidget {
  const VideoControls({super.key, required this.player, this.compact = false});
  final bool compact;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final children = [
      StreamBuilder(
        stream: player.stream.playing,
        builder: (context, snapshot) {
          final isPlaying = snapshot.hasData ? snapshot.data! : false;

          return IconButton(
            tooltip: !isPlaying ? "Resume" : "Pause",
            icon: Icon(
              !isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            onPressed: player.playOrPause,
          );
        },
      ),
      StreamBuilder(
        stream: player.stream.volume,
        builder: (context, snapshot) {
          final isMuted = snapshot.hasData ? snapshot.data! == 0 : false;

          return IconButton(
            tooltip: isMuted ? "Unmute" : "Mute",
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            ),
            onPressed: () {
              isMuted ? player.setVolume(100.0) : player.setVolume(0);
            },
          );
        },
      ),
      VideoDurationIndicator(player: player),
    ];

    return compact
        ? FloatingToolBar.compact(children: children)
        : FloatingToolBar(children: children);
  }
}

class VideoDurationIndicator extends StatefulWidget {
  const VideoDurationIndicator({super.key, required this.player});
  final Player player;

  @override
  State<VideoDurationIndicator> createState() => _VideoDurationIndicatorState();
}

class _VideoDurationIndicatorState extends State<VideoDurationIndicator> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.player.stream.position,
      initialData: widget.player.state.position,
      builder: (context, snapshot) {
        final value = snapshot.data!;
        final videoDuration = widget.player.state.duration;

        final lengthTimeStamp = formatTimestamp(videoDuration);
        final playBackTimeStamp = formatTimestamp(value);

        return TimeStampText("$playBackTimeStamp / $lengthTimeStamp");
      },
    );
  }

  String formatTimestamp(Duration time) {
    final hours = time.inHours;
    final minutes = time.inMinutes % 60;
    final seconds = time.inSeconds % 60;

    final hoursText = getTimeStampPart(hours);
    final minutesText = getTimeStampPart(minutes);
    final secondsText = getTimeStampPart(seconds);

    if (hours > 0) {
      return "$hoursText:$secondsText:$minutesText";
    }
    return "$minutesText:$secondsText";
  }

  String getTimeStampPart(int value) {
    return value < 10 ? "0$value" : "$value";
  }
}

class VideoTimeline extends StatefulWidget {
  const VideoTimeline({super.key, required this.player});
  final Player player;

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  bool _isDragging = false;
  bool _wasPausedBeforeChange = false;
  bool _isHovering = false;
  double _secondaryTrackValue = 0.0;
  double _trackValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.player.stream.position,
      initialData: widget.player.state.position,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          _trackValue = snapshot.data!.inMilliseconds / 1000.0;
        }

        final value = _trackValue;
        final videoDuration = widget.player.state.duration;
        final maxValue = videoDuration == Duration.zero
            ? 1.0
            : videoDuration.inMilliseconds / 1000.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double trackWidth = constraints.maxWidth;

            final double indicatorValue = _isDragging
                ? value
                : _secondaryTrackValue;

            final double thumbFraction = (indicatorValue / maxValue).clamp(
              0.0,
              1.0,
            );
            final double indicatorOffsetX = trackWidth * thumbFraction;

            return MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              onHover: (event) {
                final RenderBox box = context.findRenderObject()! as RenderBox;
                final Offset localPosition = box.globalToLocal(event.position);

                final double newValue =
                    (localPosition.dx / box.size.width) * (maxValue);
                setState(() {
                  _secondaryTrackValue = newValue.clamp(0.0, maxValue);
                });
              },
              child: Stack(
                clipBehavior: .none,
                children: [
                  if (_isHovering || _isDragging) ...[
                    Positioned(
                      left: indicatorOffsetX,
                      bottom: 32.0,
                      child: FractionalTranslation(
                        translation: const Offset(
                          -0.5,
                          0.0,
                        ), // Center horizontally on cursor
                        child: Card(
                          elevation: 0.0,
                          color: Theme.of(context).colorScheme.inverseSurface
                              .withValues(alpha: 0.2),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              formatTimestamp(indicatorValue),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Slider(
                    padding: .all(0),
                    value: value,
                    max: maxValue,
                    secondaryTrackValue: _secondaryTrackValue.clamp(0, 1.0),
                    onChangeStart: (value) {
                      _wasPausedBeforeChange = widget.player.state.playing;
                      widget.player.pause();
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onChangeEnd: (value) {
                      if (_wasPausedBeforeChange) {
                        widget.player.play();
                      }
                      setState(() {
                        _secondaryTrackValue = value;
                        _isDragging = false;
                      });
                    },
                    onChanged: (value) {
                      final duration = Duration(
                        milliseconds: (value * 1000).round(),
                      );
                      widget.player.seek(duration);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String formatTimestamp(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$secs';
    }
    return '$minutes:$secs';
  }
}
