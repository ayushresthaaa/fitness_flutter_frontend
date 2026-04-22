import 'package:flutter/material.dart';

// ── colors ──────────────────────────────────────────
const kPrimary = Color(0xFF1B3A6B);
const kBackground = Color(0xFFF5F5F5);
const kWhite = Colors.white;
const kTextDark = Color(0xFF212121);
const kTextGrey = Color(0xFF9E9E9E);
const kTextHint = Color(0xFFBDBDBD);
const kRed = Color(0xFFF44336);
const kRedLight = Color(0xFFFFCDD2);
const kGreen = Color(0xFF388E3C);
const kDivider = Color(0xFFF0F0F0);
const kPrimaryLight = Color(0xFFE8EEF7); // light navy tint

// big blue button with white text
// use for main actions like Save, Finish Workout
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: kWhite, strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                ),
              ),
      ),
    );
  }
}

// red outlined button with red text
// use for delete actions
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const DangerButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kRedLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kRed,
          ),
        ),
      ),
    );
  }
}

// white outlined button with plus icon and primary color text
// use for Add Exercise, Add Set
class AddButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AddButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kTextHint, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: kPrimary, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// simple text field with white background and rounded corners
// use for routine name, workout title etc
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? kWhite : kBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: kTextGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// app bar with white background, dark text, and optional back button and actions
// consistent top bar used on every screen
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppTopBar({super.key, required this.title, this.actions, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kTextDark),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: kTextDark,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// bottom action bar with white background and padding, used for Save button on workout edit screen, Finish Workout button on workout screen etc
// white container pinned at bottom of screen
class BottomBar extends StatelessWidget {
  final Widget child;

  const BottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: child,
    );
  }
}

// empty state
// shown when a list has no items
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: kTextHint),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kTextGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: kTextHint),
          ),
        ],
      ),
    );
  }
}

// section label
// grey uppercase label like "EXERCISES (3)"
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kTextGrey,
        letterSpacing: 0.5,
      ),
    );
  }
}
