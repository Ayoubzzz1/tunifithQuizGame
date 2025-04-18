import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isGradient;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final Color? shadowColor;
  final Widget? customChild;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.width,
    this.height,
    this.isGradient = false,
    this.gradientColors,
    this.borderRadius,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 0.5,
    this.padding,
    this.showShadow = true,
    this.shadowColor,
    this.customChild,
  }) : super(key: key);

  // Factory constructor for primary action button (like your start game button)
  factory CustomButton.primary({
    required String text,
    required VoidCallback onPressed,
    IconData? leadingIcon,
    double? width,
    double? height = 65,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      isGradient: true,
      gradientColors: [Colors.green[600]!, Colors.green[800]!],
      borderRadius: BorderRadius.circular(18),
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: width,
      height: height,
      shadowColor: Colors.green.withOpacity(0.4),
    );
  }

  // Factory constructor for secondary button (fixed to return CustomButton)
  factory CustomButton.secondary({
    required String text,
    required VoidCallback onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    Widget? badge,
    ThemeData? theme,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      textColor: theme?.primaryColor ?? Colors.blue,
      backgroundColor: Colors.white,
      showShadow: true,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      customChild: Builder(
          builder: (context) {
            final currentTheme = theme ?? Theme.of(context);
            final isSmallScreen = MediaQuery.of(context).size.width < 400;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: currentTheme.primaryColor.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  if (leadingIcon != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: currentTheme.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        leadingIcon,
                        size: 24,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                  if (leadingIcon != null) const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 17 : 19,
                        fontWeight: FontWeight.w600,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    badge,
                    const SizedBox(width: 10),
                  ],
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: currentTheme.primaryColor,
                      size: 28,
                    ),
                ],
              ),
            );
          }
      ),
    );
  }

  // Factory constructor for circle button (like your start timer button)
  factory CustomButton.circle({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double size = 120,
    double fontSize = 40,
    ThemeData? theme,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.all(0),
    );
  }

  // Factory constructor for menu button (for HomeScreen)
  factory CustomButton.menu({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double height = 80,
  }) {
    return CustomButton(
      text: title,
      onPressed: onTap,
      height: height,
      showShadow: true,
      shadowColor: color.withOpacity(0.3),
      customChild: Builder(
          builder: (context) {
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: color.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  // Factory constructor for social button (for HomeScreen)
  factory CustomButton.social({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomButton(
      text: '', // Empty text for social buttons
      onPressed: onTap,
      showShadow: true,
      shadowColor: Colors.black.withOpacity(0.1),
      customChild: Builder(
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(18),
        boxShadow: showShadow
            ? [
          BoxShadow(
            color: shadowColor ?? theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
        gradient: isGradient
            ? LinearGradient(
          colors: gradientColors ??
              [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.7),
              ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
            : null,
      ),
      child: customChild ?? ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isGradient ? Colors.transparent : backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(18),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 24),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: letterSpacing,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              Icon(trailingIcon, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// Badge widget specifically for the theme button
class ButtonBadge extends StatelessWidget {
  final String text;
  final ThemeData? theme;

  const ButtonBadge({
    Key? key,
    required this.text,
    this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: currentTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 15,
          color: currentTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}