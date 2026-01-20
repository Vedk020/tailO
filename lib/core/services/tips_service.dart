import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/tip_model.dart';
import '../theme/colors.dart';

class TipsService {
  static List<Tip> getTips() {
    return [
      const Tip(
        title: "Daily Checks",
        subtitle: "Monitor vitals",
        icon: LucideIcons.heart,
        color: TailOColors.coral,
      ),
      const Tip(
        title: "Nutrition",
        subtitle: "Feeding guide",
        icon: LucideIcons.utensils,
        color: Color(0xFFFBEFE6), // Light Cream
      ),
      const Tip(
        title: "Active Play",
        subtitle: "Fun exercises",
        icon: LucideIcons.activity,
        color: Color(0xFF7D7D81), // Grey
      ),
      const Tip(
        title: "Training",
        subtitle: "Behavior tips",
        icon: LucideIcons.brain,
        color: Color(0xFF151515), // Black
      ),
      const Tip(
        title: "Grooming",
        subtitle: "Coat care",
        icon: LucideIcons.scissors,
        color: TailOColors.coral,
      ),
    ];
  }

  static List<Faq> getFaqs() {
    return [
      const Faq(
        question: "How do I set up my TailO Belt?",
        answer:
            "Turn on Bluetooth, go to the Overview page, tap 'Add', and hold the power button on the belt for 3 seconds.",
      ),
      const Faq(
        question: "What do the health alerts mean?",
        answer:
            "Red alerts indicate vitals outside the normal range. Yellow alerts suggest minor irregularities.",
      ),
      const Faq(
        question: "How often should I charge the device?",
        answer:
            "With average use, the battery lasts 3-4 days. We recommend charging it when it drops below 20%.",
      ),
      const Faq(
        question: "Can I track multiple pets?",
        answer:
            "Yes! You can add up to 5 pets in one account. Use the switcher on the Home or Profile page.",
      ),
      const Faq(
        question: "Is the device waterproof?",
        answer:
            "The TailO belt is IP67 water-resistant. It can withstand rain and splashes but is not meant for swimming.",
      ),
      const Faq(
        question: "How do I share my pet's profile?",
        answer:
            "Go to the Profile page, tap and hold your pet's card, and click 'Share ID Card'.",
      ),
    ];
  }
}
