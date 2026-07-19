# 📋 Kế hoạch phân chia công việc — Apartment Building Management System

## Tổng quan

Dựa trên tài liệu SRS và SWD, dự án sử dụng kiến trúc **Flutter + Firebase** (2-tier Client-Server). Hiện tại codebase chỉ có template Flutter mặc định, cần build toàn bộ từ đầu.

### Quy mô Release 1.0
- **1 tòa nhà**, 12 tầng, ~36-48 căn hộ
- **3 roles chính**: Admin, Staff, Resident
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging)

---

## Các tính năng cho Release 1.0

Dựa trên SRS (23 use cases) và SWD, tôi chọn **10 feature groups** cốt lõi cho Release 1.0:

| # | Feature Group | Mức ưu tiên | Mô tả ngắn |
|---|--------------|-------------|------------|
| 1 | **Authentication** | 🔴 Critical | Login, Logout, Change Password |
| 2 | **User Management** | 🔴 Critical | CRUD users, assign roles (Admin only) |
| 3 | **Apartment Management** | 🔴 Critical | CRUD apartments, assign resident |
| 4 | **Resident Management** | 🟡 High | View/Create/Update resident profiles |
| 5 | **Maintenance Request** | 🟡 High | Submit request (Resident), manage/update status (Staff) |
| 6 | **Bill & Invoice** | 🟡 High | Create bills (Staff), view/pay bills (Resident) |
| 7 | **Announcement** | 🟢 Medium | Create/Edit (Admin/Staff), View (All) |
| 8 | **Visitor Management** | 🟢 Medium | Register visitor (Resident), Check-in/out (Staff) |
| 9 | **Complaint/Feedback** | 🟢 Medium | Submit (Resident), Respond (Admin/Staff) |
| 10 | **Dashboard & Reports** | 🟢 Medium | Overview statistics, basic reports |

### Tính năng LOẠI TRỪ khỏi Release 1.0 (để dành cho Release 2.0+)
- ❌ Face Authentication (phức tạp, cần ML)
- ❌ Amenity Booking (không critical)
- ❌ Service Orders (tương tự Maintenance Request, gộp sau)
- ❌ Contract Management (phức tạp, cần legal logic)
- ❌ Payment Gateway integration (dùng manual payment trước)
- ❌ Export Report (PDF/Excel)
- ❌ System Settings & Audit Logs

---

## 🏗️ Cấu trúc thư mục mục tiêu

```
lib/
├── main.dart                    # Entry point — Firebase init + App widget
├── app/
│   ├── app.dart                 # MaterialApp + ThemeData + Routes
│   ├── theme.dart               # Design system from DESIGN.md
│   └── routes.dart              # Named routes / GoRouter config
├── models/
│   ├── user_model.dart
│   ├── apartment_model.dart
│   ├── request_model.dart
│   ├── bill_model.dart
│   ├── notification_model.dart
│   ├── visitor_model.dart
│   └── complaint_model.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── change_password_screen.dart
│   ├── admin/
│   │   ├── user_management/
│   │   ├── apartment_management/
│   │   └── dashboard/
│   ├── staff/
│   │   ├── request_management/
│   │   ├── bill_management/
│   │   ├── visitor_management/
│   │   └── announcement/
│   └── resident/
│       ├── home/
│       ├── my_requests/
│       ├── my_bills/
│       ├── announcements/
│       ├── visitors/
│       └── profile/
├── services/
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── apartment_service.dart
│   ├── request_service.dart
│   ├── bill_service.dart
│   ├── notification_service.dart
│   ├── visitor_service.dart
│   └── complaint_service.dart
├── providers/                   # State management (Provider/Riverpod)
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── apartment_provider.dart
│   ├── request_provider.dart
│   ├── bill_provider.dart
│   └── ...
├── widgets/                     # Shared reusable widgets
│   ├── custom_text_field.dart
│   ├── loading_indicator.dart
│   ├── status_badge.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   └── confirm_dialog.dart
└── utils/
    ├── constants.dart
    ├── validators.dart
    ├── extensions.dart
    └── helpers.dart
```

