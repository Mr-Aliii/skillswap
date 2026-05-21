import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/models/skill_model.dart';
import 'package:skill_swap/models/user_model.dart';

/// Demo data used when [AppConfig.useDemoMode] is enabled.
class DummyData {
  DummyData._();

  static const demoUserId = 'demo_user_1';

  static UserModel get demoUser => const UserModel(
        id: demoUserId,
        email: 'demo@skillswap.app',
        name: 'Alex Morgan',
        bio: 'Passionate about design and always eager to learn new tech skills.',
        skillsTeach: ['Graphic Design', 'UI/UX', 'Figma'],
        skillsLearn: ['Web Development', 'Flutter', 'Python'],
        experienceLevel: 'Advanced',
        isOnline: true,
        rating: 4.8,
        sessionsCount: 24,
      );

  static List<UserModel> get recommendedUsers => [
        const UserModel(
          id: 'user_2',
          email: 'sarah@example.com',
          name: 'Sarah Chen',
          bio: 'Full-stack developer teaching React & Node.',
          skillsTeach: ['Web Development', 'JavaScript', 'React'],
          skillsLearn: ['Graphic Design', 'UI/UX'],
          experienceLevel: 'Expert',
          isOnline: true,
          rating: 4.9,
          sessionsCount: 42,
        ),
        const UserModel(
          id: 'user_3',
          email: 'mike@example.com',
          name: 'Mike Johnson',
          bio: 'Digital marketer & growth hacker.',
          skillsTeach: ['Marketing', 'SEO', 'Content Strategy'],
          skillsLearn: ['Photography', 'Video Editing'],
          experienceLevel: 'Advanced',
          isOnline: false,
          rating: 4.6,
          sessionsCount: 18,
        ),
        const UserModel(
          id: 'user_4',
          email: 'emma@example.com',
          name: 'Emma Wilson',
          bio: 'Piano teacher & music producer.',
          skillsTeach: ['Piano', 'Music Theory', 'Ableton'],
          skillsLearn: ['Spanish', 'French'],
          experienceLevel: 'Intermediate',
          isOnline: true,
          rating: 4.7,
          sessionsCount: 31,
        ),
        const UserModel(
          id: 'user_5',
          email: 'david@example.com',
          name: 'David Park',
          bio: 'Fitness coach & nutrition enthusiast.',
          skillsTeach: ['Fitness Training', 'Nutrition'],
          skillsLearn: ['Photography', 'Video Editing'],
          experienceLevel: 'Expert',
          isOnline: true,
          rating: 4.5,
          sessionsCount: 15,
        ),
      ];

  static List<SkillModel> get trendingSkills => [
        const SkillModel(
          id: 's1',
          name: 'Flutter Development',
          category: 'Development',
          trending: true,
          learnersCount: 1280,
        ),
        const SkillModel(
          id: 's2',
          name: 'UI/UX Design',
          category: 'Design',
          trending: true,
          learnersCount: 980,
        ),
        const SkillModel(
          id: 's3',
          name: 'Digital Marketing',
          category: 'Marketing',
          trending: true,
          learnersCount: 750,
        ),
        const SkillModel(
          id: 's4',
          name: 'Spanish',
          category: 'Language',
          trending: false,
          learnersCount: 620,
        ),
      ];

  static List<ChatModel> get demoChats => [
        ChatModel(
          id: 'chat_1',
          participantIds: [demoUserId, 'user_2'],
          lastMessage: 'Sounds great! See you tomorrow at 3pm.',
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
          otherUserName: 'Sarah Chen',
          otherUserId: 'user_2',
          isOtherOnline: true,
          unreadCount: 2,
        ),
        ChatModel(
          id: 'chat_2',
          participantIds: [demoUserId, 'user_3'],
          lastMessage: 'I can teach you SEO basics in exchange!',
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
          otherUserName: 'Mike Johnson',
          otherUserId: 'user_3',
          isOtherOnline: false,
          unreadCount: 0,
        ),
      ];

  static List<NotificationModel> get demoNotifications => [
        NotificationModel(
          id: 'n1',
          userId: demoUserId,
          title: 'New Match!',
          body: 'Sarah Chen wants to exchange skills with you.',
          type: 'match',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: 'n2',
          userId: demoUserId,
          title: 'Session Request',
          body: 'Mike Johnson requested a session on Marketing.',
          type: 'session',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        NotificationModel(
          id: 'n3',
          userId: demoUserId,
          title: 'Exchange Accepted',
          body: 'Your skill exchange request was accepted!',
          type: 'request',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
