# 🍔 Taleb Order - Food Ordering App (Flutter + Firebase)

## 📌 Overview
Taleb Order is a multi-role food ordering application built with **Flutter** and **Firebase**.  
The app supports four types of users:
- **Admin** → manages branches, adds managers, and later adds global menu items.
- **Manager** → manages waiters and assigns items to branch menus.
- **Waiter** → views orders and marks them as served.
- **Customer** → registers, browses branch menus, places orders, and views past orders.

---

## ✅ Progress So Far (Milestone 1)
### 🔧 Setup
- Integrated **Firebase** into Flutter project.
- Configured **Authentication** (Email/Password).
- Connected **Firestore Database** with collections:
  - `users` → stores all user profiles (admin, manager, waiter, customer).
  - `branches` → stores branch details.
  - `menus` → branch menus (to be expanded later).
  - `orders` → customer orders.

### 📝 Implemented Screens
- **Login Page**
  - All types of users login and landing on their desired pages.
  - Validation: required fields, email format check, error handling (clears fields on incorrect login).

- **Register Page (Customer)**
  - Customer registration with full name, email, password.
  - Validation: required fields + email format check.

- **Admin Dashboard**
  - Grid layout with 4 options:
    - Add Manager
    - Add Branch (with link manager to branch functionality)
    - View Analytics (placeholder)
    - Profile (placeholder)
  - Styled with **red/black/white palette** inspired by fast-food branding.

- **Add Manager Page**
  - Admin creates manager accounts (Firebase Auth + Firestore).
  - Styled textfields with spacing and consistent design.
  - Validation: required fields + email format check.

- **Branch Page**
  - Admin adds new branches.
  - Admin links managers to branches (updates both `branches.manager_id` and `users.branch_id`).
  - Styled textfields and dropdowns for selection.

- **Customer Page (Placeholder)**
  - Simple landing page for customers after login.

---

## 🎨 UI/UX
- Custom **TextField styling** (`customTextField`) with:
  - Rounded borders
  - Red focus color (`#ff0022`)
  - Soft background (`#f8e9f2`)
  - Consistent spacing
- Centralized validation functions in `utils/validators.dart`.

---

## 📂 Project Structure
```
lib/
 ├── main.dart
 ├── utils/
 │    └── validators.dart        # validation functions
 ├── widgets/
 │    └── custom_widgets.dart    # reusable styled textfields/buttons
 ├── pages/
 │    ├── auth/
 │    │    ├── login_page.dart
 │    │    └── register_page.dart
 │    ├── admin/
 │    │    ├── admin_dashboard.dart
 │    │    ├── add_manager_page.dart
 │    │    ├── branch_page.dart
 │    │    ├── analytics_page.dart
 │    │    └── profile_page.dart
 │    └── customer/
 │         └── customer_page.dart
 │    └── manager/
 │         └── manager_page.dart
 │    └── waiter/
 │         └── waiter_page.dart
```

---

## 🚀 Next Steps (Milestone 2)
- Expand **Admin Dashboard** to add global menu items (later integrate Supabase for item photos).
- Build **Manager Page** to:
  - Add waiters.
  - Assign items from global catalog to branch menus.
- Build **Waiter Page** to:
  - View orders.
  - Mark orders as served.
- Enhance **Customer Page** to:
  - Browse branch menus.
  - Place orders.
  - View past orders.

