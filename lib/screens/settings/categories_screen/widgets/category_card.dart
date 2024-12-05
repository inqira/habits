import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:habits/core/ui/spacing.dart';
import 'package:habits/models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final bool isSelectionMode;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isSelectionMode
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacing.verticalSpace8,
              CircleAvatar(
                radius: 22,
                backgroundColor: Color(category.color),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Spacing.verticalSpace16,
              AutoSizeText(
                maxLines: 1,
                category.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              if (category.description != null) ...[
                Spacing.verticalSpace4,
                Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
