import 'package:flutter/material.dart';

import 'frosted_glass_box.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.menuIconPath,
    required this.menuTitle,
    required this.onPressed,
  });

  final String? menuIconPath;
  final String menuTitle;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: FrostedGlassBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              color: Theme.of(context).primaryColorDark,
              menuIconPath!,
              width: 60,
              height: 60,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                menuTitle,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  color:Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
