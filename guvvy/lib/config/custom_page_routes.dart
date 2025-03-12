// lib/core/routes/custom_page_routes.dart
import 'package:flutter/material.dart';

class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadeScaleRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutCubic;
            var curveTween = CurveTween(curve: curve);
            
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              animation.drive(curveTween),
            );
            
            var scaleAnimation = Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(
              animation.drive(curveTween),
            );
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutCubic;
            var curveTween = CurveTween(curve: curve);
            
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(
              animation.drive(curveTween),
            );
            
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              animation.drive(curveTween),
            );
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}