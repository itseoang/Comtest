import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/collection/collection_bloc.dart';
import '../../models/collection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollectionBloc>().add(const LoadCollections());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CollectionBloc, CollectionState>(
          builder: (context, state) {
            final count = state is CollectionLoaded ? state.items.length : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('내 도감'),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CollectionError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is CollectionLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text(
                      '아직 발견한 생물이 없어요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '첫 생물을 발견해보세요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF3E2723).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildGrid(context, state.items);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<CollectionItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildCard(context, items[index]);
      },
    );
  }

  Widget _buildCard(BuildContext context, CollectionItem item) {
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

    return GestureDetector(
      onTap: () => context.push('/home/collection/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [categoryColor.withOpacity(0.7), categoryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                item.speciesName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
