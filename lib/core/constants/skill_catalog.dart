class SkillCatalog {
  static const customSkill = 'Other';

  static const all = <String>[
    'Networking',
    'Cybersecurity',
    'Cloud Computing',
    'Database Management',
    'SQL',
    'Python',
    'Java',
    'C++',
    'JavaScript',
    'React',
    'Flutter',
    'UI/UX Design',
    'Data Analysis',
    'Machine Learning',
    'Artificial Intelligence',
    'DevOps',
    'Linux',
    'Windows Server',
    'System Administration',
    'IT Support',
    'Business Analysis',
    'Project Management',
    'Marketing',
    'Digital Marketing',
    'Sales',
    'Finance',
    'Accounting',
    'Entrepreneurship',
    'Human Resources',
    'Communication',
    'Leadership',
    'Graphic Design',
    'Video Editing',
    'Photography',
    'Content Writing',
    'Copywriting',
    'Animation',
    '3D Modeling',
    customSkill,
  ];

  static List<String> normalizedUnique(Iterable<String> skills) {
    final result = <String>[];
    for (final skill in skills) {
      final trimmed = skill.trim();
      if (trimmed.isEmpty ||
          result.any(
            (existing) => existing.toLowerCase() == trimmed.toLowerCase(),
          )) {
        continue;
      }
      result.add(trimmed);
    }
    return result;
  }
}
