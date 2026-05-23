# FitRoute 🍏🏃‍♂️

**FitRoute** is a comprehensive, dual-role mobile application built with Flutter that bridges the gap between individuals seeking health improvement and certified nutritionists providing professional guidance. 

This `README.md` serves as the **Ultimate Project Handoff and Technical Specification Document**, designed to allow any new developer—or AI Agent—to instantly understand the architecture, data schema, and coding conventions needed to seamlessly continue development.

---

## 🌟 Key Features

### For Users (Clients)
- **Persistent Authentication**: Seamlessly stay logged in with a local-first hydration architecture using Hive and Firebase Auth.
- **Nutritionist Marketplace**: Browse certified nutritionists, filter by specialty, and view detailed profiles, pricing, and ratings.
- **Assignment Requests**: Send, track, and cancel assignment requests to nutritionists with a real-time, dynamic 4-state action bar.
- **Dashboard & Macro Tracking**: Monitor daily calories, protein, carbs, and fat with visual progress rings (Percent Indicators).
- **Weight History Charting**: Track weight progress over time via an interactive timeline powered by `fl_chart`.
- **Diet & Workout Plans**: View structured, assigned meal and workout plans delivered directly by your nutritionist.

### For Nutritionists
- **Client Management Dashboard**: Overview of all assigned clients and their current active statuses.
- **Client Progress Monitoring**: Deep dive into individual client metrics, viewing their full weight history charts and macro adherence.
- **Plan Creation**: Design and assign custom meal plans and workout routines for clients.
- **Request Inbox**: Review incoming assignment requests from marketplace users and manage client rosters.

---

## 🏗 Architecture & Tech Stack

FitRoute is built using modern, production-grade Flutter patterns with a strong emphasis on reactive programming and offline accessibility.

* **Framework:** Flutter (`sdk: ^3.12.0-127.0.dev`)
* **State Management:** Riverpod (`flutter_riverpod: ^2.6.1`)
* **Routing:** GoRouter (`go_router: ^15.1.2`) with strict role-based guards.
* **Backend:** Firebase (Auth, Cloud Firestore, Storage)
* **Local Storage / Caching:** Hive (`hive_flutter`) — *Offline-first data serving.*
* **Code Generation:** `build_runner`, `json_serializable`, `hive_generator`

### Project Structure (Feature-First Architecture)

```text
lib/
├── config/
│   └── router/         # app_router.dart (GoRouter configuration & role-based redirects)
├── core/
│   ├── constants/      # AppColors, AppSizes, AppTextStyles
│   ├── models/         # Centralized Data Models (.dart & .g.dart files)
│   ├── theme/          # Centralized Theme configuration
│   └── services/       # Core utility services
├── features/
│   ├── auth/           # Login, Sign up, Auth State tracking
│   ├── dashboard/      # Main client dashboard (Macros, quick stats)
│   ├── diet/           # Meal rendering and tracking
│   ├── marketplace/    # Nutritionist browsing & assignment logic
│   ├── nutritionist/   # Nutritionist-specific dashboards
│   ├── profile/        # User and nutritionist settings & logout
│   ├── shared/         # Shared repositories across roles
│   └── workout/        # Workout routines and exercises
└── main.dart           # App entry point (ProviderScope & App configuration)
```

---

## 💾 Data Models & Firestore Schema

FitRoute uses a heavily typed model system. Every model relies on `json_annotation` for Firestore mapping and `hive` for local storage.

### 1. UserModel (`users` collection / Hive TypeId: 0)
- `id`: String (Firebase Auth UID)
- `role`: String ('user' or 'nutritionist')
- `email`, `fullName`, `age`, `height`, `gender`, `activityLevel`, `goal`: Standard demographic strings/ints.
- `weightHistory`: `List<WeightEntry>` (Chronological array of weight objects for charting).
- `assignedNutritionistId`: String? (Links user to an active nutritionist).
- `profileImageUrl`: String.

### 2. NutritionistModel (`nutritionists` collection / Hive TypeId: 1)
- `id`, `email`, `fullName`, `bio`: Standard profile strings.
- `specialties`: `List<String>`
- `price`, `rating`: Doubles.
- `clientCount`: Int.
- `whatsappNumber`, `instagramUrl`, `profileImageUrl`: Contact and social links.

### 3. MealModel (`meals` collection / Hive TypeId: 2)
- `id`, `name`, `imageUrl`: Standard identification.
- `category`: String ('Breakfast', 'Lunch', 'Dinner', 'Snack').
- `calories`, `carbs`, `protein`, `fat`: Integers.
- `isSelected`: Boolean (Used locally for tracking daily adherence).

### 4. AssignmentRequestModel (`assignment_requests` collection)
- `id`, `userId`, `nutritionistId`: Strings.
- `status`: String ('pending', 'accepted', 'rejected', 'cancelled').
- `createdAt`: DateTime (Mapped to/from Firestore Timestamp).

---

## 🔐 Routing & Authentication Flow

FitRoute uses a unique **Splash Screen Hydration Pattern**:
1. **App Starts:** `SplashScreen` displays for 2.5s while it watches `FirebaseAuth.instance.authStateChanges()`.
2. **Hydration:** If an authenticated session exists, the splash screen fetches the full user/nutritionist document from Firestore and writes it to the local Hive `userBox` **before** routing anywhere.
3. **Role-Based Redirect:** `GoRouter`'s redirect callback reads the role locally from Hive instantly.
   - Users are directed to `/home`.
   - Nutritionists are directed to `/nutritionist-dashboard`.
   - Cross-role navigation is blocked (e.g., users cannot access `/client-progress`).

---

## 🤖 AI Agent & Developer Handoff Guidelines

If you are an AI Agent or Developer continuing this project, **strictly adhere to the following rules**:

### 1. Code Generation is Mandatory
If you modify ANY file inside `lib/core/models/`, you **must** regenerate the `.g.dart` files before running the app.
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. State Management Rules (Riverpod)
- **Do NOT use `setState` for global state.** Use `StateNotifierProvider` or `NotifierProvider`.
- Use `StreamProvider` for real-time Firestore listeners (e.g., `pendingRequestProvider`).
- If you create a new repository, expose it via a Riverpod `Provider` (e.g., `final assignmentRepositoryProvider = Provider(...)`).

### 3. Routing Rules
- All new screens **must** be registered in `lib/config/router/app_router.dart`.
- If a route is for Users only, add it to the `_userOnlyPaths` set inside the router.
- If a route is for Nutritionists only, add it to the `_nutritionistOnlyPaths` set.

### 4. UI/UX Standards
- Do not hardcode colors or paddings. Use `AppColors`, `AppSizes`, and `AppTextStyles` from `lib/core/constants/`.
- Maintain the premium aesthetic: Use gradients, `GoogleFonts.poppins`, and visual feedback (loading spinners, Snackbars) for all async actions.
- Avoid deprecated properties. (e.g., use `Color.withValues(alpha: 0.5)` instead of `Color.withOpacity(0.5)`).

### 5. Local Storage (Hive)
- Hive is the synchronous source of truth for the router and initial UI rendering.
- If you update a user's data in Firestore, make sure you also update the local Hive box so the UI remains perfectly in sync without requiring a hard refresh.

---

## 🛠 Setup Instructions

1. **Clone & Install:**
   ```bash
   git clone <repository_url>
   cd fit_route
   flutter pub get
   ```

2. **Generate Adapters:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run:**
   ```bash
   flutter run
   ```
