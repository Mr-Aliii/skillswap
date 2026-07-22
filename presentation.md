# SkillSwap — Presentation Guide (Roman Urdu)

Yeh file aapko project "SkillSwap" ko asaan aur mukammal tareeqay se present karne mein madad karegi. Neeche har zaroori cheez Roman Urdu mein samjhayi gayi hai — overview, background, tech stack, features jo implement hue hain, user flows (scenarios), architecture/flow diagram ka lafzi bayan, demo script, aur run karne ke steps.

## 1) Project ka short overview

SkillSwap aik mobile app hai jahan users apni skills exchange karte hain — paisa nahi, balkay seekhna aur sikhana. Iska objective hai knowledge sharing ko aadat banana jahan log apni skills 'teach' karte hain aur doosron se 'learn' karte hain.

## 2) Background / Kyun banaya gaya?

- Market gap: Log mentorship ya short sessions ke liye mutual exchange prefer karte hain. 
- Goal: Aik simple platform provide karna jahan users apni profile banayein, skills declare karein, match ho kar chat karein, aur sessions book karein.
- MVP focus: Authentication, profile, discovery/match, chat, booking, notifications (structure).

## 3) Tech stack (short)

- Frontend: Flutter (Dart 3.11)
- State management: Riverpod
- Backend / BaaS: Firebase (Auth, Firestore, Storage, Messaging)
- Other libs: image_picker, cached_network_image, google_fonts, uuid, shimmer, timeago

## 4) Project structure (quick)

- `lib/main.dart` — App entry point, Firebase init, FCM init
- `lib/config/` — App flags (demo mode), firebase_config
- `lib/firebase/` — Firebase init + messaging service
- `lib/services/` — Business logic (auth, user CRUD, chat, booking, notifications)
- `lib/models/` — Data models (User, Skill, Chat, Message, Booking, Notification)
- `lib/providers/` — Riverpod providers (auth, profile, home, theme)
- `lib/screens/` — UI screens (auth, home, match, chat, profile, booking, settings)
- `lib/widgets/` — Reusable UI components

## 5) Implemented features (jo repo mein nazar aa rahe hain)

- Authentication
  - Email login, register, forgot password
  - Demo mode supported (AppConfig.useDemoMode true) — app bina firebase ke chal sakta hai for demo

- User Profile
  - Profile creation & edit
  - Upload profile image (Firebase Storage)
  - Skills I teach / Skills I want to learn

- Home / Discovery
  - Search bar (skills & people)
  - Category filters
  - Trending skills carousel
  - Recommended users list
  - Pull-to-refresh

- Match / Connect
  - User cards with Connect / Request actions
  - Match screen for viewing potential matches

- Chat
  - Conversations list
  - Real-time message stream (Firestore) or demo messages
  - Send message and update lastMessage metadata

- Booking
  - Book session screen (date/time picker)
  - Booking request flow (creates booking docs)

- Notifications
  - In-app notification screen
  - FCM initialization present (MessagingService) — push tokens

- Settings & UI
  - Dark / Light mode toggle
  - About screen

## 6) Key services & collections (Firestore)

- `users` — user profiles
- `chats` — chat meta data
- `chats/{id}/messages` — messages
- `bookings` — session requests
- `notifications` — in-app notifications
- `skills` — catalog / trending skills

## 7) User scenarios / Demo flows (Roman Urdu step-by-step)

Below mein 4 short demo scenarios diye hue hain jo presentation mein use ho sakte hain.

Scenario A — Onboarding + Register
1) App open karein -> Splash animation nazar aayega.
2) Onboarding slides se guzrein (3 pages).
3) Register screen par jaake email, name, password bharen aur "Sign Up" karein.
4) Agar Demo Mode on hai to turant dummy profile load ho jayega.
5) Profile edit kar ke skills add karein (Skills I teach / Skills I learn).

Scenario B — Search aur Connect
1) Home dashboard: search bar mein "Web" type karein.
2) Search results se kisi user par tap karein -> User Profile screen khulegi.
3) Agar match ho to "Connect" ya "Request Exchange" button press karein.
4) A popup/confirmation aur snackbar dikhega: "Connection request sent".

Scenario C — Chat flow
1) Main tab se Conversations open karein.
2) Kisi conversation par tap karein -> Chat screen open.
3) Message likhein aur send karein; agar Demo mode toh local demo messages add ho jayenge, warna Firestore mein message create ho ke list update hoti hai.
4) Last message timestamp update hota hai (conversations list mein reflect).

