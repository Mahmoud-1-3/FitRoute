# FitRoute Project Analysis & Feature Overview

**FitRoute** is a dual-role health and fitness ecosystem designed to connect individuals with certified nutritionists. It leverages a modern, offline-first architecture with dynamic, real-time data syncing.

Below is a detailed breakdown of the application's core features, categorized by user role and technical implementation.

---

## 1. Identity & Onboarding 👤

FitRoute uses a role-based identity system. A single Firebase Auth backend supports two completely distinct user journeys.

- **Role Selection**: Upon sign-up, users select whether they are a "User" (Client) or "Nutritionist".
- **Dynamic Onboarding**: Based on the selected role, the app collects relevant metadata:
  - **Users**: Age, height, initial weight, activity level, and fitness goals.
  - **Nutritionists**: Pricing, specialties, bio, and social connection links (WhatsApp/Instagram).
- **Persistent Hydration**: The app employs a unique "Splash Screen Hydration" pattern. When an authenticated user opens the app, the Splash Screen seamlessly pulls their latest data from Firestore, caches it locally in Hive, and uses GoRouter to route them to their correct, role-specific dashboard instantly.

---

## 2. User Features (Clients) 🏃‍♂️

The User environment focuses on tracking personal progress and receiving professional guidance.

### **The Dashboard**
- **Macro Tracking**: A highly visual interface displaying daily nutritional goals. It uses animated circular progress rings (`percent_indicator`) to track Calories, Protein, Carbohydrates, and Fat.
- **Weight History Charting**: Replaces static weight tracking with a dynamic, chronological `fl_chart`. It maps historical `WeightEntry` data into a visual timeline, allowing users to see their progress trajectory with automatically scaling X/Y axes.
- **Quick Actions**: Immediate access to assigned diet plans, daily workouts, and marketplace exploration.

### **The Nutritionist Marketplace**
- **Discovery**: A directory of all certified nutritionists using the platform.
- **Detailed Profiles**: Users can view a nutritionist's bio, client count, monthly pricing, and connect with them via WhatsApp or Instagram.
- **Smart Assignment Engine**: A highly reactive 4-state action bar manages the request flow:
  1. **Send Request**: Available when the user has no pending assignments.
  2. **Cancel Request**: A red destructive button to retract a pending request specifically to that nutritionist.
  3. **Pending Elsewhere**: A disabled state preventing the user from sending overlapping requests to multiple nutritionists at once, while still allowing them to browse profiles.
  4. **Assigned**: A locked state when the user is successfully paired with their nutritionist.

### **Diet & Workouts**
- **Structured Meals**: Users view meals categorized into Breakfast, Lunch, Dinner, and Snacks.
- **Daily Adherence**: Users can mark meals as "completed" to update their daily macro progress on the dashboard.

---

## 3. Nutritionist Features 📋

The Nutritionist environment acts as a CRM (Customer Relationship Management) tool tailored for fitness professionals.

### **Roster Management**
- **Dashboard Overview**: A high-level view of all currently assigned clients and pending tasks.
- **Request Inbox**: Nutritionists can review incoming marketplace requests, seeing the potential client's initial goals and metrics, and choose to Accept or Reject them.

### **Client Progress Monitoring**
- **Deep-Dive Analytics**: Nutritionists can tap on any assigned client to view their dedicated "Client Progress Screen".
- **Remote Weight Tracking**: This screen mirrors the user's weight chart, granting the nutritionist full visibility into the client's historical weight fluctuations over time using the same dynamic `fl_chart` integration.
- **Macro Adherence**: Nutritionists can monitor if their clients are actually hitting their assigned macro targets based on the client's local interactions.

### **Plan Creation**
- Nutritionists have the authority to push custom meal structures and workout routines directly to their client's devices in real-time via Firestore syncing.

---

## 4. Technical Infrastructure 🏗

FitRoute is engineered for scalability, offline resilience, and immediate UI reactivity.

- **Offline-First Data (Hive)**: The app uses Hive local storage as its synchronous source of truth. This allows the app to load instantly without waiting for network calls. Background syncing updates Hive from Firestore, preventing UI layout shifts or lag.
- **Reactive State (Riverpod)**: Global state and real-time database listeners are handled via Riverpod. For example, the `pendingRequestProvider` watches a specific document in Firestore; when a user clicks "Cancel Request", the UI instantly reverts to "Send Request" without a page refresh because Riverpod automatically yields the new state.
- **Role-Guarded Routing (GoRouter)**: The application architecture completely isolates the two roles. GoRouter's redirect logic acts as a strict security guard—if a regular User attempts to access a Nutritionist-only URL path, they are instantly bounced back to their respective home screen. 
- **Type-Safe Data Models**: All data moving between Firestore and Hive is strictly typed using code generation (`json_serializable` and `hive_generator`), ensuring absolute data integrity for complex nested structures like `WeightEntry` arrays within the `UserModel`.
