import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/collection/collection_bloc.dart';
import '../../blocs/pet/pet_bloc.dart';
import '../../models/collection.dart';

class PetSelectSheet extends StatefulWidget {
  const PetSelectSheet({super.key});

  @override
  State<PetSelectSheet> createState() => _PetSelectSheetState();
}

class _PetSelectSheetState extends State<PetSelectSheet> {
  CollectionItem? _selected;
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAF5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들바
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 타이틀
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '펫으로 키울 생물을 선택하세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              // 그리드
              Expanded(
                child: BlocBuilder<CollectionBloc, CollectionState>(
                  builder: (context, state) {
                    if (state is! CollectionLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final isSelected = _selected?.id == item.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE0E0E0),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _categoryEmoji(item.speciesCategory),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.speciesName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3E2723),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // 별명 입력 + 확인 버튼
              if (_selected != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    top: 8,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          hintText: '별명을 지어주세요 (예: ${_selected!.speciesName}이)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final nickname = _nicknameController.text.trim().isNotEmpty
                                ? _nicknameController.text.trim()
                                : '${_selected!.speciesName}이';
                            context.read<PetBloc>().add(SelectPetFromCollection(
                              collectionId: _selected!.id,
                              speciesName: _selected!.speciesName,
                              speciesCategory: _selected!.speciesCategory,
                              nickname: nickname,
                            ));
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '이 친구로 결정!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'plant': return '🌿';
      case 'bird': return '🐦';
      case 'insect': return '🐞';
      case 'mammal': return '🐿️';
      case 'amphibian': return '🦎';
      default: return '🐾';
    }
  }
}
