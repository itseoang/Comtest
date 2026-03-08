import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/collection/collection_bloc.dart';
import '../../blocs/collection/collection_detail_bloc.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../models/collection.dart';
import '../../services/image_validator.dart';
import '../../services/map_launcher.dart';
import '../../data/species_encyclopedia.dart';
import '../../widgets/collection/lifecycle_timeline.dart';
import '../../widgets/collection/stats_chart.dart';
import '../../widgets/diary/diary_write_sheet.dart';
import '../../widgets/diary/stats_boost_result_dialog.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionDetailBloc(
        collectionBloc: context.read<CollectionBloc>(),
      )..add(LoadCollectionDetail(collectionId: collectionId)),
      child: const _CollectionDetailView(),
    );
  }
}

class _CollectionDetailView extends StatefulWidget {
  const _CollectionDetailView();

  @override
  State<_CollectionDetailView> createState() => _CollectionDetailViewState();
}

class _CollectionDetailViewState extends State<_CollectionDetailView> {
  String? _photoPath;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);

      // EXIF 검증
      final result = await ImageValidator.validate(file);
      if (!result.isLikelyDirectPhoto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text('직접 촬영한 사진을 추천해요!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF8D6E63),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      setState(() => _photoPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionDetailBloc, CollectionDetailState>(
      listenWhen: (prev, curr) =>
          curr is CollectionDetailLoaded && curr.boostResult != null,
      listener: (context, state) {
        if (state is CollectionDetailLoaded && state.boostResult != null) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => StatsBoostResultDialog(
              result: state.boostResult!,
              speciesName: state.item.speciesName,
              onDismiss: () {
                context
                    .read<CollectionDetailBloc>()
                    .add(const DismissBoostResult());
                Navigator.of(context).pop();
              },
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: BlocBuilder<CollectionDetailBloc, CollectionDetailState>(
            builder: (context, state) {
              if (state is CollectionDetailLoaded) {
                return Text(state.item.speciesName);
              }
              return const Text('상세 정보');
            },
          ),
        ),
        body: BlocBuilder<CollectionDetailBloc, CollectionDetailState>(
          builder: (context, state) {
            if (state is CollectionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CollectionDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is CollectionDetailLoaded) {
              return _buildContent(context, state.item);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: _photoPath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_photoPath!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _photoPath = null),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD7CCC8),
                  width: 1.5,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFFBCAAA4)),
                  SizedBox(height: 8),
                  Text(
                    '사진 추가하기',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context, CollectionItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          _buildCardHeader(item),
          const SizedBox(height: 16),
          // 사진 영역
          _buildPhotoSection(),
          const SizedBox(height: 16),
          // 능력치 섹션
          _buildSection(
            '능력치',
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: StatsChart(stats: item.stats),
            ),
          ),
          const SizedBox(height: 16),
          // 관찰일기 쓰기 버튼
          if (!item.stats.isMaxed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showDiaryWriteSheet(context, item),
                icon: const Icon(Icons.edit_note),
                label: const Text(
                  '관찰일기 쓰기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (item.stats.isMaxed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    '모든 능력치가 최대입니다!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // 발견 장소
          if (item.locationName != null) ...[
            _buildSection(
              '발견 장소',
              GestureDetector(
                onTap: () => MapLauncher.openNaverMap(
                  placeName: item.locationName!,
                  latitude: item.latitude,
                  longitude: item.longitude,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF5D4037)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.locationName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5D4037),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFBCAAA4),
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 14, color: Color(0xFFBCAAA4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // 발견 날짜
          if (item.discoveredAt != null) ...[
            _buildSection(
              '발견 날짜',
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF5D4037)),
                  const SizedBox(width: 6),
                  Text(
                    '${item.discoveredAt!.year}년 ${item.discoveredAt!.month}월 ${item.discoveredAt!.day}일 ${item.discoveredAt!.hour.toString().padLeft(2, '0')}:${item.discoveredAt!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
                  ),
                  if (item.weather != null && item.weather!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Text(
                      item.weather!,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          // 생애 주기
          _buildLifecycleSection(item.speciesName),
          // 메모
          _buildSection(
            '메모',
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD7CCC8)),
              ),
              child: Text(
                item.notes?.isNotEmpty == true ? item.notes! : '메모가 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: item.notes?.isNotEmpty == true
                      ? const Color(0xFF3E2723)
                      : const Color(0xFF8D6E63),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(CollectionItem item) {
    // 카테고리 아이콘 매핑
    final IconData categoryIcon;
    final Color categoryColor;
    switch (item.speciesCategory) {
      case 'plant':
        categoryIcon = Icons.eco;
        categoryColor = Colors.green;
      case 'bird':
        categoryIcon = Icons.flutter_dash;
        categoryColor = Colors.blue;
      case 'insect':
        categoryIcon = Icons.bug_report;
        categoryColor = Colors.orange;
      case 'mammal':
        categoryIcon = Icons.pets;
        categoryColor = Colors.brown;
      case 'amphibian':
        categoryIcon = Icons.water;
        categoryColor = Colors.teal;
      default:
        categoryIcon = Icons.nature;
        categoryColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor.withOpacity(0.8), categoryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(categoryIcon, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.speciesName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _categoryLabel(item.speciesCategory),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'plant':
        return '식물';
      case 'bird':
        return '조류';
      case 'insect':
        return '곤충';
      case 'mammal':
        return '포유류';
      case 'amphibian':
        return '양서류';
      default:
        return category;
    }
  }

  Widget _buildLifecycleSection(String speciesName) {
    final info = SpeciesEncyclopedia.getInfo(speciesName);
    if (info == null || info.lifecycleStages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSection(
          '생애 주기',
          LifecycleTimeline(stages: info.lifecycleStages),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  void _showDiaryWriteSheet(BuildContext context, CollectionItem item) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<CollectionDetailBloc>(),
        child: DiaryWriteSheet(item: item),
      ),
    ).then((saved) {
      if (saved == true && context.mounted) {
        context.read<QuizBloc>().add(const CheckQuizTrigger(trigger: 'diary'));
      }
    });
  }
}
