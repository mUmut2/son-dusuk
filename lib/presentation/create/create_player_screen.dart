import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../core/game_random.dart';
import '../../domain/career/career_factory.dart';
import '../../domain/player/player.dart';
import '../../domain/player/player_factory.dart';
import '../../domain/player/position.dart';
import '../../domain/player/turkish_cities.dart';
import '../l10n_labels.dart';
import '../providers.dart';
import '../widgets/player_avatar.dart';

/// Oyuncu yaratma ekranı. [slot] seçilen kayıt slotudur (0-2).
class CreatePlayerScreen extends ConsumerStatefulWidget {
  const CreatePlayerScreen({required this.slot, super.key});

  final int slot;

  @override
  ConsumerState<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends ConsumerState<CreatePlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _city = turkishCities.first;
  PlayerPosition _position = PlayerPosition.forward;
  PreferredFoot _foot = PreferredFoot.right;
  Appearance _appearance = const Appearance();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final player = PlayerFactory.create(
      name: _nameController.text.trim(),
      birthplace: _city,
      position: _position,
      foot: _foot,
      appearance: _appearance,
      random: GameRandom(),
    );
    await ref
        .read(activeCareerProvider.notifier)
        .start(widget.slot, CareerFactory.create(player, GameRandom()));
    if (!mounted) return;
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: PlayerAvatar(appearance: _appearance, size: 96),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return l10n.nameRequired;
                      if (v.length > 24) return l10n.nameTooLong;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _city,
                    decoration: InputDecoration(
                      labelText: l10n.birthplaceLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final city in turkishCities)
                        DropdownMenuItem(value: city, child: Text(city)),
                    ],
                    onChanged: (v) => setState(() => _city = v ?? _city),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.positionLabel, style: textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in PlayerPosition.values)
                        ChoiceChip(
                          label: Text(l10n.positionName(p)),
                          selected: _position == p,
                          onSelected: (_) => setState(() => _position = p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.footLabel, style: textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<PreferredFoot>(
                    segments: [
                      for (final f in PreferredFoot.values)
                        ButtonSegment(value: f, label: Text(l10n.footName(f))),
                    ],
                    selected: {_foot},
                    onSelectionChanged: (s) => setState(() => _foot = s.first),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.appearanceLabel, style: textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _SwatchRow(
                    label: l10n.skinLabel,
                    colors: skinTones,
                    selected: _appearance.skinTone,
                    onSelected: (i) => setState(
                      () => _appearance = Appearance(
                        skinTone: i,
                        hairColor: _appearance.hairColor,
                        kitColor: _appearance.kitColor,
                      ),
                    ),
                  ),
                  _SwatchRow(
                    label: l10n.hairLabel,
                    colors: hairColors,
                    selected: _appearance.hairColor,
                    onSelected: (i) => setState(
                      () => _appearance = Appearance(
                        skinTone: _appearance.skinTone,
                        hairColor: i,
                        kitColor: _appearance.kitColor,
                      ),
                    ),
                  ),
                  _SwatchRow(
                    label: l10n.kitLabel,
                    colors: kitColors,
                    selected: _appearance.kitColor,
                    onSelected: (i) => setState(
                      () => _appearance = Appearance(
                        skinTone: _appearance.skinTone,
                        hairColor: _appearance.hairColor,
                        kitColor: i,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: _saving ? null : _start,
                    child: Text(l10n.startCareer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(label)),
          for (var i = 0; i < colors.length; i++)
            Semantics(
              button: true,
              selected: i == selected,
              label: '$label ${i + 1}',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelected(i),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == selected ? outline : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
