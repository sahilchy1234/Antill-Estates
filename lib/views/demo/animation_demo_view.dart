import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/utils/animation_utils.dart';

/// Demo view showcasing all available animations
/// This is for demonstration purposes only
class AnimationDemoView extends StatelessWidget {
  const AnimationDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Showcase'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Page Transitions'),
          _buildTransitionDemo('Slide & Fade', '/search_view'),
          _buildTransitionDemo('Scale & Fade', '/gallery_view'),
          _buildTransitionDemo('Slide Up', '/notification_view'),
          _buildTransitionDemo('Shared Axis', '/property_details_view'),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Widget Animations'),
          
          const SizedBox(height: 16),
          _buildAnimationCard(
            'Fade In',
            AnimationUtils.fadeIn(
              child: _buildDemoCard('Fade In Animation', Colors.blue),
            ),
          ),
          
          const SizedBox(height: 16),
          _buildAnimationCard(
            'Slide In From Bottom',
            AnimationUtils.slideInFromBottom(
              child: _buildDemoCard('Slide In Animation', Colors.green),
            ),
          ),
          
          const SizedBox(height: 16),
          _buildAnimationCard(
            'Scale In',
            AnimationUtils.scaleIn(
              child: _buildDemoCard('Scale In Animation', Colors.orange),
              begin: 0.5,
            ),
          ),
          
          const SizedBox(height: 16),
          _buildAnimationCard(
            'Slide From Right',
            AnimationUtils.slideInFromRight(
              child: _buildDemoCard('Slide Right Animation', Colors.purple),
            ),
          ),
          
          const SizedBox(height: 16),
          _buildAnimationCard(
            'Bounce',
            AnimationUtils.bounce(
              child: _buildDemoCard('Bounce Animation', Colors.red),
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Staggered List Example'),
          const SizedBox(height: 16),
          
          ...List.generate(5, (index) {
            return AnimatedListItem(
              index: index,
              delay: const Duration(milliseconds: 100),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries[index % Colors.primaries.length],
                      Colors.primaries[(index + 1) % Colors.primaries.length],
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staggered Item ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Animates with ${(index * 100)}ms delay',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AnimationUtils.fadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionDemo(String title, String route) {
    return AnimationUtils.fadeIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          onPressed: () {
            // Try to navigate if route exists
            try {
              Get.toNamed(route);
            } catch (e) {
              Get.snackbar(
                'Demo',
                'This demonstrates the $title transition',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationCard(String title, Widget animatedWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        animatedWidget,
      ],
    );
  }

  Widget _buildDemoCard(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

