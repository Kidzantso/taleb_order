# 🍔 Taleb Order - Food Ordering App (Flutter + Firebase)

## 📌 Overview
Taleb Order is a multi-role food ordering application built with **Flutter** and **Firebase**.  
The app supports five types of users:
- **Admin** → manages branches, adds managers, views workers, and later adds global menu items.
- **Manager** → manages waiters, assigns items to branch menus, and views/deletes waiters.
- **Waiter** → views orders in their branch and marks them as served.
- **Kitchen** → shared branch account, views pending orders, applies scheduling strategies, and marks them as serving.
- **Customer** → registers, browses branch menus, places orders, and views past orders with status tracking.

## ✅ Progress So Far
### 🔧 Setup
- Integrated **Firebase** into Flutter project.
- Configured **Authentication** (Email/Password).
- Connected **Firestore Database** with collections:
  - `users` → stores all user profiles (admin, manager, waiter, kitchen, customer).
  - `branches` → stores branch details.
  - `branch_menus` → branch menus → collections of items.
  - `items` → global catalog of menu items.
  - `orders` → customer orders with status (`pending`, `serving`, `served`).

### 📝 Implemented Screens
- **Login Page**
  - Role‑based routing: users land on their respective dashboards after login.
  - Validation: required fields, email format check, error handling.

- **Register Page (Customer)**
  - Customer registration with **first name + last name** (concatenated into `full_name` in Firestore).
  - Validation: required fields + email format check.

- **Admin Dashboard**
  - Grid layout with options:
    - Add Manager
    - Add Item
    - Add Branch (with manager linking + auto kitchen account creation)
    - View Workers
    - View Analytics (placeholder)
    - Profile (placeholder)
  - Styled with **red/black/white palette** inspired by fast-food branding.

- **Add Manager Page**
  - Admin creates manager accounts with **first name + last name → full_name**.
  - Validation: required fields + email format check.

- **Add Waiter Page**
  - Manager creates waiter accounts with **first name + last name → full_name**.
  - Validation: required fields + email format check and branch linking.

- **Branch Page**
  - Admin adds new branches.
  - Auto‑generates a **shared kitchen account** with default credentials (`kitchen_branchId@taleborder.com` / `taleborderkitchen#1-2-3`).
  - Admin links managers to branches (updates both `branches.manager_id` and `users.branch_id`).

- **View Workers Page (Admin)**
  - Displays all users with:
    - Case-insensitive alphabetical or date sorting.
    - Compact table layout (fixed widths, no horizontal scrolling).
    - Role abbreviations (M, W, C, A, K).
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
  - Toggle availability for items (visible/hidden).
  - Displays item photo, category, price, and description.
  - Real-time updates via Firestore.

- **Customer Menu Page**
  - Customers browse branch menus.
  - Integrated **Riverpod cart provider** for add/remove items.
  - Cart synced across menu and checkout.

- **Checkout Page (Customer)**
  - Displays cart items with images.
  - Delete confirmation popup.
  - Prevents empty orders.
  - Saves orders with `status = pending`.
  - Clears cart after successful order.

- **Order History Page (Customer)**
  - Displays past orders with status badges:
    - 🔴 Pending (kitchen)
    - 🟡 Serving (waiter)
    - 🟢 Served (completed)

- **Kitchen Page**
  - Shared branch account login.
  - Views `pending` orders.
  - Marks orders as `serving`.
  - FIFO scheduling (by `created_at`).

- **Waiter Page**
  - Views `serving` orders for their branch.
  - Marks orders as `served`.

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
- Status badges with color coding for orders.

---

## 📂 Project Structure
```
lib/
 ├── main.dart
 ├── utils/
 │    ├── validators.dart
 │    ├── migration_utils.dart
 │    └── backfill_created_at.dart
 ├── widgets/
 │    └── custom_widgets.dart
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
 │    ├── kitchen/
 │    │    └── kitchen_dashboard.dart
 │    └── customer/
 │         ├── cart_provider.dart
 │         ├── customer_page.dart
 │         ├── customer_menu_page.dart
 │         ├── checkout_page.dart
 │         └── order_history_page.dart
```

---

## 🚀 Next Steps
- **Kitchen Scheduling Strategies**
  - Extend beyond FIFO:
    - Round Robin (assign evenly to staff).
    - Multi‑Queue (separate queues by category).
- **Analytics Dashboard (Admin)**
  - Sales, orders, performance metrics.
- **Search Bars**
  - Add filtering in view pages with debounce.
- **Profile Pages**
  - Allow users to update personal info and change passwords.
- **Global Menu Management (Admin)**
  - Admins add/edit/delete items in the global catalog.
- **Push Notifications**
  - Notify customers on order status changes.
- **Drive Through Mode**
  - Special interface for drive-through orders.
- **Delivery Mode**
  - Allow customers to order online for delivery.
---