import 'package:skill_swap/models/booking_model.dart';
import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/models/connection_request_model.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/models/skill_model.dart';
import 'package:skill_swap/models/user_model.dart';

/// Demo data used when [AppConfig.isDemoMode] is enabled.
class DummyData {
  DummyData._();

  static const demoUserId = 'demo_user_1';

  static UserModel get demoUser => const UserModel(
        id: demoUserId,
        email: 'demo@skillswap.app',
        name: 'Alex Morgan',
        bio: 'Passionate about design and always eager to learn new tech skills.',
        skillsTeach: ['Graphic Design', 'UI/UX Design', 'Figma'],
        skillsLearn: ['Web Development', 'Flutter', 'Python'],
        experienceLevel: 'Advanced',
        isOnline: true,
        rating: 4.8,
        sessionsCount: 24,
      );

  static final List<UserModel> recommendedUsers = [
        // ─── PREMIUM USERS (3) ───
        // #1 Premium – 3 teaching skills match, rating 4.9
        const UserModel(
          id: 'user_2',
          email: 'sarah@example.com',
          name: 'Sarah Chen',
          bio: 'Full-stack developer who teaches Web, Flutter & Python.',
          skillsTeach: ['Web Development', 'Flutter', 'Python'],
          skillsLearn: ['UI/UX Design', 'Figma'],
          experienceLevel: 'Expert',
          isOnline: true,
          rating: 4.9,
          sessionsCount: 42,
          isPremium: true,
          isVerified: true,
          premiumPlan: 'monthly',
        ),
        // #2 Premium – 2 teaching skills match, rating 4.8
        const UserModel(
          id: 'user_4',
          email: 'emma@example.com',
          name: 'Emma Wilson',
          bio: 'Flutter developer & web specialist.',
          skillsTeach: ['Flutter', 'Web Development', 'Android Development'],
          skillsLearn: ['Graphic Design', 'Photography'],
          experienceLevel: 'Intermediate',
          isOnline: true,
          rating: 4.8,
          sessionsCount: 31,
          isPremium: true,
          isVerified: true,
          premiumPlan: 'yearly',
        ),
        // #3 Premium – 1 teaching skill match, rating 4.7
        const UserModel(
          id: 'user_7',
          email: 'james@example.com',
          name: 'James Kim',
          bio: 'Python expert & open-source contributor.',
          skillsTeach: ['Python', 'Data Science', 'Machine Learning'],
          skillsLearn: ['UI/UX Design', 'Graphic Design'],
          experienceLevel: 'Expert',
          isOnline: false,
          rating: 4.7,
          sessionsCount: 55,
          isPremium: true,
          isVerified: true,
          premiumPlan: 'monthly',
        ),
        // ─── NON-PREMIUM USERS (3+) ───
        // #4 Non-premium – 3 teaching skills match
        const UserModel(
          id: 'user_3',
          email: 'mike@example.com',
          name: 'Mike Johnson',
          bio: 'Full-stack mentor for Web, Flutter & Python.',
          skillsTeach: ['Web Development', 'Flutter', 'Python'],
          skillsLearn: ['Docker', 'Kubernetes'],
          experienceLevel: 'Advanced',
          isOnline: false,
          rating: 4.6,
          sessionsCount: 18,
        ),
        // #5 Non-premium – 2 teaching skills match
        const UserModel(
          id: 'user_6',
          email: 'lisa@example.com',
          name: 'Lisa Patel',
          bio: 'Web & Flutter developer who loves mentoring.',
          skillsTeach: ['Flutter', 'Web Development', 'React'],
          skillsLearn: ['TypeScript', 'Node.js'],
          experienceLevel: 'Advanced',
          isOnline: true,
          rating: 4.5,
          sessionsCount: 27,
        ),
        // #6 Non-premium – 1 teaching skill match
        const UserModel(
          id: 'user_8',
          email: 'priya@example.com',
          name: 'Priya Sharma',
          bio: 'Python developer & data enthusiast.',
          skillsTeach: ['Python', 'Django', 'FastAPI'],
          skillsLearn: ['Flutter', 'Web Development'],
          experienceLevel: 'Advanced',
          isOnline: true,
          rating: 4.4,
          sessionsCount: 22,
        ),
        // ─── OTHER USERS (no skill match with demo user) ───
        const UserModel(
          id: 'user_5',
          email: 'david@example.com',
          name: 'David Park',
          bio: 'Fitness coach & nutrition enthusiast.',
          skillsTeach: ['Fitness Training', 'Nutrition'],
          skillsLearn: ['Python', 'Video Editing'],
          experienceLevel: 'Expert',
          isOnline: true,
          rating: 4.5,
          sessionsCount: 15,
        ),
      ];

  static List<SkillModel> get trendingSkills => [
        const SkillModel(
          id: 's1',
          name: 'Flutter',
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
          name: 'Python',
          category: 'Development',
          trending: true,
          learnersCount: 1150,
        ),
        const SkillModel(
          id: 's4',
          name: 'Digital Marketing',
          category: 'Marketing',
          trending: true,
          learnersCount: 750,
        ),
        const SkillModel(
          id: 's5',
          name: 'React',
          category: 'Development',
          trending: true,
          learnersCount: 890,
        ),
        const SkillModel(
          id: 's6',
          name: 'Machine Learning',
          category: 'Development',
          trending: false,
          learnersCount: 620,
        ),
      ];

  static final List<ChatModel> demoChats = [
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

  static final List<ConnectionRequestModel> demoConnectionRequests = [
    ConnectionRequestModel(
      id: 'user_2_demo_user_1',
      senderId: 'user_2',
      receiverId: demoUserId,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static final List<NotificationModel> demoNotifications = [
        NotificationModel(
          id: 'n1',
          userId: demoUserId,
          title: 'Connection Request',
          body: 'Sarah Chen wants to connect with you.',
          type: 'connection_request',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          data: const {
            'connectionRequestId': 'user_2_demo_user_1',
            'senderId': 'user_2',
            'senderName': 'Sarah Chen',
          },
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

  static final List<BookingModel> demoBookings = [
        BookingModel(
          id: 'booking_1',
          requesterId: 'user_3',
          hostId: demoUserId,
          skill: 'Graphic Design',
          date: DateTime.now().add(const Duration(days: 2)),
          timeSlot: '10:00 AM',
          status: 'pending',
          note: 'Would love to learn Figma basics!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        BookingModel(
          id: 'booking_2',
          requesterId: demoUserId,
          hostId: 'user_2',
          skill: 'Flutter Development',
          date: DateTime.now().add(const Duration(days: 5)),
          timeSlot: '2:00 PM',
          status: 'confirmed',
          note: 'Excited to learn about state management!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
