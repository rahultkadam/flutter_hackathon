import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_fact_provider.dart';
import '../widgets/daily_fact_card.dart';
import '../models/daily_fact_models.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class DailyFactsScreen extends StatefulWidget {
  const DailyFactsScreen({Key? key}) : super(key: key);

  @override
  State<DailyFactsScreen> createState() => _DailyFactsScreenState();
}

class _DailyFactsScreenState extends State<DailyFactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyFactProvider>().loadTodaysFacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 Daily Facts'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarkedFacts(context),
            tooltip: 'Bookmarked Daily Facts',
          ),
        ],
      ),
      body: Consumer<DailyFactProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your daily mind-blowing money facts...'),
                ],
              ),
            );
          }

          if (provider.todaysFacts.isEmpty) {
            return _buildEmptyState(provider);
          }

          return _buildFactsView(provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(DailyFactProvider provider) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 24, desktop: 20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💡', style: TextStyle(fontSize: isDesktop ? 56 : 64)),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12)),
            Text(
              'No Daily Facts Available',
              style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, mobile: 24, desktop: 20), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6)),
            const Text(
              'Check your internet connection and try again',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 24, desktop: 20)),
            ElevatedButton.icon(
              onPressed: () => provider.loadTodaysFacts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // REVERTED: Back to horizontal swipe card view
  Widget _buildFactsView(DailyFactProvider provider) {
    final currentFact = provider.currentFact;
    if (currentFact == null) return const SizedBox();

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final padding = ResponsiveHelper.getPadding(context, mobile: 16, desktop: 12);
    final titleSize = ResponsiveHelper.getFontSize(context, mobile: 16, desktop: 14);

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Daily Interesting Financial Facts : ${provider.currentFactIndex + 1}/${provider.todaysFacts.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  // Removed green badge (Fix #1 preserved)
                ],
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6)),
              LinearProgressIndicator(
                value: (provider.currentFactIndex + 1) /
                    provider.todaysFacts.length,
                backgroundColor: Colors.grey,
                color: AppColors.primaryPurple,
                minHeight: isDesktop ? 6 : 8,
              ),
            ],
          ),
        ),

        // Main card with horizontal swipe (REVERTED)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxContentWidth(context),
              ),
              child: DailyFactCard(
                key: ValueKey(currentFact.id),
                fact: currentFact,
                onSwipeLeft: provider.hasMoreFacts ? () => provider.nextFact() : null,
                onSwipeRight: provider.hasMoreFacts ? () => provider.nextFact() : null,
                onBookmark: () => provider.toggleBookmark(currentFact),
              ),
            ),
          ),
        ),

        // Navigation buttons (RESTORED)
        Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 16, desktop: 12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: provider.currentFactIndex > 0
                      ? () => provider.previousFact()
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: provider.hasMoreFacts
                      ? () => provider.nextFact()
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Fix #4 preserved: Bookmarked facts readable
  void _showBookmarkedFacts(BuildContext context) {
    final bookmarked = context.read<DailyFactProvider>().bookmarkedFacts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📌 Bookmarked Daily Facts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${bookmarked.length} saved',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookmarked.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No bookmarks yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap 🔖 on any fact to save it',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                itemCount: bookmarked.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final fact = bookmarked[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        _showFullTriviaDialog(context, fact);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fact.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fact.headline,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fact.fullExplanation,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap to read full story',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark,
                                  color: AppColors.primaryPurple),
                              onPressed: () {
                                context
                                    .read<DailyFactProvider>()
                                    .toggleBookmark(fact);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullTriviaDialog(BuildContext context, DailyFact fact) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fact.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                fact.headline,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                fact.fullExplanation,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
