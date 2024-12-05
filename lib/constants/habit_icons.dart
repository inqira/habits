import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';

/// Class to manage habit icons with encapsulated access
class HabitIcons {
  /// Default icon name to use
  static const defaultIconName = 'fitness';

  /// Default icon to use when an icon name is not found
  static const defaultIcon = Ionicons.help_circle_outline;

  // Health & Fitness
  static const fitness = 'fitness';
  static const bicycle = 'bicycle';
  static const walk = 'walk';
  static const nutrition = 'nutrition';
  static const water = 'water';
  static const meditate = 'meditate';
  static const sleep = 'sleep';
  static const health = 'health';
  static const noSmoking = 'no_smoking';

  // Productivity
  static const book = 'book';
  static const study = 'study';
  static const work = 'work';
  static const code = 'code';
  static const write = 'write';
  static const task = 'task';
  static const time = 'time';

  // Lifestyle
  static const home = 'home';
  static const clean = 'clean';
  static const cook = 'cook';
  static const music = 'music';
  static const art = 'art';
  static const photo = 'photo';
  static const travel = 'travel';

  // Mind & Soul
  static const pray = 'pray';
  static const journal = 'journal';
  static const mindfulness = 'mindfulness';
  static const gratitude = 'gratitude';

  // Social & Communication
  static const social = 'social';
  static const chat = 'chat';
  static const mail = 'mail';
  static const call = 'call';

  // Finance & Business
  static const budget = 'budget';
  static const business = 'business';
  static const money = 'money';
  static const card = 'card';

  // Others
  static const close = 'close';
  static const questionMark = 'question_mark';
  static const outdoor = 'outdoor';

  /// Get all available icon names
  static List<String> get iconNames => _icons.keys.toList();

  /// Private map of icon names to their corresponding IconData from Ionicons package
  static final Map<String, IconData> _icons = {
    // Health & Fitness
    fitness: Ionicons.fitness_outline,
    bicycle: Ionicons.bicycle_outline,
    walk: Ionicons.walk_outline,
    nutrition: Ionicons.nutrition_outline,
    water: Ionicons.water_outline,
    meditate: Ionicons.leaf_outline,
    sleep: Ionicons.moon_outline,
    health: Ionicons.medical_outline,
    noSmoking: Ionicons.close_circle_outline,

    // Productivity
    book: Ionicons.book_outline,
    study: Ionicons.school_outline,
    work: Ionicons.briefcase_outline,
    code: Ionicons.code_slash_outline,
    write: Ionicons.pencil_outline,
    task: Ionicons.checkbox_outline,
    time: Ionicons.time_outline,

    // Lifestyle
    home: Ionicons.home_outline,
    clean: Ionicons.sparkles_outline,
    cook: Ionicons.restaurant_outline,
    music: Ionicons.musical_notes_outline,
    art: Ionicons.color_palette_outline,
    photo: Ionicons.camera_outline,
    travel: Ionicons.airplane_outline,

    // Mind & Soul
    pray: Ionicons.heart_outline,
    journal: Ionicons.journal_outline,
    mindfulness: Ionicons.flower_outline,
    gratitude: Ionicons.happy_outline,

    // Social & Communication
    social: Ionicons.people_outline,
    chat: Ionicons.chatbubbles_outline,
    mail: Ionicons.mail_outline,
    call: Ionicons.call_outline,

    // Finance & Business
    budget: Ionicons.wallet_outline,
    business: Ionicons.business_outline,
    money: Ionicons.cash_outline,
    card: Ionicons.card_outline,

    // Others
    close: Ionicons.close_outline,
    questionMark: Ionicons.help_circle_outline,
    outdoor: Ionicons.earth_outline,
  };

  /// Returns the icon data for the given name
  /// If the icon name is not found, returns the default icon
  static IconData getIcon(String name) => _icons[name] ?? defaultIcon;

  /// Private constructor to prevent instantiation
  HabitIcons._();
}