---

## 📅 Timeline — 3 Sprints (6 tuần)

### Sprint 0: Foundation (Tuần 1) — Toàn team cùng làm

> [!IMPORTANT]
> Sprint 0 là nền tảng chung, **tất cả 5 người đều cần tham gia**. Sau Sprint 0, mỗi người tách ra làm feature riêng.

| Task | Người phụ trách | Mô tả |
|------|----------------|-------|
| Project setup + Firebase config | **Member 5** | Thêm Firebase dependencies, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` vào `pubspec.yaml`. Config Firebase project. |
| Theme & Design System | **Member 5** ~~→ Done by Member 1~~ | ✅ Implement `ThemeData` + `ColorScheme` dựa trên DESIGN.md (Modern Haven). Fonts: Outfit + Inter. |
| Navigation & Routing | **Member 1** | Setup `go_router` hoặc named routes. Role-based navigation (Admin/Staff/Resident → different home screens). |
| Models | **Member 2** | Tạo tất cả data models (`UserModel`, `ApartmentModel`, `RequestModel`, `BillModel`, `NotificationModel`, `VisitorModel`, `ComplaintModel`) với `fromJson`/`toJson`. |
| Base Services | **Member 3** | Tạo base service class cho Firestore CRUD operations. Setup `AuthService` cơ bản. |
| Shared Widgets | **Member 4** | `CustomTextField`, `LoadingIndicator`, `StatusBadge`, `EmptyState`, `ErrorState`, `ConfirmDialog`. |
| State Management setup | **Member 1** | Chọn và setup Provider/Riverpod. Tạo `AuthProvider` cơ bản. |

---

### Sprint 1: Core Features (Tuần 2–3)

### Sprint 2: Secondary Features (Tuần 4–5)

### Sprint 3: Polish & Testing (Tuần 6)

---

## 👥 Phân chia công việc theo thành viên

---

### 👤 Member 1 — Team Lead

**Vai trò**: Team Lead + Foundation + Authentication + User Management

#### Sprint 0
- [x] Setup navigation & routing (GoRouter)
- [x] Role-based route guards (Admin/Staff/Resident)
- [x] Setup state management (Provider)
- [x] Tạo `AuthProvider`

#### Sprint 1 — Authentication Module
- [x] `LoginScreen` — Email/Password login via Firebase Auth
- [x] `ChangePasswordScreen` — Đổi mật khẩu
- [x] `AuthService` — Login, Logout, Change Password, Listen auth state
- [x] `AuthProvider` — Quản lý trạng thái đăng nhập, current user, role
- [x] Splash screen + Auto-login (check saved session) *(done in Sprint 0)*
- [x] Role-based redirect sau login (Admin → Admin Home, Staff → Staff Home, Resident → Resident Home) *(done in Sprint 0)*

#### Sprint 2 — User Management (Admin only)
- [ ] `UserListScreen` — Danh sách users, search, filter by role
- [ ] `UserCreateScreen` — Form tạo user mới (name, email, role, apartment)
- [ ] `UserEditScreen` — Cập nhật thông tin user
- [ ] `UserService` — CRUD operations trên Firestore `users` collection
- [ ] `UserProvider` — State management cho user list
- [ ] Update/Disable user status (Active/Inactive)
- [ ] Assign role cho user

#### Sprint 3
- [ ] Widget tests cho Authentication screens
- [ ] Unit tests cho `AuthService`
- [ ] Code review toàn team
- [ ] Fix bugs + polish

**Screens phụ trách**: Login, Change Password, User List, User Create/Edit
**Firestore collections**: `users`

---

### 👤 Member 2

**Vai trò**: Apartment Management + Resident Management

#### Sprint 0
- [x] Tạo `UserModel` (`lib/models/user_model.dart`) *(done by Member 1)*
- [ ] Tạo các models còn lại (`ApartmentModel`, `RequestModel`, `BillModel`, `NotificationModel`, `VisitorModel`, `ComplaintModel`)
- [ ] Implement `fromJson()` / `toJson()` cho mỗi model
- [ ] Định nghĩa Firestore collection structure

#### Sprint 1 — Apartment Management (Admin)
- [ ] `ApartmentListScreen` — Danh sách căn hộ, filter theo tầng/trạng thái
- [ ] `ApartmentDetailScreen` — Chi tiết căn hộ (số phòng, tầng, diện tích, chủ hộ, thành viên)
- [ ] `ApartmentCreateScreen` — Form thêm/sửa căn hộ
- [ ] `ApartmentService` — CRUD operations trên Firestore `apartments` collection
- [ ] `ApartmentProvider` — State management
- [ ] Assign resident vào apartment

#### Sprint 2 — Resident Management (Admin/Staff)
- [ ] `ResidentListScreen` — Danh sách cư dân, search theo tên/căn hộ
- [ ] `ResidentProfileScreen` — Xem profile cư dân (Staff view)
- [ ] `ResidentCreateScreen` — Form thêm cư dân mới (Admin/Staff)
- [ ] `ResidentEditScreen` — Cập nhật thông tin cư dân
- [ ] Link resident ↔ apartment (quan hệ 2 chiều trên Firestore)
- [ ] Disable resident (Admin only)

#### Sprint 3
- [ ] Widget tests cho Apartment/Resident screens
- [ ] Unit tests cho `ApartmentService`, models
- [ ] Fix bugs + polish

**Screens phụ trách**: Apartment List/Detail/Create, Resident List/Profile/Create/Edit
**Firestore collections**: `apartments`, `users` (resident data)

---

### 👤 Member 3

**Vai trò**: Maintenance Request + Complaint/Feedback

#### Sprint 0
- [ ] Tạo base service class cho Firestore CRUD
- [x] Setup `AuthService` (`lib/services/auth_service.dart`) *(done by Member 1)*
- [x] Helper functions — `validators.dart` (`lib/utils/validators.dart`) *(done by Member 1)*

#### Sprint 1 — Maintenance Request (Resident → Staff)
- [ ] `RequestListScreen` (Resident) — Xem danh sách request đã gửi + trạng thái
- [ ] `RequestCreateScreen` (Resident) — Form gửi request mới (Title, Description, Category, Photo)
- [ ] `RequestDetailScreen` — Xem chi tiết request
- [ ] `RequestManageScreen` (Staff) — Danh sách tất cả requests, filter by status
- [ ] `RequestService` — CRUD trên Firestore `requests` collection
- [ ] `RequestProvider` — State management
- [ ] Upload ảnh request lên Firebase Storage
- [ ] Cập nhật status: Pending → In Progress → Completed (Staff)

#### Sprint 2 — Complaint/Feedback
- [ ] `ComplaintListScreen` (Resident) — Xem complaints đã gửi
- [ ] `ComplaintCreateScreen` (Resident) — Gửi feedback/complaint
- [ ] `ComplaintManageScreen` (Admin/Staff) — Xem và respond complaints
- [ ] `ComplaintService` — CRUD trên Firestore `complaints` collection
- [ ] `ComplaintProvider` — State management
- [ ] Respond complaint (Admin/Staff)

#### Sprint 3
- [ ] Widget tests cho Request/Complaint screens
- [ ] Unit tests cho `RequestService`, `ComplaintService`
- [ ] Fix bugs + polish

**Screens phụ trách**: Request List/Create/Detail/Manage, Complaint List/Create/Manage
**Firestore collections**: `requests`, `complaints`

---

### 👤 Member 4

**Vai trò**: Bill & Invoice Management + Shared Widgets

#### Sprint 0
- [ ] Tạo các shared widgets còn lại:
  - [x] `CustomTextField` — Styled text input theo Design System *(done by Member 1)*
  - [x] `LoadingIndicator` — Loading spinner/skeleton *(done by Member 1)*
  - [ ] `StatusBadge` — Badge hiển thị trạng thái (Paid/Unpaid/Pending/...)
  - [ ] `EmptyState` — Placeholder khi không có data
  - [ ] `ErrorState` — Hiển thị lỗi + retry
  - [ ] `ConfirmDialog` — Dialog xác nhận hành động nguy hiểm

#### Sprint 1 — Bill Management (Staff side)
- [ ] `BillListScreen` (Staff) — Danh sách bills, filter by apartment/month/status
- [ ] `BillCreateScreen` (Staff) — Form tạo bill mới (Apartment, Type, Amount, Due Date)
- [ ] `BillDetailScreen` — Xem chi tiết bill
- [ ] `BillService` — CRUD trên Firestore `bills` collection
- [ ] `BillProvider` — State management
- [ ] Bill types: Electricity, Water, Service Fee, Parking
- [ ] Bill status: Unpaid → Paid

#### Sprint 2 — Bill/Payment (Resident side)
- [ ] `MyBillsScreen` (Resident) — Xem danh sách bills của mình
- [ ] `BillPaymentScreen` (Resident) — Xem chi tiết + xác nhận thanh toán (manual/simulated)
- [ ] `PaymentHistoryScreen` — Lịch sử thanh toán
- [ ] Record Cash Payment (Staff)
- [ ] Confirm Bank Transfer (Staff)
- [ ] Payment status tracking

#### Sprint 3
- [ ] Widget tests cho Bill/Payment screens
- [ ] Unit tests cho `BillService`
- [ ] Fix bugs + polish

**Screens phụ trách**: Bill List/Create/Detail, My Bills, Payment, Payment History
**Firestore collections**: `bills`, `payments`

---

### 👤 Member 5

**Vai trò**: Project Setup + Announcement + Visitor Management + Notification

#### Sprint 0
- [ ] Firebase project creation & configuration
- [ ] Add all Firebase dependencies to `pubspec.yaml`
- [x] Implement `ThemeData` + `ColorScheme` theo DESIGN.md *(done by Member 1)*
- [x] Setup Google Fonts (Outfit + Inter) *(done by Member 1)*
- [ ] Create `app.dart`, `theme.dart`, `routes.dart` *(theme.dart + routes.dart done by Member 1)*
- [ ] Resident Home Screen layout (bottom navigation)
- [ ] Staff Home Screen layout
- [ ] Admin Home Screen layout

#### Sprint 1 — Announcement Management
- [ ] `AnnouncementListScreen` — Xem danh sách thông báo (All users)
- [ ] `AnnouncementDetailScreen` — Xem chi tiết thông báo
- [ ] `AnnouncementCreateScreen` (Admin/Staff) — Tạo/sửa thông báo
- [ ] `AnnouncementService` — CRUD trên Firestore `notifications` collection
- [ ] `AnnouncementProvider` — State management
- [ ] Push notification khi có announcement mới (Firebase Cloud Messaging)

#### Sprint 2 — Visitor Management
- [ ] `VisitorRegisterScreen` (Resident) — Đăng ký khách đến thăm
- [ ] `VisitorListScreen` (Staff) — Xem danh sách khách đã đăng ký
- [ ] `VisitorCheckInOutScreen` (Staff) — Check-in / Check-out khách
- [ ] `VisitorService` — CRUD trên Firestore `visitors` collection
- [ ] `VisitorProvider` — State management
- [ ] Resident Profile Screen (view/edit own profile)
- [ ] Dashboard Screen (Admin) — Basic statistics (số căn hộ, cư dân, requests pending, bills unpaid)

#### Sprint 3
- [ ] Widget tests cho Announcement/Visitor screens
- [ ] Unit tests cho services
- [ ] Integration testing
- [ ] Fix bugs + polish

**Screens phụ trách**: Announcement List/Detail/Create, Visitor Register/List/CheckInOut, Dashboard, Resident Profile
**Firestore collections**: `notifications`, `visitors`

---

## 🗂️ Firestore Database Schema

```
📁 users/
├── {userId}
│   ├── email: string
│   ├── fullName: string
│   ├── phone: string
│   ├── role: string (admin | staff | resident)
│   ├── apartmentId: string?
│   ├── nationalId: string
│   ├── dateOfBirth: timestamp
│   ├── avatarUrl: string?
│   ├── status: string (active | inactive)
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 apartments/
├── {apartmentId}
│   ├── number: string (e.g., "301")
│   ├── floor: int
│   ├── building: string
│   ├── area: double (m²)
│   ├── ownerId: string?
│   ├── status: string (occupied | vacant)
│   ├── residentIds: array<string>
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 requests/
├── {requestId}
│   ├── title: string
│   ├── description: string
│   ├── category: string (plumbing | electrical | general)
│   ├── imageUrls: array<string>
│   ├── residentId: string
│   ├── apartmentId: string
│   ├── status: string (pending | in_progress | completed)
│   ├── assignedStaffId: string?
│   ├── resolutionNote: string?
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 bills/
├── {billId}
│   ├── apartmentId: string
│   ├── residentId: string
│   ├── type: string (electricity | water | service | parking)
│   ├── amount: double
│   ├── billingMonth: string (e.g., "2026-07")
│   ├── dueDate: timestamp
│   ├── status: string (unpaid | paid | overdue)
│   ├── paidAt: timestamp?
│   ├── paymentMethod: string? (cash | bank_transfer)
│   ├── createdBy: string
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 notifications/
├── {notificationId}
│   ├── title: string
│   ├── content: string
│   ├── type: string (announcement | system | billing)
│   ├── createdBy: string
│   ├── targetRoles: array<string> (e.g., ["resident", "staff"])
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 visitors/
├── {visitorId}
│   ├── visitorName: string
│   ├── visitorPhone: string
│   ├── purpose: string
│   ├── registeredBy: string (residentId)
│   ├── apartmentId: string
│   ├── expectedTime: timestamp
│   ├── checkInTime: timestamp?
│   ├── checkOutTime: timestamp?
│   ├── status: string (registered | checked_in | checked_out)
│   ├── checkedInBy: string? (staffId)
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

