import 'package:flutter/material.dart';
import '../models/myth_fact_models.dart';
import '../theme/app_theme.dart';

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
      duration: const Duration(milliseconds: 350),
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
      end: Offset(isRight ? 1500 : -1500, 800),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward().then((_) {
      widget.onSwipe(isRight);
      _reset();
      widget.onCardEnd();
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

    _animationController.forward().then((_) {
      _reset();
    });
  }

  void _reset() {
    setState(() {
      _offset = Offset.zero;
      _isDragging = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final rotationZ = _offset.dx / 300;
    final opacity = (1 - (_offset.dx.abs() / 500).clamp(0, 1)).toDouble();
    
    // Get screen size for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenHeight < 700; // Consider as mobile if height < 700px
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: rotationZ,
          child: Opacity(
            opacity: opacity,
            child: Card(
              margin: EdgeInsets.all(isMobile ? 16 : 24), // Reduced margin for mobile
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.primaryPurple.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 24 : 36, // Reduced vertical padding for mobile
                  horizontal: isMobile ? 20 : 32, // Reduced horizontal padding for mobile
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Important: Use min to prevent overflow
                    children: [
                      Text(
                        widget.statement.emoji,
                        style: TextStyle(fontSize: isMobile ? 48 : 64), // Smaller emoji for mobile
                      ),
                      SizedBox(height: isMobile ? 20 : 32), // Reduced spacing for mobile
                      Text(
                        widget.statement.statement,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22, // Smaller text for mobile
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: isMobile ? 32 : 48), // Reduced spacing for mobile
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // MYTH section
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 20,
                              vertical: isMobile ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                              ),
                              border: Border.all(
                                color: AppColors.errorRed.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_back, size: isMobile ? 20 : 24, color: AppColors.errorRed),
                                SizedBox(height: isMobile ? 2 : 4),
                                Text('MYTH',
                                    style: TextStyle(
                                        fontSize: isMobile ? 10 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.errorRed)),
                              ],
                            ),
                          ),
                          // FACT section
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 20,
                              vertical: isMobile ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                              border: Border.all(
                                color: AppColors.successGreen.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_forward, size: isMobile ? 20 : 24, color: AppColors.successGreen),
                                SizedBox(height: isMobile ? 2 : 4),
                                Text('FACT',
                                    style: TextStyle(
                                        fontSize: isMobile ? 10 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.successGreen)),
                              ],
                            ),
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
      ),
    );
  }
}
