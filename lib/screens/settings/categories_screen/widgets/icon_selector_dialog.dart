import 'package:flutter/material.dart';

import 'package:habits/constants/habit_icons.dart';

class IconSelectorDialog extends StatelessWidget {
  final String selectedIconName;
  final ValueChanged<String> onIconSelected;

  const IconSelectorDialog({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Icon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: HabitIcons.iconNames.length,
                itemBuilder: (context, index) {
                  final iconName = HabitIcons.iconNames[index];
                  final icon = HabitIcons.getIcon(iconName);
                  final isSelected = iconName == selectedIconName;

                  return InkWell(
                    onTap: () {
                      onIconSelected(iconName);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showIconSelector({
  required BuildContext context,
  required String selectedIconName,
  required ValueChanged<String> onIconSelected,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => IconSelectorDialog(
      selectedIconName: selectedIconName,
      onIconSelected: onIconSelected,
    ),
  );
}
