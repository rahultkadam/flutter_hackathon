import 'package:flutter/material.dart';
import '../models/daily_fact_models.dart';
import '../theme/app_theme.dart';

class DailyFactCard extends StatefulWidget {
  final DailyFact fact;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback onBookmark;

  const DailyFactCard({
    Key? key,
    required this.fact,
    this.onSwipeLeft,
    this.onSwipeRight,
    required this.onBookmark,
  }) : super(key: key);

  @override
  State<DailyFactCard> createState() => _DailyFactCardState();
}

class _DailyFactCardState extends State<DailyFactCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  Offset _offset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // RESTORED: Horizontal swipe gesture handlers
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
      _isDragging = true;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final threshold = MediaQuery.of(context).size.width * 0.3;

    if (_offset.dx.abs() > threshold) {
      if (_offset.dx > 0 && widget.onSwipeRight != null) {
        _animateCardAway(true);
      } else if (_offset.dx < 0 && widget.onSwipeLeft != null) {
        _animateCardAway(false);
      } else {
        _animateCardBack();
      }
    } else {
      _animateCardBack();
    }
  }

  void _animateCardAway(bool toRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset(toRight ? screenWidth * 2 : -screenWidth * 2, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward().then((_) {
      if (toRight && widget.onSwipeRight != null) {
        widget.onSwipeRight!();
      } else if (!toRight && widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      }
      _reset();
    });
  }

  void _animateCardBack() {
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    animation.addListener(() {
      setState(() {
        _offset = animation.value;
      });
    });

    _animationController.forward().then((_) => _reset());
  }

  void _reset() {
    setState(() {
      _offset = Offset.zero;
      _isDragging = false;
      _isExpanded = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final rotationZ = _offset.dx / 1000;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: rotationZ,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryPurple.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fix #2 preserved: No category badge
                          const SizedBox(height: 24),

                          // Emoji
                          Center(
                            child: Text(
                              widget.fact.emoji,
                              style: const TextStyle(fontSize: 72),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Headline
                          Text(
                            widget.fact.headline,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Expand/Collapse button
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              icon: Icon(
                                _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              label: Text(
                                _isExpanded ? 'Show Less' : 'Read Full Story',
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          // Full explanation
                          if (_isExpanded) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.fact.fullExplanation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Swipe hint (horizontal)
                          if (!_isDragging)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back,
                                        size: 16, color: Colors.black54),
                                    SizedBox(width: 8),
                                    Text('Swipe for next trivia',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward,
                                        size: 16, color: Colors.black54),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bookmark button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: widget.onBookmark,
                        icon: Icon(
                          widget.fact.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: widget.fact.isBookmarked
                              ? AppColors.primaryPurple
                              : Colors.grey,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
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
