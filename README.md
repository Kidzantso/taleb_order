# 🍔 Taleb Order - Food Ordering App (Flutter + Firebase)

## 📌 Overview
Taleb Order is a multi-role food ordering application built with **Flutter** and **Firebase**.  
The app supports four types of users:
- **Admin** → manages branches, adds managers, views workers, and later adds global menu items.
- **Manager** → manages waiters, assigns items to branch menus, and views/deletes waiters.
- **Waiter** → views orders and marks them as served.
- **Customer** → registers, browses branch menus, places orders, and views past orders.

---

## ✅ Progress So Far
### 🔧 Setup
- Integrated **Firebase** into Flutter project.
- Configured **Authentication** (Email/Password).
- Connected **Firestore Database** with collections:
  - `users` → stores all user profiles (admin, manager, waiter, customer).
  - `branches` → stores branch details.
  - `branch_menus` → branch menus -> collections of menus -> collections of items.
  - `items` → global catalog of menu items.
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
  - Validation: required fields + email format check and branch linking to his branch.

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
  - Displays waiters within the manager's branch with:
    - Case-insensitive alphabetical or date sorting.
    - Compact table layout (fixed widths, no horizontal scrolling).
    - Dates formatted as `DD/MM/YY`.
    - Tooltip + ellipsis for long names.
    - Delete functionality with confirmation dialog.

- **Menu Items Page (Manager)**
  - Managers can add/remove items from the branch menu using the global catalog.
  - Toggle availability for items (visible/hidden) without removing them.
  - Displays item photo (if available), category, price, and description.
  - Real-time updates via Firestore (`items` and `branch_menus/<branchId>/items`).

- **Customer Page**
  - Can view Menus for each branch (only available items).

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
 │    ├── validators.dart        # validation functions
 │    ├── migration_utils.dart   # functions for Firestore datamigration
 │    └── backfill_created_at.dart  # backfill created_at field for existing users
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
 │    │    ├── manager_dashboard.dart
 │    │    ├── add_waiter_page.dart
 │    │    ├── branch_analytics.dart
 │    │    ├── view_waiters_page.dart
 │    │    └── menu_items_page.dart
 │    ├── waiter/
 │    │    └── waiter_page.dart
 │    └── customer/
 │         ├── customer_page.dart
 │         └── customer_menu_page.dart
```

---

## 🚀 Next Steps
- Build **Waiter Page** to:
  - View orders.
  - Mark orders as served.
- Enhance **Customer Page** to:
  - Place orders.
  - View past orders.
- Add **search bars** in view pages for quick filtering by name using debounce and abort.
- signout functionality for all user types and session store.
- Kitchen display page for order preparation using diffrent kinds of scheduling (Multi queue - FIFO - Round Robin).
- Implement **analytics dashboard** for admins (sales, orders, performance).