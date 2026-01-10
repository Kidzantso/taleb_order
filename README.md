# 🍔 Taleb Order - Food Ordering App (Flutter + Firebase)

## 📌 Overview
Taleb Order is a multi-role food ordering application built with **Flutter** and **Firebase**.  
The app supports four types of users:
- **Admin** → manages branches, adds managers, views workers, and later adds global menu items.
- **Manager** → manages waiters, assigns items to branch menus, and views/deletes waiters.
- **Waiter** → views orders and marks them as served.
- **Customer** → registers, browses branch menus, places orders, and views past orders.

---

## ✅ Progress So Far (Milestone 1 & 2)
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
  - All types of users login and land on their respective dashboards.
  - Validation: required fields, email format check, error handling.

- **Register Page (Customer)**
  - Customer registration with **first name + last name** (concatenated into `full_name` in Firestore).
  - Validation: required fields + email format check.

- **Admin Dashboard**
  - Grid layout with various options:
    - Add Manager
    - Add Item
    - Add Branch (with manager linking)
    - View Workers
    - View Analytics (placeholder)
    - Profile (placeholder)
  - Styled with **red/black/white palette** inspired by fast-food branding.

- **Add Manager Page**
  - Admin creates manager accounts with **first name + last name → full_name**.
  - Validation: required fields + email format check.

- **Add Waiter Page**
  - Manager creates waiter accounts with **first name + last name → full_name**.
  - Validation: required fields + email format check.

- **Branch Page**
  - Admin adds new branches.
  - Admin links managers to branches (updates both `branches.manager_id` and `users.branch_id`).

- **View Workers Page (Admin)**
  - Displays all users with:
    - Case-insensitive alphabetical or date sorting.
    - Compact table layout (fixed widths, no horizontal scrolling).
    - Role abbreviations (M, W, C, A).
    - Dates formatted as `DD/MM/YY`.
    - Tooltip + ellipsis for long names.
    - Delete functionality with confirmation dialog.
    - Admin cannot delete themselves (shows centered “-”).

- **View Waiters Page (Manager)**
  - Displays waiters with:
    - Case-insensitive alphabetical or date sorting.
    - Compact table layout (fixed widths, no horizontal scrolling).
    - Dates formatted as `DD/MM/YY`.
    - Tooltip + ellipsis for long names.
    - Delete functionality with confirmation dialog.

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
- Compact **DataTable design**:
  - Fixed column widths
  - Ellipsis + tooltip for long names
  - Centered action icons/dash
  - No horizontal scrolling

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
 │    │    ├── add_item_page.dart
 │    │    ├── branch_page.dart
 │    │    ├── view_workers_page.dart
 │    │    ├── analytics_page.dart
 │    │    └── profile_page.dart
 │    ├── manager/
 │    │    ├── manager_page.dart
 │    │    └── view_waiters_page.dart
 │    ├── waiter/
 │    │    └── waiter_page.dart
 │    └── customer/
 │         └── customer_page.dart
```

---

## 🚀 Next Steps (Milestone 3)
- Expand **Admin Dashboard** to add global menu items (later integrate Supabase for item photos).
- Build **Manager Page** to:
  - Assign items from global catalog to branch menus.
- Build **Waiter Page** to:
  - View orders.
  - Mark orders as served.
- Enhance **Customer Page** to:
  - Browse branch menus.
  - Place orders.
  - View past orders.
- Add **search bars** in view pages for quick filtering by name.
- Implement **analytics dashboard** for admins (sales, orders, performance).