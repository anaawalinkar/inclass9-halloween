import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SpookyApp());
}

class SpookyApp extends StatefulWidget {
  const SpookyApp({super.key});

  @override
  State<SpookyApp> createState() => _SpookyAppState();
}

class _SpookyAppState extends State<SpookyApp> {
  final AudioPlayer _bgPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setSource(AssetSource('audio/spooky_bg.mp3'));
    await _bgPlayer.resume();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooktacular Storybook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A0DAD),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C073A),
        ),
        useMaterial3: true,
      ),
      home: const TitleScreen(),
    );
  }
}

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1A1A2E),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'The Mystery of Midnight Alley',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text('Start the Challenge', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A0DAD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Find the Lucky Bat to win!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Lucky Bat'),
        backgroundColor: const Color(0xFF2C073A),
      ),
      body: const HauntedScreenLayout(),
    );
  }
}

class HauntedScreenLayout extends StatefulWidget {
  const HauntedScreenLayout({super.key});

  @override
  State<HauntedScreenLayout> createState() => _HauntedScreenLayoutState();
}

class _HauntedScreenLayoutState extends State<HauntedScreenLayout> {
  final List<SpookyObjectData> spookyObjects = [
    SpookyObjectData(name: 'Ghost', icon: '👻', isTrap: true),
    SpookyObjectData(name: 'Pumpkin', icon: '🎃', isTrap: true),
    SpookyObjectData(name: 'Spider', icon: '🕷️', isTrap: true),
    SpookyObjectData(name: 'Skull', icon: '💀', isTrap: true),
    SpookyObjectData(name: 'Bat', icon: '🦇', isTrap: false, isWinner: true),
  ];

  final AudioPlayer _effectPlayer = AudioPlayer();

  @override
  void dispose() {
    _effectPlayer.dispose();
    super.dispose();
  }

  void _playTrapSound() async {
    await _effectPlayer.stop();
    await _effectPlayer.play(AssetSource('audio/jumpscare.mp3'));
  }

  void _playWinSound() async {
    await _effectPlayer.stop();
    await _effectPlayer.play(AssetSource('audio/success.mp3'));
  }

  void _handleTap(SpookyObjectData object) {
    if (object.isTrap) {
      _playTrapSound();
    } else if (object.isWinner) {
      _playWinSound();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OutcomeScreen(
          isWinner: object.isWinner,
          heroTag: object.name,
          icon: object.icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: spookyObjects.map((object) {
              return AnimatedSpookyObject(
                key: ValueKey(object.name),
                data: object,
                constraints: constraints,
                onTap: _handleTap,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class SpookyObjectData {
  final String name;
  final String icon;
  final bool isTrap;
  final bool isWinner;

  SpookyObjectData({
    required this.name,
    required this.icon,
    this.isTrap = false,
    this.isWinner = false,
  });
}

class AnimatedSpookyObject extends StatefulWidget {
  final SpookyObjectData data;
  final BoxConstraints constraints;
  final Function(SpookyObjectData) onTap;

  const AnimatedSpookyObject({
    super.key,
    required this.data,
    required this.constraints,
    required this.onTap,
  });

  @override
  State<AnimatedSpookyObject> createState() => _AnimatedSpookyObjectState();
}

class _AnimatedSpookyObjectState extends State<AnimatedSpookyObject> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _top;
  late double _left;
  late double _rotation;
  final double size = 60.0;
  final double speedFactor = 0.00005;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _initializePosition();
  }

  void _initializePosition() {
    final random = Random();
    _top = random.nextDouble() * (widget.constraints.maxHeight - size);
    _left = random.nextDouble() * (widget.constraints.maxWidth - size);
    _rotation = random.nextDouble() * pi * 2;

    _controller.addListener(_updatePosition);
  }

  void _updatePosition() {
    if (!mounted) return;
    setState(() {
      _top = _top + sin(_controller.value * 2 * pi) * 0.5;
      _left = _left + cos(_controller.value * 2 * pi) * 0.5;
      _rotation = _controller.value * 2 * pi;

      if (_top < 0 || _top > widget.constraints.maxHeight - size) {
        _top = _top.clamp(0.0, widget.constraints.maxHeight - size);
      }
      if (_left < 0 || _left > widget.constraints.maxWidth - size) {
        _left = _left.clamp(0.0, widget.constraints.maxWidth - size);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.data),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotation,
              child: Hero(
                tag: widget.data.name,
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.isWinner
                            ? const Color(0xFFFFD700).withOpacity(0.5)
                            : Colors.purple.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.data.icon,
                    style: TextStyle(fontSize: size * 0.8),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OutcomeScreen extends StatelessWidget {
  final bool isWinner;
  final String heroTag;
  final String icon;

  const OutcomeScreen({
    super.key,
    required this.isWinner,
    required this.heroTag,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final String message = isWinner
        ? 'YOU FOUND IT! The Lucky Bat!'
        : 'SPOOKY TRAP! Try again...';
    final Color color = isWinner ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: const Color(0xFF2C073A),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: heroTag,
                child: Text(
                  icon,
                  style: TextStyle(fontSize: 120, color: color),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWinner ? Colors.green : Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Continue Searching', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
