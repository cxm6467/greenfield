import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../providers/character_provider.dart';
import '../../widgets/character/pixel_art_avatar.dart';

class CharacterProfileScreen extends ConsumerWidget {
  const CharacterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('CHARACTER PROFILE'), centerTitle: true),
      body: characterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (character) {
          if (character == null) {
            return const Center(child: Text('No character found'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  PixelArtAvatar(
                    race: character.race,
                    characterClass: character.characterClass,
                    size: 160,
                  ),
                  const SizedBox(height: 24),

                  // Name and Class
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${character.race.displayName} ${character.characterClass.displayName}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Level & XP
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LEVEL',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${character.level}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'XP',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${character.currentXp}/${character.xpToNextLevel}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value:
                                  character.currentXp / character.xpToNextLevel,
                              minHeight: 12,
                              backgroundColor: Colors.grey[700],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                GreenlandsTheme.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role/Fellowship Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FELLOWSHIP ROLE',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${character.fellowshipRole.emoji} ${character.fellowshipRole.displayName}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            character.fellowshipRole.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATS',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            context,
                            'Strength',
                            character.totalStats['strength'] ?? 0,
                            character.baseStats['strength'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'Constitution',
                            character.totalStats['constitution'] ?? 0,
                            character.baseStats['constitution'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'Dexterity',
                            character.totalStats['dexterity'] ?? 0,
                            character.baseStats['dexterity'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'Wisdom',
                            character.totalStats['wisdom'] ?? 0,
                            character.baseStats['wisdom'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'Intelligence',
                            character.totalStats['intelligence'] ?? 0,
                            character.baseStats['intelligence'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            'Charisma',
                            character.totalStats['charisma'] ?? 0,
                            character.baseStats['charisma'] ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bonuses Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BONUSES',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${character.race.emoji} ${character.race.displayName}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            character.race.bonusText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${character.characterClass.emoji} ${character.characterClass.displayName}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            character.characterClass.bonusText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    int totalStat,
    int baseStat,
  ) {
    final bonus = totalStat - baseStat;
    final bonusText = bonus > 0 ? '+$bonus' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Row(
          children: [
            Text(
              '$totalStat',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: GreenlandsTheme.accentGold,
              ),
            ),
            if (bonus != 0) ...[
              const SizedBox(width: 4),
              Text(
                '($baseStat$bonusText)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: bonus > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