Scenario D — Booking a session
1) Kisi user profile se "Book Session" button tap karein.
2) Date & time choose karein, short message attach karein, "Request" bhejein.
3) Booking document Firestore mein create ho jayega (ya demo mode mein delay ke sath simulate). 
4) User ko in-app notification ya snackbar mil jayega.

## 8) Architecture / Flow (high-level — Roman Urdu)

- App start: `main.dart` → FirebaseInitializer.initialize() → MessagingService.initialize() → ProviderScope run
- Auth: `AuthService` (FirebaseAuth or demo), auth state provided by a Riverpod provider (`auth_provider`) → app routes decide initial screen (splash → onboarding → main)
- Data: `UserService`, `ChatService`, `BookingService` interact with Firestore and Firebase Storage. Agar `AppConfig.isDemoMode` true ho to local dummy data API chalti hai instead of Firestore.
- UI: Screens use Riverpod providers (`home_provider`, `profile_provider`, etc.) jo services se data fetch kar ke UI ko update karte hain.
- Messaging: `MessagingService` registers FCM token and listens for messages; notifications displayed in-app via `NotificationService`.

## 9) How to present this project (talk track in Roman Urdu)

1) Intro (10-20 seconds): "Main aaj aapko SkillSwap dikhata/ti hoon — aik app jahan log apni skills exchange karte hain. Objective: knowledge exchange bina paise ke."
2) Tech stack (10 seconds): "App Flutter mein bani hai, backend Firebase; state management Riverpod. Iska faida: cross-platform fast UI aur Firebase se quick backend integration."
3) Live demo plan (2 mins):
   - Splash & onboarding (brief)
   - Register/login (demo mode show karein) — profile create karke skills add karein
   - Home: search & trending skills
   - Open user profile → Connect / Book
   - Chat: send message and show real-time behavior (or demo messages)
4) Architecture (30-40 seconds): Explain main flow: AuthService → UserService/ChatService → Firestore; demo mode fallback. Show folder structure briefly.
5) Data model & collections (15 seconds): `users`, `chats`, `messages`, `bookings`, `notifications`, `skills`.
6) Known gaps & next steps (15-30 seconds): push notifications, video sessions, better matching algorithm, composite indexes for advanced queries, E2E tests.
7) Close (5-10 seconds): Ask for questions; show roadmap link (`ROADMAP.md`) and Github repo.

## 10) Commands / How to run locally (Roman Urdu with steps)

- Prereqs: Flutter installed, Android emulator ya device. Agar aap Firebase use karna chahte hain to `flutterfire configure` chalayen.

1) Dependencies install:

```powershell
cd "c:\IT VISION PROJECTS\MOBILE APPLICATIONS\Skill-Swap"
flutter pub get
```

2) Demo mode run (recommended for presentation — no Firebase required):
- `lib/config/app_config.dart` mein `useDemoMode = true` ensure karein (ye default hota hai README ke mutabiq).
- Run:

```powershell
flutter run -d emulator-5554
```

3) Real Firebase run:
- Create Firebase project & run `flutterfire configure` (generate `lib/firebase/firebase_options.dart`)
- Place `google-services.json` in `android/app/` and optional iOS config
- Set `useDemoMode = false` in `lib/config/app_config.dart`
- Run the app on device/emulator.

## 11) Edge cases / Limitations (short)

- Search queries are single-field (no composite index), large datasets need paginated queries.
- Demo mode bypasses auth & network; production requires Firebase configuration.
- FCM push on web may need additional service worker setup.
- No video/voice session implementation yet.

## 12) Suggested talking points (short bullets in Roman Urdu)

- "Yeh app mutual learning ko asaan banata hai — exchange of skills without money."
- "Demo mode se seedha run kar sakte hain presentation mein bina backend configure kiye." 
- "Core flows: register → profile → discover → connect → chat → book."
- "Architecture simple hai: Flutter UI + Riverpod + Firebase firestore/storage/auth. Demo mode local data se fast prototyping allow karta hai."

## 13) Next steps (for roadmap mention)

- Implement push notifications fully and show remote notifications.
- Add video sessions (Zoom / WebRTC integration).
- Matching algorithm improvements and personalization.
- Add analytics and error tracking.

---

File created from codebase inspection (June 2, 2026). Agar aap chahen main is presentation ko Urdu script (Perso-Arabic) mein convert kar dun ya slides (PowerPoint) bhi bana doon to bata dein — main kar dunga.