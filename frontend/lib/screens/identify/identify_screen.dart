import 'package:flutter/material.dart';
import '../../config/theme.dart';

class IdentifyScreen extends StatelessWidget {
  const IdentifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NatureTheme.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeroSection(),
              const SizedBox(height: 40),
              _buildCameraCard(context),
              const SizedBox(height: 16),
              _buildGalleryCard(context),
              const SizedBox(height: 32),
              _buildTipsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: NatureTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: NatureTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 식별 준비 완료',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NatureTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '새로운 생물을\n발견해보세요!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: NatureTheme.textDarkBrown,
            height: 1.3,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '카메라로 촬영하거나 갤러리에서 사진을 선택하면\nAI가 어떤 생물인지 알려줘요',
          style: TextStyle(
            fontSize: 15,
            color: NatureTheme.textDarkBrown.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraCard(BuildContext context) {
    return _ActionCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 기능 준비 중입니다')),
        );
      },
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
      ),
      icon: Icons.camera_alt_rounded,
      iconBackgroundColor: Colors.white,
      iconBackgroundOpacity: 0.2,
      title: '카메라로 촬영',
      subtitle: '지금 바로 주변의 생물을 촬영해보세요',
      textColor: Colors.white,
    );
  }

  Widget _buildGalleryCard(BuildContext context) {
    return _ActionCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리 기능 준비 중입니다')),
        );
      },
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFB300), Color(0xFFFFC107)],
      ),
      icon: Icons.photo_library_rounded,
      iconBackgroundColor: Colors.white,
      iconBackgroundOpacity: 0.25,
      title: '갤러리에서 선택',
      subtitle: '이미 찍어둔 사진으로 분석할 수 있어요',
      textColor: Colors.white,
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: NatureTheme.secondaryYellow,
              ),
              SizedBox(width: 8),
              Text(
                '촬영 팁',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: NatureTheme.textDarkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('생물이 잘 보이도록 가까이 촬영해주세요'),
          const SizedBox(height: 8),
          _buildTipItem('밝은 곳에서 촬영하면 더 정확해요'),
          const SizedBox(height: 8),
          _buildTipItem('흔들리지 않게 안정적으로 촬영해주세요'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: NatureTheme.primaryGreen.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: NatureTheme.textDarkBrown.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final VoidCallback onTap;
  final Gradient gradient;
  final IconData icon;
  final Color iconBackgroundColor;
  final double iconBackgroundOpacity;
  final String title;
  final String subtitle;
  final Color textColor;

  const _ActionCard({
    required this.onTap,
    required this.gradient,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconBackgroundOpacity,
    required this.title,
    required this.subtitle,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withValues(
                      alpha: iconBackgroundOpacity,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: textColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
