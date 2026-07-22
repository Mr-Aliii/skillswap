# SkillSwap - Changelog

## [1.1.0] - 2026-07-07

### 🔧 Critical Fixes
- **Fixed Firestore Security Rules**: Updated and corrected all Firestore security rules to properly handle authentication and authorization
  - Added rules for `connection_requests` collection
  - Added rules for `reviews` collection
  - Fixed user profile read/write permissions
  - Added proper booking access control (requester and host)
  - Added default deny rule for security

### ✨ New Features
- **Enhanced Booking System**
  - Added status management (pending, confirmed, cancelled, rejected, completed)
  - Added `getUserBookings()` method to fetch all bookings for a user
  - Added `updateBookingStatus()` method for hosts to accept/reject requests
  - Added `cancelBooking()` method for requesters
  - Added `getPendingBookingsForHost()` method
  - Added `copyWith()` method to BookingModel

- **My Bookings Screen**
  - New screen to view and manage all user bookings
  - Tabbed interface (All, Pending, Confirmed)
  - Accept/Reject buttons for hosts on pending bookings
  - Cancel button for requesters on pending bookings
  - Status chips with color coding
  - Integrated with settings menu

- **Review System Model**
  - Created ReviewModel for ratings and feedback
  - Includes rating (1-5 stars), comment, and skill
  - Tracks reviewer and reviewee
  - Links to booking for verification

### 📚 Documentation Updates
- Updated README.md with new Firestore collections
- Updated ROADMAP.md with current progress
- Created CHANGELOG.md for tracking changes

### 📱 UI/UX Improvements
- Added "My Bookings" link in Settings screen
- Added route for My Bookings screen in app router
- Improved booking status visualization with colored chips

### 🔒 Security Improvements
- All Firestore collections now have proper security rules
- Users can only access their own data where appropriate
- Connection requests properly secured (sender/receiver access)
- Reviews can only be created by authenticated users

### 📦 Files Modified
- `firestore.rules` - Complete rewrite with proper security
- `lib/services/booking_service.dart` - Enhanced with status management
- `lib/models/booking_model.dart` - Added copyWith method
- `lib/models/review_model.dart` - New file
- `lib/utils/dummy_data.dart` - Added demoBookings list
- `lib/screens/booking/my_bookings_screen.dart` - New file
- `lib/routes/app_routes.dart` - Added myBookings route
- `lib/routes/app_router.dart` - Added myBookings route handler
- `lib/screens/settings/settings_screen.dart` - Added bookings link
- `README.md` - Updated documentation
- `ROADMAP.md` - Updated progress

---

## [1.0.0] - Initial MVP Release

### Features
- User authentication (Email/Password)
- User profiles with skills management
- Home dashboard with search and recommendations
- Match/Discover users with skill matching
- Connection request system
- Chat system
- Basic booking system
- Notifications system
- Settings with dark mode
- Premium subscription model