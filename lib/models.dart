class MediaCategory {
  final String id;
  final String name;
  final List<MediaCategory>? subCategories; // 子分类

  const MediaCategory({
    required this.id,
    required this.name,
    this.subCategories,
  });
}

class MediaItem {
  final String id;
  final String title;
  final String filePath;
  final String categoryId;

  const MediaItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.categoryId,
  });
}

const List<MediaCategory> videoCategories = [
  MediaCategory(
    id: 'doc',
    name: '纪录片',
    subCategories: [
      MediaCategory(id: 'doc_douban2022', name: '豆瓣2022评分Top10纪录片'),
      MediaCategory(id: 'doc_food', name: '美食纪录片'),
      MediaCategory(id: 'doc_economy', name: '经济纪录片'),
      MediaCategory(id: 'doc_science', name: '科学纪录片'),
      MediaCategory(id: 'doc_society', name: '社会纪录片'),
      MediaCategory(id: 'doc_biology', name: '生物地理纪录片'),
      MediaCategory(id: 'doc_military', name: '军事纪录片'),
      MediaCategory(id: 'doc_person', name: '人物纪录片'),
      MediaCategory(id: 'doc_history', name: '人文历史纪录片'),
      MediaCategory(id: 'doc_4k', name: '4K REMUX纪录片'),
    ],
  ),
  MediaCategory(
    id: 'tech',
    name: '科技',
    subCategories: [
      MediaCategory(id: 'tech_design', name: '工业设计'),
      MediaCategory(id: 'tech_manufacture', name: '制造原理'),
      MediaCategory(id: 'tech_agriculture', name: '农业技术'),
      MediaCategory(id: 'tech_computer', name: '电脑科技'),
      MediaCategory(id: 'tech_veterinary', name: '畜牧兽医'),
      MediaCategory(id: 'tech_internet', name: '互联网'),
    ],
  ),
  MediaCategory(
    id: 'music',
    name: '音乐',
    subCategories: [
      MediaCategory(id: 'music_instrument', name: '声乐器乐'),
      MediaCategory(id: 'music_opera', name: '梨园百家'),
      MediaCategory(id: 'music_pop', name: '流行音乐'),
    ],
  ),
  MediaCategory(
    id: 'kids',
    name: '少儿',
    subCategories: [
      MediaCategory(id: 'kids_animation', name: '动画片'),
      MediaCategory(id: 'kids_course', name: '课程'),
    ],
  ),
  MediaCategory(
    id: 'movie',
    name: '电影',
    subCategories: [
      MediaCategory(id: 'movie_war', name: '战争电影'),
      MediaCategory(id: 'movie_india', name: '印度电影'),
      MediaCategory(id: 'movie_classic', name: '经典电影'),
    ],
  ),
  MediaCategory(
    id: 'school',
    name: '学堂',
    subCategories: [
      MediaCategory(id: 'school_magic', name: '魔术表演'),
      MediaCategory(id: 'school_learning', name: '高效学习'),
      MediaCategory(id: 'school_finance', name: '财商网赚'),
      MediaCategory(id: 'school_programming', name: '编程开发'),
      MediaCategory(id: 'school_economics', name: '经济学'),
      MediaCategory(id: 'school_social', name: '社交情商'),
      MediaCategory(id: 'school_esports', name: '电子竞技'),
      MediaCategory(id: 'school_ebusiness', name: '电子商务'),
      MediaCategory(id: 'school_dialect', name: '方言学习'),
      MediaCategory(id: 'school_broadcast', name: '播音主持'),
      MediaCategory(id: 'school_photography', name: '摄影教程'),
      MediaCategory(id: 'school_motivation', name: '成功励志'),
      MediaCategory(id: 'school_business', name: '商业管理'),
      MediaCategory(id: 'school_philosophy', name: '哲学'),
      MediaCategory(id: 'school_culture', name: '历史文化'),
      MediaCategory(id: 'school_office', name: '办公宝典'),
      MediaCategory(id: 'school_design', name: '创意设计'),
      MediaCategory(id: 'school_health', name: '健康养生'),
      MediaCategory(id: 'school_wisdom', name: '人生智慧'),
    ],
  ),
  MediaCategory(
    id: 'life',
    name: '生活',
    subCategories: [
      MediaCategory(id: 'life_food', name: '美食烹饪'),
      MediaCategory(id: 'life_skill', name: '生活技能'),
      MediaCategory(id: 'life_communication', name: '社交沟通'),
      MediaCategory(id: 'life_medical', name: '杏林医宝'),
      MediaCategory(id: 'life_cultivation', name: '处世修身'),
    ],
  ),
  MediaCategory(
    id: 'art',
    name: '艺术',
    subCategories: [
      MediaCategory(id: 'art_handmade', name: '手工制作'),
      MediaCategory(id: 'art_painting', name: '绘画艺术'),
    ],
  ),
  MediaCategory(id: 'parent', name: '育儿'), // 无子分类
  MediaCategory(
    id: 'knowledge',
    name: '知识',
    subCategories: [
      MediaCategory(id: 'knowledge_platform', name: '各大平台学习课程'),
      MediaCategory(id: 'knowledge_exam', name: '学习考试'),
      MediaCategory(id: 'knowledge_college', name: '百科职业学院'),
      MediaCategory(id: 'knowledge_classics', name: '国学宝'),
      MediaCategory(id: 'knowledge_adult', name: '成人进修'),
      MediaCategory(
        id: 'knowledge_language',
        name: '外语课程',
        subCategories: [
          MediaCategory(id: 'knowledge_language_english', name: '英语'),
          MediaCategory(id: 'knowledge_language_japanese', name: '日语'),
          MediaCategory(id: 'knowledge_language_french', name: '法语'),
          MediaCategory(id: 'knowledge_language_spanish', name: '西班牙语'),
          MediaCategory(id: 'knowledge_language_german', name: '德语'),
          MediaCategory(id: 'knowledge_language_russian', name: '俄语'),
          MediaCategory(id: 'knowledge_language_arabic', name: '阿拉伯语'),
          MediaCategory(id: 'knowledge_language_italian', name: '意大利语'),
          MediaCategory(id: 'knowledge_language_thai', name: '泰语'),
          MediaCategory(id: 'knowledge_language_portuguese', name: '葡萄牙语'),
          MediaCategory(id: 'knowledge_language_hebrew', name: '希伯来语'),
          MediaCategory(id: 'knowledge_language_korean', name: '韩语'),
        ],
      ),
    ],
  ),
  MediaCategory(
    id: 'fashion',
    name: '时尚',
    subCategories: [
      MediaCategory(id: 'fashion_beauty', name: '穿衣美容'),
      MediaCategory(
        id: 'fashion_fitness',
        name: '健身燃脂',
        subCategories: [
          MediaCategory(id: 'fashion_fitness_dance', name: '舞蹈'),
          MediaCategory(id: 'fashion_fitness_traditional', name: '传统健身'),
          MediaCategory(id: 'fashion_fitness_modern', name: '现代健身'),
        ],
      ),
    ],
  ),
];

const List<MediaCategory> musicCategories = [
  MediaCategory(id: 'original', name: '原创'),
  MediaCategory(id: 'pop', name: '流行'),
  MediaCategory(id: 'classic', name: '经典'),
];

MediaCategory? findVideoCategoryByChineseName(String name) {
  MediaCategory? result;

  MediaCategory? search(List<MediaCategory> categories) {
    for (final cat in categories) {
      if (cat.name == name) return cat;
      if (cat.subCategories != null && cat.subCategories!.isNotEmpty) {
        final found = search(cat.subCategories!);
        if (found != null) return found;
      }
    }
    return null;
  }

  result = search(videoCategories);
  return result;
}

MediaCategory? findMusicCategoryByChineseName(String name) {
  try {
    return musicCategories.firstWhere((cat) => cat.name == name);
  } catch (_) {
    return null;
  }
}


