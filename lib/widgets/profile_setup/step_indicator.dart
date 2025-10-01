import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on current step
    final double stepProgress = (currentStep + 1) / totalSteps;
    
    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: stepProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Step counter and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${((currentStep + 1) / totalSteps * 100).round()}% Complete',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Visual step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            return _buildStepDot(index);
          }),
        ),
      ],
    );
  }

  Widget _buildStepDot(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted 
            ? const Color(0xFF10B981)
            : isCurrent 
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted 
              ? const Color(0xFF10B981)
              : isCurrent 
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
      ),
    );
  }
}
