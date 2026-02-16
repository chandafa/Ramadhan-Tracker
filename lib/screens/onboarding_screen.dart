import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/app_providers.dart';
import '../services/notification_service.dart';
import 'main_layout.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lottie animation URLs from LottieFiles (free, open-source animations)
  final List<Map<String, String>> _pages = [
    {
      'title': 'Track Your Ibadah',
      'desc':
          'Keep track of your daily prayers and spiritual activities effectively.',
      'lottie':
          'https://lottie.host/48e3ec00-c15f-4672-86e2-6a3e8a303889/zGwqTSfZ7e.json',
    },
    {
      'title': 'Monitor Progress',
      'desc': 'Visualize your daily and overall Ramadhan progress at a glance.',
      'lottie':
          'https://lottie.host/f2f79ff4-4575-4b5b-beef-39f3c0e56b7d/PNfOyVLkY3.json',
    },
    {
      'title': 'Stay Consistent',
      'desc':
          'Build good habits and stay consistent throughout the holy month.',
      'lottie':
          'https://lottie.host/1cfd84ce-16c5-4e22-8e2b-a98f66b75a28/WLIHe0C8dF.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right
            Align(
              alignment: Alignment.topRight,
              child: _currentPage < _pages.length - 1
                  ? TextButton(
                      onPressed: () => _completeOnboarding(),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : const SizedBox(height: 48),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Animation
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: Lottie.network(
                            _pages[index]['lottie']!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if Lottie fails
                              return Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIcon(index),
                                  size: 64,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title with animation
                        AnimatedOpacity(
                          opacity: _currentPage == index ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            _pages[index]['title']!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        AnimatedOpacity(
                          opacity: _currentPage == index ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            _pages[index]['desc']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // Action button
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started 🚀'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.setOnboardingSeen();

    // Request permissions (don't block navigation on failure)
    // Request permissions (don't block navigation on failure)
    final notificationService = NotificationService();
    try {
      // Add timeout to prevent hanging if the plugin is unresponsive
      await notificationService.requestPermissions().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }

    // NOTE: Scheduling is handled by MainLayout in background to prevent freezing

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.checklist_rtl;
      case 1:
        return Icons.bar_chart;
      case 2:
        return Icons.star_border;
      default:
        return Icons.circle;
    }
  }
}
