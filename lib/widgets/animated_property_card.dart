import 'package:flutter/material.dart';
import 'package:antill_estates/utils/animation_utils.dart';

/// Example: Animated Property Card Wrapper
/// Use this to wrap your existing property cards with smooth animations
class AnimatedPropertyCard extends StatefulWidget {
  final Widget child;
  final int index;
  final String? propertyId;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  const AnimatedPropertyCard({
    super.key,
    required this.child,
    this.index = 0,
    this.propertyId,
    this.onTap,
    this.animationDelay,
  });

  @override
  State<AnimatedPropertyCard> createState() => _AnimatedPropertyCardState();
}

class _AnimatedPropertyCardState extends State<AnimatedPropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Use staggered animation for list items
    Widget animatedChild = AnimatedListItem(
      index: widget.index,
      delay: widget.animationDelay ?? const Duration(milliseconds: 50),
      child: widget.child,
    );

    // Add hero animation if propertyId is provided
    if (widget.propertyId != null) {
      animatedChild = Hero(
        tag: 'property-card-${widget.propertyId}',
        child: Material(
          type: MaterialType.transparency,
          child: animatedChild,
        ),
      );
    }

    // Add tap animation if onTap is provided
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: animatedChild,
        ),
      );
    }

    return animatedChild;
  }
}

/// Example: Animated Section Header
class AnimatedSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onSeeAllTap;

  const AnimatedSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationUtils.fadeIn(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            if (trailing != null)
              trailing!
            else if (onSeeAllTap != null)
              TextButton(
                onPressed: onSeeAllTap,
                child: const Text('See All'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Example: Animated Stats Card
class AnimatedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const AnimatedStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      index: index,
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example: Animated Image Card with Hero
class AnimatedImageCard extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final VoidCallback? onTap;
  final double? height;
  final BorderRadius? borderRadius;

  const AnimatedImageCard({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.onTap,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationUtils.scaleIn(
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: height ?? 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height ?? 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: height ?? 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Example: Floating Action Button with Animation
class AnimatedFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationUtils.bounce(
      duration: const Duration(milliseconds: 800),
      child: label != null
          ? FloatingActionButton.extended(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label!),
              backgroundColor: backgroundColor,
            )
          : FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              child: Icon(icon),
            ),
    );
  }
}

/// Example Usage in Your App:
/// 
/// ```dart
/// ListView.builder(
///   itemCount: properties.length,
///   itemBuilder: (context, index) {
///     return AnimatedPropertyCard(
///       index: index,
///       propertyId: properties[index].id,
///       onTap: () {
///         Get.toNamed('/property_details_view', 
///           arguments: {'property': properties[index]});
///       },
///       child: YourPropertyCard(properties[index]),
///     );
///   },
/// )
/// ```

