class GhostWidget extends StatefulWidget {
  final AnimationController controller;
  
  const GhostWidget({super.key, required this.controller});
  
  @override
  State<GhostWidget> createState() => _GhostWidgetState();
}

class _GhostWidgetState extends State<GhostWidget> {
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Opacity(
            opacity: _glowAnimation.value,
            child: CustomPaint(
              painter: GhostPainter(),
              size: const Size(60, 80),
            ),
          ),
        );
      },
    );
  }
}