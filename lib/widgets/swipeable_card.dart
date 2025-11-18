import 'package:flutter/material.dart';
import '../models/myth_fact_models.dart';

class SwipeableCard extends StatefulWidget {
  final MythFactStatement statement;
  final Function(bool) onSwipe;
  final VoidCallback onCardEnd;

  const SwipeableCard({
    Key? key,
    required this.statement,
    required this.onSwipe,
    required this.onCardEnd,
  }) : super(key: key);

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Offset _offset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
      _isDragging = true;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    // REDUCED threshold for easier swiping
    final isPastThreshold = _offset.dx.abs() > 60 || velocity.abs() > 500;

    if (isPastThreshold) {
      _animateCard(_offset.dx > 0);
    } else {
      _animateCardBack();
    }
  }

  void _animateCard(bool isRight) {
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset(isRight ? 1500 : -1500, 1000),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward().then((_) {
      widget.onSwipe(isRight);
      _reset();
    });
  }

  void _animateCardBack() {
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward();
  }

  void _reset() {
    _offset = Offset.zero;
    _isDragging = false;
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final rotationZ = _offset.dx / 300;
    final opacity = (1 - (_offset.dx.abs() / 500).clamp(0, 1)).toDouble();

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: rotationZ,
          child: Opacity(
            opacity: opacity,
            child: Card(
              margin: const EdgeInsets.all(24),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // FIXED COLORS for better visibility
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.green!,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.green!,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.statement.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 32),
                    // FIXED TEXT COLOR for visibility
                    Text(
                      widget.statement.statement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Colors.black87, // Dark text for readability
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 28,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'MYTH',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 60),
                          Column(
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                size: 28,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'FACT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
