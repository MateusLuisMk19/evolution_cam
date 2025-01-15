import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:flutter/material.dart';

class CameraSettingsBar extends StatelessWidget {
  final bool isFlashOn, isTimerOn, isGridOn, isOpacityOn;
  final VoidCallback onFlashToggle,
      onTimerToggle,
      onGridToggle,
      onOpacityToggle;
  final Color myColor;
  final double opacityLevel;
  final int timerValue;
  final Function(double) onOpacityChange;

  const CameraSettingsBar({
    Key? key,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.isTimerOn,
    required this.onTimerToggle,
    required this.isGridOn,
    required this.onGridToggle,
    required this.isOpacityOn,
    required this.onOpacityToggle,
    this.myColor = AppColors.backgroundLight,
    this.opacityLevel = 0.5,
    required this.onOpacityChange,
    required this.timerValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.timer,
                      color: isTimerOn ? AppColors.errorDark : myColor,
                    ),
                    onPressed: onTimerToggle,
                  ),
                  Positioned(
                    right: timerValue == 10 ? 0 : 5,
                    top: 5,
                    child: VisibilityBox(
                      inviseble: !isTimerOn,
                      child: Text(timerValue.toString()),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.opacity,
                  color: isOpacityOn ? AppColors.primaryDark : myColor,
                ),
                onPressed: onOpacityToggle,
              ),
              IconButton(
                icon: Icon(
                  Icons.grid_3x3_outlined,
                  color: isGridOn ? AppColors.secondaryDark : myColor,
                ),
                onPressed: onGridToggle,
              ),
              IconButton(
                icon: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: isFlashOn ? Colors.yellow : myColor,
                ),
                onPressed: onFlashToggle,
              ),
            ],
          ),
          VisibilityBox(
            inviseble: !isOpacityOn,
            child: Card(
              color: myColor,
              child: SizedBox(
                width: 200,
                height: 50,
                child: Slider(
                  min: 0.1,
                  max: 1,
                  activeColor: AppColors.primaryDark,
                  value: opacityLevel,
                  onChanged: (value) {
                    onOpacityChange(value);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CameraActionBar extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleCamera;
  final VoidCallback onBack;
  final Color myColor;

  const CameraActionBar({
    Key? key,
    required this.onCapture,
    required this.onToggleCamera,
    required this.onBack,
    this.myColor = AppColors.backgroundLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: myColor,
          ),
          onPressed: onBack,
        ),
        ElevatedButton(
          onPressed: onCapture,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0.5),
            shape: CircleBorder(),
            backgroundColor: myColor,
          ),
          child: Icon(
            Icons.circle,
            size: 60,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.flip_camera_android,
            color: myColor,
          ),
          onPressed: onToggleCamera,
        ),
      ],
    );
  }
}

class TimerOverlay extends StatelessWidget {
  final int seconds;

  const TimerOverlay({Key? key, required this.seconds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$seconds',
          style: TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FocusIndicator extends StatefulWidget {
  const FocusIndicator({Key? key}) : super(key: key);

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