📁 complaints/
├── {complaintId}
│   ├── content: string
│   ├── residentId: string
│   ├── apartmentId: string
│   ├── status: string (submitted | in_review | resolved)
│   ├── response: string?
│   ├── respondedBy: string?
│   ├── respondedAt: timestamp?
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

---

## 📦 Dependencies cần thêm vào `pubspec.yaml`

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.12.1
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.10.1
  firebase_storage: ^12.5.0
  firebase_messaging: ^15.4.0

  # State Management
  provider: ^6.1.5

  # Navigation
  go_router: ^15.1.2

  # UI
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1
  flutter_svg: ^2.0.17
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.20.2
  image_picker: ^1.1.2
  uuid: ^4.5.1

  # Forms
  form_builder_validators: ^11.1.0
```
---

## 🗃️ Dữ liệu mẫu đã được Seed (Seed Data)

Dự án đã được chạy script seed dữ liệu mẫu lên Firebase Cloud chung. Cả team dùng chung database này, không cần chạy lại script trừ khi muốn reset dữ liệu.

### 🔑 Tài khoản thử nghiệm (Test Accounts):

| Email | Mật khẩu | Vai trò (Role) | Mô tả |
|-------|----------|----------------|-------|
| `admin@apartment.com` | `Admin@123` | `admin` | Quản trị viên hệ thống |
| `staff1@apartment.com` | `Staff@123` | `staff` | Nhân viên ban quản lý 1 |
| `staff2@apartment.com` | `Staff@123` | `staff` | Nhân viên ban quản lý 2 |
| `resident1@apartment.com` | `Resident@123` | `resident` | Cư dân phòng 301 |
| `resident2@apartment.com` | `Resident@123` | `resident` | Cư dân phòng 302 |
| `resident3@apartment.com` | `Resident@123` | `resident` | Cư dân phòng 501 |
| `resident4@apartment.com` | `Resident@123` | `resident` | Cư dân phòng 702 |
| `resident5@apartment.com` | `Resident@123` | `resident` | Cư dân phòng 1001 |

### 📂 Các dữ liệu mẫu đã tạo sẵn trên Firestore:
- **36 Căn hộ (apartments)**: Tầng 1 đến tầng 12 (3 phòng/tầng). Đã gắn sẵn chủ hộ và cư dân cho các phòng 301, 302, 501, 702, 1001.
- **5 Hóa đơn (bills)**: Đủ các loại phí (điện, nước, dịch vụ, gửi xe) với các trạng thái thanh toán khác nhau (`unpaid`, `paid`, `overdue`).
- **3 Yêu cầu sửa chữa (requests)**: Đủ các trạng thái (`pending`, `in_progress`, `completed`).
- **3 Thông báo chung (notifications)**: Mẫu tin tức, lịch họp, nội quy.
- **2 Khách viếng thăm (visitors)**: Đăng ký bởi cư dân.
- **2 Khiếu nại (complaints)**: Trạng thái `submitted` và `resolved`.

> ⚠️ **Lưu ý**: Nếu muốn chạy lại script reset dữ liệu về trạng thái ban đầu, chạy lệnh: `node scripts/seed_data.js`

---

## ⚠️ User Review Required

> [!IMPORTANT]
> **State Management**: Kế hoạch sử dụng `Provider` vì đơn giản, phù hợp team mới. Nếu team muốn dùng `Riverpod` hoặc `BLoC`, cần điều chỉnh.

> [!IMPORTANT]
> **Payment Gateway**: Release 1.0 sẽ **KHÔNG** tích hợp payment gateway thực (VNPay/MoMo). Thanh toán sẽ là manual (Staff confirm cash/bank transfer). Payment gateway để Release 2.0.

> [!IMPORTANT]
> **Face Authentication**: Loại trừ hoàn toàn khỏi Release 1.0 do phức tạp về ML/AI. Để dành cho Release 2.0+.

---

## ✅ Open Questions (Đã giải quyết)

> [!NOTE]
> 1. **Roles**: ✅ Team đồng ý dùng **3 roles** (Admin, Staff, Resident) theo SWD. Chấp nhận đơn giản hóa, bỏ bước Approve Invoice và không phân biệt BQT Head/Member. SRS cần cập nhật cho khớp.

> [!NOTE]
> 2. **Team member roles**: ✅ Đã ghi Member 1–5. Mỗi thành viên tự đối chiếu phần việc của mình.

> [!NOTE]
> 3. **Firebase project**: ✅ Đã tạo project `apartment-mgmt-prm393`. Firestore + Auth (Email/Password) đã bật. Storage bật khi cần. Thành viên được add sẽ tự chạy `flutterfire configure` để sinh config files.

---

## Verification Plan

### Automated Tests
```bash
flutter analyze          # Zero warnings
dart format . --set-exit-if-changed  # Code formatting
flutter test             # Unit + Widget tests
```

### Manual Verification
- Mỗi Sprint end: Demo features trên emulator/device
- Sprint 3: Full integration test trên Android device thật
- Cross-check role-based access: Login từng role và verify quyền truy cập đúng screens

---

## 📊 Tổng kết phân chia

| Member | Sprint 0 | Sprint 1 | Sprint 2 | Screens | Collections |
|--------|----------|----------|----------|---------|------------|
| **Member 1** (Lead) | Navigation, State Mgmt | Authentication | User Management | 6 | `users` |
| **Member 2** | Models | Apartment Mgmt | Resident Mgmt | 7 | `apartments`, `users` |
| **Member 3** | Base Services | Maintenance Request | Complaint/Feedback | 7 | `requests`, `complaints` |
| **Member 4** | Shared Widgets | Bill Mgmt (Staff) | Bill/Payment (Resident) | 6 | `bills`, `payments` |
| **Member 5** | Firebase + Theme + Home Layouts | Announcement | Visitor Mgmt + Dashboard | 8 | `notifications`, `visitors` |
