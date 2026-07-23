# Revised Section II — Software Requirement Specification

## Hướng dẫn sử dụng

Phần từ **II. Software Requirement Specification** đến hết **5.4 Release Scope Exclusions** được viết bằng tiếng Anh để có thể dán trực tiếp vào tài liệu SRS. Phần **Diagram Redrawing Guide** ở cuối file là hướng dẫn tiếng Việt dành cho người vẽ lại sơ đồ và không cần đưa nguyên văn vào SRS.

---

# II. Software Requirement Specification

## 1. Product Overview

The Apartment Building Management System (ABMS) is a mobile application that digitizes the daily operations of a small apartment building. Release 1.0 is designed for one building with 12 floors and approximately 36 to 48 apartment units. The application replaces manual processes such as paper maintenance forms, direct fee notices, phone-based visitor registration, and printed announcements.

The system supports three user roles: Admin, Staff, and Resident. Each role is provided with a dedicated home screen and a role-appropriate set of functions.

- **Admin** manages user accounts, apartments, resident records, announcements, and overview statistics. Admin can also review maintenance requests, complaints, and visitor activities.
- **Staff** manages maintenance requests, bills, payment confirmations, visitor check-in and check-out, complaints, and announcements.
- **Resident** views personal bills and payment history, submits maintenance requests and complaints, registers visitors, reads announcements, and manages personal profile information.

Release 1.0 uses Firebase Authentication for account authentication, Cloud Firestore for application data, and Firebase Storage for uploaded images. The application is implemented with Flutter and is intended for Android and iOS mobile devices.

Invoice payment in Release 1.0 is handled manually. A Resident reviews the building bank account information, performs a bank transfer outside the application, and submits a payment confirmation request. Staff verifies the payment and approves or rejects it. Staff may also record a cash payment. Release 1.0 does not integrate with VNPay, MoMo, an in-app wallet, or another external payment gateway.

The main system capabilities are:

1. Authentication and role-based navigation.
2. User account management.
3. Apartment management.
4. Resident management.
5. Maintenance request management.
6. Bill and manual payment management.
7. Complaint and feedback management.
8. Announcement management.
9. Visitor management.
10. Dashboard statistics and personal profile management.

**Figure 1-1: Apartment Building Management System Context**

The system context diagram shall show the three human actors and the Firebase services used by the mobile application. Detailed redrawing instructions are provided in the Diagram Redrawing Guide.

---

## 2. User Requirements

### 2.1 Actors

| # | Actor | Description |
|---|---|---|
| 1 | Admin | The user responsible for system administration and building master data. Admin manages user accounts, roles, account statuses, apartments, resident records, announcements, and dashboard statistics. Admin may also access operational lists for maintenance requests, complaints, and visitors. |
| 2 | Staff | The building operations user. Staff creates and manages bills, records or verifies payments, processes maintenance requests, responds to complaints, manages visitor entry and exit, and creates or updates announcements. |
| 3 | Resident | A person living in an apartment. A Resident views assigned bills, submits bank-transfer payment confirmations, views payment history, creates maintenance requests and complaints, registers visitors, reads announcements, and views or updates personal profile information. |

### 2.2 Use Cases

#### 2.2.1 Diagram

**Figure 2-1: ABMS Use Case Diagram**

The use case diagram shall contain the three actors defined in Section 2.1 and the use cases listed in Section 2.2.2. Payment Gateway shall not appear as an actor in Release 1.0.

#### 2.2.2 Use Case Descriptions

| ID | Function Group | Use Case | Actors | Use Case Description and Main Flow |
|---|---|---|---|---|
| UC-01 | Authentication | Login | Admin, Staff, Resident | The user enters an email address and password. The system validates the credentials through Firebase Authentication, loads the corresponding user profile, verifies that the account is active, and redirects the user to the home screen for the assigned role. |
| UC-02 | Authentication | Logout | Admin, Staff, Resident | The authenticated user selects Logout. The system ends the Firebase authentication session, clears the current application user state, and returns to the Login screen. |
| UC-03 | Authentication | Change Password | Admin, Staff, Resident | The authenticated user enters the current password, a new password, and password confirmation. The system re-authenticates the user, validates the new password, updates the Firebase Authentication password, and displays the result. |
| UC-04 | Profile Management | View and Update Own Profile | Admin, Staff, Resident | The user opens the Profile screen to view personal information. The user may update permitted profile fields such as full name, phone number, national identity number, and date of birth. The system validates and saves the permitted changes. Role, account status, apartment assignment, and email cannot be changed by the user. |
| UC-05 | Dashboard | View Dashboard Statistics | Admin | Admin opens the dashboard. The system retrieves and displays the number of apartments, residents, pending maintenance requests, unpaid bills, and visitors currently inside the building. |
| UC-06 | User Management | Manage User Accounts | Admin | Admin views, searches, and filters user accounts. Admin may create an account, edit permitted account information, assign a role, assign an apartment, activate an account, or deactivate an account. The system prevents Admin from deactivating the account currently being used. |
| UC-07 | Apartment Management | Manage Apartments | Admin | Admin views, searches, and filters apartments by floor or occupancy status. Admin may view apartment details, create an apartment, update apartment information, or delete an apartment after confirmation. |
| UC-08 | Apartment Management | Assign Resident | Admin | Admin opens an apartment, selects a Resident, and assigns that person to the apartment. The system adds the Resident identifier to the apartment, updates the Resident apartment assignment, marks the apartment as Occupied, and records the selected Resident as the apartment owner in the current screen flow. |
| UC-09 | Resident Management | Manage Resident Records | Admin | Admin views and searches Resident accounts, opens a Resident profile, creates a Resident record, updates Resident information, or changes the Resident account status. |
| UC-10 | Maintenance Request | Submit Maintenance Request | Resident | The Resident enters a title, category, description, and up to three optional images. The system associates the request with the authenticated Resident and apartment, sets the status to Pending, saves the request, and makes it available to Staff and Admin. |
| UC-11 | Maintenance Request | View Own Maintenance Requests | Resident | The Resident opens the maintenance request list, views requests submitted by the current account, selects a request, and views its category, description, images, status, assigned Staff, resolution note, and timestamps when available. |
| UC-12 | Maintenance Request | Manage Maintenance Requests | Admin, Staff | Admin or Staff views all maintenance requests and filters them by status. The user opens a request and updates it from Pending to In Progress or Completed. The system stores the current processing account identifier and an optional resolution note when the update is submitted. |
| UC-13 | Complaint Management | Submit Complaint or Feedback | Resident | The Resident enters complaint or feedback content. The system associates the record with the authenticated Resident and apartment, sets the status to Submitted, and saves the record for review. |
| UC-14 | Complaint Management | View Own Complaints | Resident | The Resident views complaints submitted by the current account, opens a complaint, and views its content, status, response, responder, and response time when available. |
| UC-15 | Complaint Management | Review and Respond to Complaint | Admin, Staff | Admin or Staff views submitted complaints, marks a complaint as In Review when appropriate, enters a response, and resolves the complaint. The system stores the response, responder, response time, and final status. |
| UC-16 | Bill Management | Create Bill | Staff | Staff enters the apartment identifier, bill type, billing month, amount, and due date. The system validates the input, creates the bill with Unpaid status, and makes it available to the assigned Resident. |
| UC-17 | Bill Management | View and Manage Bills | Staff | Staff views and filters bills by apartment, billing month, or status. Staff selects a bill to view its details and any pending payment request. Staff may proceed to record cash payment or approve or reject a bank-transfer confirmation. |
| UC-18 | Bill Management | View My Bills | Resident | The Resident views bills associated with the assigned apartment, including bill type, billing month, amount, due date, and status. The Resident may open an unpaid bill to start manual payment confirmation. |
| UC-19 | Payment Management | Submit Bank-Transfer Payment Confirmation | Resident | The Resident opens an unpaid bill, reviews the building bank account and transfer reference, confirms that the transfer was made, and submits a payment confirmation. The system creates a Pending payment record and changes the bill status to Pending for Staff verification. |
| UC-20 | Payment Management | Record Cash Payment | Staff | Staff opens an unpaid bill, confirms that cash was received, and records the payment. The system creates an Approved cash payment record and changes the bill status to Paid. |
| UC-21 | Payment Management | Approve or Reject Bank Transfer | Staff | Staff opens a bill with a Pending payment, reviews the submitted payment information, and approves or rejects it. Approval changes the payment to Approved and the bill to Paid. Rejection records a reason, changes the payment to Rejected, and returns the bill to Unpaid. |
| UC-22 | Payment Management | View Payment History | Resident | The Resident views payment records associated with the current Resident or apartment. The system displays amount, payment method, payment status, and transaction time. |
| UC-23 | Announcement Management | View Announcements | Admin, Staff, Resident | The user views the in-app announcement list, selects an announcement, and reads its title, content, type, author, target-role metadata, and publication time. Release 1.0 retrieves announcements for all authenticated roles and does not enforce target-role filtering in the list query. |
| UC-24 | Announcement Management | Manage Announcements | Admin, Staff | Admin or Staff creates an announcement by entering a title, content, type, and target roles. The user may also edit or delete an existing announcement. A destructive confirmation is required before deletion. |
| UC-25 | Visitor Management | Register Visitor | Resident | The Resident enters visitor name, phone number, purpose, expected visit time, and apartment information. The system creates a visitor record with Registered status. |
| UC-26 | Visitor Management | View Visitor List | Admin, Staff | Admin or Staff views and searches registered visitors. The list displays visitor identity, apartment, expected time, and the current Registered, Checked In, or Checked Out status. |
| UC-27 | Visitor Management | Check In or Check Out Visitor | Admin, Staff | Admin or Staff selects a visitor, verifies the visitor information, and records Check In when the visitor arrives or Check Out when the visitor leaves. The system stores the relevant timestamps and the Staff or Admin account performing the operation. |

---

## 3. Software Features

### 3.1 Functional Overview

The ABMS provides a centralized mobile platform for apartment administration and daily resident services. Release 1.0 supports the following three roles:

1. Admin.
2. Staff.
3. Resident.

The application uses role-based routing after successful login:

- Admin is redirected to the Admin Home screen.
- Staff is redirected to the Staff Home screen.
- Resident is redirected to the Resident Home screen.

The functional scope of Release 1.0 consists of:

| # | Feature Group | Scope |
|---|---|---|
| 1 | Authentication | Login, logout, session restoration, role-based redirect, and change password. |
| 2 | User Management | Admin user list, search, filter, account creation, account editing, role assignment, apartment assignment, activation, and deactivation. |
| 3 | Apartment Management | Admin apartment list, search, filter, details, create, update, delete, and Resident assignment. |
| 4 | Resident Management | Admin resident list, search, create, update, status management, and profile view. |
| 5 | Maintenance Request | Resident submission and tracking; Admin or Staff review and status updates. |
| 6 | Bill and Payment | Staff bill creation and payment confirmation; Resident bill view, manual transfer confirmation, and payment history. |
| 7 | Complaint and Feedback | Resident submission and tracking; Admin or Staff review and response. |
| 8 | Announcement | Admin or Staff create, edit, and delete; all roles view. |
| 9 | Visitor Management | Resident registration; Admin or Staff visitor list, check-in, and check-out. |
| 10 | Dashboard and Profile | Admin overview statistics and personal profile access for all roles. |

#### 3.1.1 Screen Flow

**Figure 3-1: Role-Based Screen Flow**

After Login, the application routes the user to one of three home screens according to the assigned role. The complete set of nodes and transitions required in the screen flow is provided in the Diagram Redrawing Guide.

#### 3.1.2 Screen Descriptions

| # | Feature | Screen | Description |
|---|---|---|---|
| 1 | Authentication | Splash | Initializes Firebase, restores the authentication session, loads the user profile, and redirects to Login or the correct role home screen. |
| 2 | Authentication | Login | Authenticates all roles using email and password. |
| 3 | Authentication | Change Password | Re-authenticates the current user and changes the Firebase Authentication password. |
| 4 | Profile | User Profile | Displays and updates permitted personal profile information and provides logout and theme controls. |
| 5 | Administration | Admin Home and Dashboard | Displays Admin navigation and overview counters for apartments, residents, pending requests, unpaid bills, and visitors inside. |
| 6 | Administration | User List | Displays, searches, and filters user accounts by role and status. |
| 7 | Administration | User Create | Creates a Firebase Authentication account and the corresponding Firestore user profile. |
| 8 | Administration | User Edit | Updates permitted user fields, role, apartment assignment, and active or inactive status. |
| 9 | Apartment Management | Apartment List | Displays, searches, and filters apartments by floor and occupancy status. |
| 10 | Apartment Management | Apartment Form | Creates or updates apartment number, floor, building, area, price, type, and status. |
| 11 | Apartment Management | Apartment Details | Displays apartment information, owner, residents, and the Resident assignment action. |
| 12 | Resident Management | Resident List | Displays and searches Resident accounts and filters them by status. |
| 13 | Resident Management | Resident Form | Creates or updates Resident identity and apartment information. |
| 14 | Resident Management | Resident Profile | Displays detailed information for a selected Resident. |
| 15 | Staff Operations | Staff Home | Provides tab navigation to maintenance requests, bills, visitors, complaints, and personal profile. |
| 16 | Resident Services | Resident Home | Provides access to bills, maintenance requests, complaints, announcements, visitor registration, payment history, and profile. |
| 17 | Maintenance Request | My Request List | Displays maintenance requests submitted by the current Resident. |
| 18 | Maintenance Request | Request Create | Creates a request with title, category, description, and optional images. |
| 19 | Maintenance Request | Request Details | Displays request information, current status, assigned Staff, images, and resolution note. |
| 20 | Maintenance Request | Request Management | Allows Admin or Staff to view, filter, and update maintenance requests and resolution notes. |
| 21 | Complaint | My Complaint List | Displays complaints submitted by the current Resident. |
| 22 | Complaint | Complaint Create | Creates a complaint or feedback record. |
| 23 | Complaint | Complaint Details | Displays complaint content, status, and response information. |
| 24 | Complaint | Complaint Management | Allows Admin or Staff to review, mark in review, respond to, and resolve complaints. |
| 25 | Bill | Bill List | Allows Staff to view and filter building bills. |
| 26 | Bill | Bill Create | Allows Staff to create a bill for an apartment and billing month. |
| 27 | Bill | Bill Details | Displays bill details and supports cash recording or bank-transfer approval and rejection. |
| 28 | Bill | My Bills | Displays bills associated with the Resident apartment. |
| 29 | Payment | Bill Payment | Displays manual bank-transfer information and submits a payment confirmation request. |
| 30 | Payment | Payment History | Displays payment records associated with the Resident or apartment. |
| 31 | Announcement | Announcement List | Displays announcements visible to the current role. Admin and Staff can open the create screen. |
| 32 | Announcement | Announcement Create or Edit | Allows Admin or Staff to create or edit an announcement and select target roles. |
| 33 | Announcement | Announcement Details | Displays announcement content. Admin and Staff can edit or delete the announcement. |
| 34 | Visitor | Visitor Registration | Allows a Resident to register a visitor and expected arrival time. |
| 35 | Visitor | Visitor List and Check-In/Out | Allows Admin or Staff to view, search, check in, and check out visitors. |

#### 3.1.3 Screen Authorization

`X` indicates that the role is authorized to access the screen or action through the intended application flow.

| # | Screen or Action | Admin | Staff | Resident |
|---|---|---|---|---|
| 1 | Splash | X | X | X |
| 2 | Login | X | X | X |
| 3 | Logout | X | X | X |
| 4 | Change Password | X | X | X |
| 5 | View or Update Own Profile | X | X | X |
| 6 | Admin Home and Dashboard | X |  |  |
| 7 | User List | X |  |  |
| 8 | Create User | X |  |  |
| 9 | Edit User | X |  |  |
| 10 | Assign User Role | X |  |  |
| 11 | Activate or Deactivate User | X |  |  |
| 12 | Apartment List | X |  |  |
| 13 | Apartment Details | X |  |  |
| 14 | Create or Update Apartment | X |  |  |
| 15 | Delete Apartment | X |  |  |
| 16 | Assign Resident to Apartment | X |  |  |
| 17 | Resident List | X |  |  |
| 18 | Resident Profile | X |  |  |
| 19 | Create or Update Resident | X |  |  |
| 20 | Resident Home |  |  | X |
| 21 | Submit Maintenance Request |  |  | X |
| 22 | View Own Maintenance Requests |  |  | X |
| 23 | Request Management | X | X |  |
| 24 | Update Request Status or Resolution | X | X |  |
| 25 | Submit Complaint or Feedback |  |  | X |
| 26 | View Own Complaints |  |  | X |
| 27 | Complaint Management | X | X |  |
| 28 | Respond to Complaint | X | X |  |
| 29 | Bill List |  | X |  |
| 30 | Create Bill |  | X |  |
| 31 | Bill Details and Payment Verification |  | X |  |
| 32 | View My Bills |  |  | X |
| 33 | Submit Bank-Transfer Confirmation |  |  | X |
| 34 | View Personal Payment History |  |  | X |
| 35 | Record Cash Payment |  | X |  |
| 36 | Approve or Reject Bank Transfer |  | X |  |
| 37 | Announcement List and Details | X | X | X |
| 38 | Create or Edit Announcement | X | X |  |
| 39 | Delete Announcement | X | X |  |
| 40 | Register Visitor |  |  | X |
| 41 | Visitor List | X | X |  |
| 42 | Check In or Check Out Visitor | X | X |  |

#### 3.1.4 Non-Screen Functions

| # | Feature | System Function | Description |
|---|---|---|---|
| 1 | Authentication | Authentication State Listener | Listens for Firebase Authentication session changes and updates the current application authentication state. |
| 2 | Authentication | Role-Based Redirect | Loads the Firestore user profile and redirects an authenticated account to the Admin, Staff, or Resident home screen. |
| 3 | Authentication | Active Account Validation | Prevents an inactive account from continuing to use protected application functions. |
| 4 | User Management | User Account Provisioning | Creates a Firebase Authentication account through a secondary Firebase session, creates the Firestore profile, and rolls back the authentication account if profile creation fails. |
| 5 | Data Access | Firestore Repository Services | Provides create, read, update, delete, query, and stream operations for the application collections. |
| 6 | Maintenance Request | Request Image Upload | Uploads selected maintenance request images to Firebase Storage and stores their URLs in the request record. |
| 7 | Payment | Atomic Payment Status Update | Uses a Firestore batch to create or update a payment record and update the related bill status as one operation. |
| 8 | Dashboard | Dashboard Counter Aggregation | Counts apartments, Residents, pending requests, unpaid bills, and checked-in visitors through Firestore aggregate queries. |
| 9 | Search | Vietnamese Text Normalization | Normalizes Vietnamese characters to support case-insensitive and accent-insensitive search. |
| 10 | Localization | Vietnamese Date and Currency Formatting | Formats dates, date-times, billing months, and currency values using the `vi_VN` locale. |

#### 3.1.5 Entity Relationship Diagram

**Figure 3-2: ABMS Entity Relationship Diagram**

The entity relationship diagram shall contain the eight entities listed below. The entities `Meal`, `Meal Subscription`, and `Product` are not part of ABMS and shall be removed.

##### Entity Descriptions

| # | Entity | Description |
|---|---|---|
| 1 | User | Stores authentication-related profile data, role, apartment assignment, identity information, and account status for Admin, Staff, and Resident accounts. |
| 2 | Apartment | Stores apartment number, floor, building, physical information, occupancy status, owner, and assigned Residents. |
| 3 | Request | Stores a maintenance request submitted by a Resident, including category, description, images, processing status, assigned Staff, and resolution note. |
| 4 | Complaint | Stores a complaint or feedback item submitted by a Resident and the response provided by Admin or Staff. |
| 5 | Bill | Stores a bill assigned to an apartment and Resident for a billing month, including type, amount, due date, and payment status. |
| 6 | Payment | Stores a cash or bank-transfer payment record related to a bill, including verification status, proof reference, recorder, and rejection reason. |
| 7 | Notification | Stores an announcement created by Admin or Staff for one or more target roles. |
| 8 | Visitor | Stores a visitor registration and its expected time, check-in time, check-out time, status, and processing Staff. |

#### 3.1.6 Entity Details

##### User

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | uid | X | String | Yes | Firebase Authentication user identifier and Firestore document identifier. |
| 2 | email |  | String | Yes | Unique email address used for login. |
| 3 | fullName |  | String | Yes | User full name. |
| 4 | phone |  | String | Yes | Vietnamese phone number. |
| 5 | role |  | Enum | Yes | One of `admin`, `staff`, or `resident`. |
| 6 | apartmentId |  | String | No | Identifier of the apartment assigned to a Resident. |
| 7 | nationalId |  | String | Yes | National identity number. |
| 8 | dateOfBirth |  | Timestamp | No | User date of birth. |
| 9 | avatarUrl |  | String | No | URL of the profile image. |
| 10 | status |  | Enum | Yes | One of `active` or `inactive`. |
| 11 | createdAt |  | Timestamp | Yes | Account profile creation time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent profile update time. |

##### Apartment

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore apartment document identifier. |
| 2 | number |  | String | Yes | Apartment number. |
| 3 | floor |  | Integer | Yes | Floor number. |
| 4 | building |  | String | Yes | Building name or code. Release 1.0 uses one building. |
| 5 | area |  | Double | Yes | Apartment area in square metres. |
| 6 | ownerId |  | String | No | Identifier of the designated Resident owner. |
| 7 | status |  | Enum | Yes | One of `occupied` or `vacant`. |
| 8 | residentIds |  | Array of String | Yes | Identifiers of Residents assigned to the apartment. The array may be empty. |
| 9 | price |  | Double | No | Apartment rent or reference price in millions of VND. |
| 10 | type |  | String | No | Apartment layout, such as bedroom and bathroom configuration. |
| 11 | createdAt |  | Timestamp | No | Apartment record creation time. |
| 12 | updatedAt |  | Timestamp | No | Most recent apartment record update time. |

##### Request

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore maintenance request document identifier. |
| 2 | title |  | String | Yes | Short request title. |
| 3 | description |  | String | Yes | Detailed description of the maintenance issue. |
| 4 | category |  | Enum | Yes | One of `plumbing`, `electrical`, or `general`. |
| 5 | imageUrls |  | Array of String | Yes | URLs of uploaded request images. The array may be empty. |
| 6 | residentId |  | String | Yes | Identifier of the Resident who submitted the request. |
| 7 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 8 | status |  | Enum | Yes | One of `pending`, `in_progress`, or `completed`. |
| 9 | assignedStaffId |  | String | No | Identifier of the Staff assigned to the request. |
| 10 | resolutionNote |  | String | No | Processing or completion note entered by Staff or Admin. |
| 11 | createdAt |  | Timestamp | Yes | Request submission time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent request update time. |

##### Complaint

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore complaint document identifier. |
| 2 | content |  | String | Yes | Complaint or feedback content. |
| 3 | residentId |  | String | Yes | Identifier of the Resident who submitted the complaint. |
| 4 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 5 | status |  | Enum | Yes | One of `submitted`, `in_review`, or `resolved`. |
| 6 | response |  | String | No | Response entered by Admin or Staff. |
| 7 | respondedBy |  | String | No | Identifier of the Admin or Staff who responded. |
| 8 | respondedAt |  | Timestamp | No | Response time. |
| 9 | createdAt |  | Timestamp | Yes | Complaint submission time. |
| 10 | updatedAt |  | Timestamp | Yes | Most recent complaint update time. |

##### Bill

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | billId | X | String | Yes | Firestore bill document identifier. |
| 2 | apartmentId |  | String | Yes | Identifier of the billed apartment. |
| 3 | residentId |  | String | Yes | Identifier of the Resident responsible for the bill when available. |
| 4 | type |  | Enum | Yes | One of `electricity`, `water`, `service`, or `parking`. |
| 5 | amount |  | Double | Yes | Bill amount in VND. |
| 6 | billingMonth |  | String | Yes | Billing month in `YYYY-MM` format. |
| 7 | dueDate |  | Timestamp | Yes | Payment due date. |
| 8 | status |  | Enum | Yes | One of `unpaid`, `pending`, `paid`, or `overdue`. |
| 9 | paidAt |  | Timestamp | No | Time at which the bill was approved as paid. |
| 10 | paymentMethod |  | Enum | No | One of `cash` or `bank_transfer`. |
| 11 | createdBy |  | String | Yes | Identifier of the Staff who created the bill. |
| 12 | createdAt |  | Timestamp | Yes | Bill creation time. |
| 13 | updatedAt |  | Timestamp | Yes | Most recent bill update time. |

##### Payment

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | paymentId | X | String | Yes | Firestore payment document identifier. |
| 2 | billId |  | String | Yes | Identifier of the related bill. |
| 3 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 4 | residentId |  | String | Yes | Identifier of the Resident making the payment. |
| 5 | amount |  | Double | Yes | Payment amount in VND. |
| 6 | paymentMethod |  | Enum | Yes | One of `cash` or `bank_transfer`. |
| 7 | status |  | Enum | Yes | One of `pending`, `approved`, or `rejected`. |
| 8 | proofImageUrl |  | String | No | URL or reference for bank-transfer proof when implemented. |
| 9 | recordedBy |  | String | No | Identifier of the Staff who recorded, approved, or rejected the payment. |
| 10 | rejectReason |  | String | No | Reason entered when a payment is rejected. |
| 11 | createdAt |  | Timestamp | Yes | Payment record creation time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent payment record update time. |

##### Notification

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore announcement document identifier. |
| 2 | title |  | String | Yes | Announcement title. |
| 3 | content |  | String | Yes | Announcement content. |
| 4 | type |  | String | Yes | Announcement category or type. |
| 5 | createdBy |  | String | Yes | Identifier of the Admin or Staff who created the announcement. |
| 6 | targetRoles |  | Array of String | Yes | Roles allowed to receive or view the announcement. |
| 7 | createdAt |  | Timestamp | No | Announcement creation time. |
| 8 | updatedAt |  | Timestamp | No | Most recent announcement update time. |

##### Visitor

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore visitor document identifier. |
| 2 | visitorName |  | String | Yes | Visitor full name. |
| 3 | visitorPhone |  | String | Yes | Visitor phone number. |
| 4 | purpose |  | String | Yes | Purpose of the visit. |
| 5 | registeredBy |  | String | Yes | Identifier of the Resident who registered the visitor. |
| 6 | apartmentId |  | String | Yes | Identifier of the destination apartment. |
| 7 | expectedTime |  | Timestamp | No | Expected arrival time. |
| 8 | checkInTime |  | Timestamp | No | Actual check-in time. |
| 9 | checkOutTime |  | Timestamp | No | Actual check-out time. |
| 10 | status |  | Enum | Yes | One of `registered`, `checked_in`, or `checked_out`. |
| 11 | checkedInBy |  | String | No | Identifier of the Admin or Staff who checked in the visitor. |
| 12 | createdAt |  | Timestamp | No | Visitor registration time. |
| 13 | updatedAt |  | Timestamp | No | Most recent visitor record update time. |


The feature details below follow the required SRS template. Each function contains a reserved screen mock-up area, a screen definition table, and a detailed use case description.

### 3.2 Authentication and Profile Management

#### 3.2.1 UC-01 — Login

##### 3.2.1.1 Screen Mock-up

**Screen or UI scope:** Login

**Drawing requirements:** Draw the application identity, Email field, Password field with visibility toggle, Login button, loading state, inline validation, and authentication-error area.

**Mock-up reference:** See Appendix E.1. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.2.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Email | Email text field | Yes | N/A | Firebase login email. |
| 2 | Password | Password field | Yes | N/A | Masked password with show or hide control. |
| 3 | Login | Button | N/A | N/A | Validates input, authenticates, and redirects by role. |
| 4 | Authentication Error | Message area | N/A | N/A | Displays invalid credentials, inactive account, or network errors. |

##### 3.2.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-01|Authentication and Profile Management]]

#### 3.2.2 UC-02 — Logout

##### 3.2.2.1 Screen Mock-up

**Screen or UI scope:** Admin Dashboard or User Profile

**Drawing requirements:** Draw the Logout icon or button inside the Admin Dashboard app bar or User Profile screen and show the navigation result returning to Login.

**Mock-up reference:** See Appendix E.2, E.3, and E.4. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.2.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Logout | Icon button or button | N/A | N/A | Ends the current Firebase Authentication session. |
| 2 | Current User | Read-only context | Yes | N/A | The authenticated account whose session will be ended. |

##### 3.2.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-02|Authentication and Profile Management]]

#### 3.2.3 UC-03 — Change Password

##### 3.2.3.1 Screen Mock-up

**Screen or UI scope:** Change Password

**Drawing requirements:** Draw Current Password, New Password, Confirm New Password, visibility controls, validation messages, Change Password button, and Back action. Do not draw Forgot Password, OTP, or password recovery.

**Mock-up reference:** See Appendix E.1. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.2.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Current Password | Password field | Yes | N/A | Used to re-authenticate the current user. |
| 2 | New Password | Password field | Yes | N/A | New Firebase Authentication password. |
| 3 | Confirm New Password | Password field | Yes | N/A | Must match New Password. |
| 4 | Change Password | Button | N/A | N/A | Re-authenticates and updates the password. |

##### 3.2.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-03|Authentication and Profile Management]]

#### 3.2.4 UC-04 — View and Update Own Profile

##### 3.2.4.1 Screen Mock-up

**Screen or UI scope:** User Profile

**Drawing requirements:** Draw avatar or identity header, read-only Email, editable Full Name, Phone, National ID, Date of Birth, Save Profile, theme control, and Logout.

**Mock-up reference:** See Appendix E.1. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.2.4-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Email | Read-only email field | Yes | N/A | Login email; not editable. |
| 2 | Full Name | Text field | Yes | N/A | Editable user full name. |
| 3 | Phone | Phone field | Yes | N/A | Editable Vietnamese phone number. |
| 4 | National ID | Text field | Yes | N/A | Editable identity number. |
| 5 | Date of Birth | Date picker | No | N/A | Editable date of birth. |
| 6 | Save Profile | Button | N/A | N/A | Validates and saves permitted profile fields. |

##### 3.2.4.2 Use Case Description

[[USE_CASE_DETAIL|UC-04|Authentication and Profile Management]]

### 3.3 Dashboard

#### 3.3.1 UC-05 — View Dashboard Statistics

##### 3.3.1.1 Screen Mock-up

**Screen or UI scope:** Admin Home and Dashboard

**Drawing requirements:** Draw the Admin Dashboard app bar, Refresh and Logout actions, five counter cards, quick-access cards, and Admin bottom navigation.

**Mock-up reference:** See Appendix E.2. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.3.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Apartment Count | Read-only counter | N/A | N/A | Total apartments. |
| 2 | Resident Count | Read-only counter | N/A | N/A | Total Resident profiles. |
| 3 | Pending Requests | Read-only counter | N/A | N/A | Requests with Pending status. |
| 4 | Unpaid Bills | Read-only counter | N/A | N/A | Bills with Unpaid status. |
| 5 | Visitors Inside | Read-only counter | N/A | N/A | Visitors with Checked In status. |
| 6 | Refresh | Icon button | N/A | N/A | Reloads all dashboard counters. |

##### 3.3.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-05|Dashboard]]

### 3.4 User Management

#### 3.4.1 UC-06 — Manage User Accounts

##### 3.4.1.1 Screen Mock-up

**Screen or UI scope:** User List, User Create, and User Edit

**Drawing requirements:** Draw three frames: User List with search and filters; User Create with account fields; User Edit with role, apartment, and status controls.

**Mock-up reference:** See Appendix E.2. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.4.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Search | Search field | No | N/A | Searches name, email, or apartment. |
| 2 | Role Filter | Dropdown | No | N/A | Filters Admin, Staff, or Resident. |
| 3 | Status Filter | Dropdown | No | N/A | Filters Active or Inactive. |
| 4 | Email | Email field | Yes | N/A | Login email; immutable after creation. |
| 5 | Full Name | Text field | Yes | N/A | User full name. |
| 6 | Phone | Phone field | Yes | N/A | Vietnamese phone number. |
| 7 | National ID | Text field | Yes | N/A | Identity number. |
| 8 | Role | Dropdown | Yes | N/A | Admin, Staff, or Resident. |
| 9 | Apartment | Dropdown | No | N/A | Optional apartment assignment. |
| 10 | Status | Switch | Yes | N/A | Active or Inactive. |
| 11 | Create or Save | Button | N/A | N/A | Creates or updates the account. |

##### 3.4.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-06|User Management]]

### 3.5 Apartment and Resident Management

#### 3.5.1 UC-07 — Manage Apartments

##### 3.5.1.1 Screen Mock-up

**Screen or UI scope:** Apartment List, Apartment Form, and Apartment Details

**Drawing requirements:** Draw three frames: searchable Apartment List with floor and status filters; Apartment Form; Apartment Details with residents, Edit, Delete, and Assign Resident.

**Mock-up reference:** See Appendix E.10. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.5.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Search | Search field | No | N/A | Searches apartment or owner name. |
| 2 | Floor Filter | Dropdown | No | N/A | Filters by floor. |
| 3 | Status Filter | Dropdown | No | N/A | Vacant or Occupied. |
| 4 | Apartment Number | Text field | Yes | N/A | Apartment number. |
| 5 | Floor | Number field | Yes | N/A | Floor number. |
| 6 | Building | Text field | Yes | N/A | Building name. |
| 7 | Area | Number field | Yes | N/A | Area in square metres. |
| 8 | Type | Text field | No | N/A | Apartment layout. |
| 9 | Price | Number field | No | N/A | Reference price. |
| 10 | Save | Button | N/A | N/A | Creates or updates the apartment. |
| 11 | Delete | Button | N/A | N/A | Deletes after confirmation. |

##### 3.5.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-07|Apartment and Resident Management]]

#### 3.5.2 UC-08 — Assign Resident

##### 3.5.2.1 Screen Mock-up

**Screen or UI scope:** Apartment Details and Resident Picker Dialog

**Drawing requirements:** Draw Apartment Details with the current resident list and an Assign Resident button. Draw the Resident Picker dialog used to select the Resident.

**Mock-up reference:** See Appendix E.10. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.5.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Current Residents | Read-only list | N/A | N/A | Resident identifiers assigned to the apartment. |
| 2 | Owner Indicator | Read-only label | N/A | N/A | Marks the Resident whose identifier equals ownerId. |
| 3 | Assign Resident | Button | N/A | N/A | Opens the Resident Picker dialog. |
| 4 | Resident Selection | Dialog list | Yes | N/A | Selects the Resident to assign. |

##### 3.5.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-08|Apartment and Resident Management]]

#### 3.5.3 UC-09 — Manage Resident Records

##### 3.5.3.1 Screen Mock-up

**Screen or UI scope:** Resident List, Resident Form, and Resident Profile

**Drawing requirements:** Draw Resident List with search and status filter, Resident Form with identity and apartment fields, and read-only Resident Profile details.

**Mock-up reference:** See Appendix E.2. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.5.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Search | Search field | No | N/A | Searches name, phone, or apartment. |
| 2 | Status Filter | Dropdown | No | N/A | Active or Inactive. |
| 3 | Resident ID | Text field | Yes | N/A | Firestore profile identifier. |
| 4 | Email | Email field | Yes | N/A | Resident email. |
| 5 | Full Name | Text field | Yes | N/A | Resident full name. |
| 6 | Phone | Phone field | Yes | N/A | Resident phone. |
| 7 | National ID | Text field | Yes | N/A | Resident identity number. |
| 8 | Apartment | Dropdown | No | N/A | Apartment assignment. |
| 9 | Status | Dropdown | Yes | N/A | Active or Inactive. |
| 10 | Save | Button | N/A | N/A | Creates or updates the Resident profile. |

##### 3.5.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-09|Apartment and Resident Management]]

### 3.6 Maintenance Request Management

#### 3.6.1 UC-10 — Submit Maintenance Request

##### 3.6.1.1 Screen Mock-up

**Screen or UI scope:** Request Create

**Drawing requirements:** Draw Title, Category chips or dropdown, Description, image picker, image preview list with remove actions, image counter, and Submit Request.

**Mock-up reference:** See Appendix E.5. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.6.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Title | Text field | Yes | N/A | Short request title. |
| 2 | Category | Choice control | Yes | N/A | Plumbing, Electrical, or General. |
| 3 | Description | Multiline field | Yes | N/A | Issue description. |
| 4 | Images | Image picker | No | N/A | Up to three images. |
| 5 | Submit Request | Button | N/A | N/A | Uploads images and creates request. |

##### 3.6.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-10|Maintenance Request Management]]

#### 3.6.2 UC-11 — View Own Maintenance Requests

##### 3.6.2.1 Screen Mock-up

**Screen or UI scope:** My Request List and Request Details

**Drawing requirements:** Draw a Resident request list with status badges and a detail frame containing category, description, images, status, processing account, and resolution note.

**Mock-up reference:** See Appendix E.5. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.6.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Request List | Read-only list | N/A | N/A | Current Resident requests. |
| 2 | Status Badge | Read-only badge | N/A | N/A | Current request status. |
| 3 | Request Details | Read-only fields | N/A | N/A | Complete request information. |
| 4 | Resolution Note | Read-only text | No | N/A | Staff or Admin resolution note. |

##### 3.6.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-11|Maintenance Request Management]]

#### 3.6.3 UC-12 — Manage Maintenance Requests

##### 3.6.3.1 Screen Mock-up

**Screen or UI scope:** Request Management and Request Details

**Drawing requirements:** Draw status-filter tabs, request cards, request detail, status dropdown, resolution-note field, and Update Status button.

**Mock-up reference:** See Appendix E.5. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.6.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Status Filter | Tabs or dropdown | No | N/A | Filters request status. |
| 2 | Request Details | Read-only fields | N/A | N/A | Submitted request data. |
| 3 | Status | Dropdown | Yes | N/A | Pending, In Progress, or Completed. |
| 4 | Resolution Note | Multiline field | No | N/A | Processing or completion note. |
| 5 | Update Status | Button | N/A | N/A | Saves status and processing account. |

##### 3.6.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-12|Maintenance Request Management]]

### 3.7 Complaint and Feedback Management

#### 3.7.1 UC-13 — Submit Complaint or Feedback

##### 3.7.1.1 Screen Mock-up

**Screen or UI scope:** Complaint Create

**Drawing requirements:** Draw a complaint or feedback multiline field, validation message, Resident and apartment context, and Submit Complaint button.

**Mock-up reference:** See Appendix E.7. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.7.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Content | Multiline field | Yes | N/A | Complaint or feedback content. |
| 2 | Resident and Apartment | Read-only context | Yes | N/A | Derived from authenticated profile. |
| 3 | Submit Complaint | Button | N/A | N/A | Creates a Submitted complaint. |

##### 3.7.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-13|Complaint and Feedback Management]]

#### 3.7.2 UC-14 — View Own Complaints

##### 3.7.2.1 Screen Mock-up

**Screen or UI scope:** My Complaint List and Complaint Details

**Drawing requirements:** Draw complaint cards with status badges and a details frame containing content, status, response, responder, and response time.

**Mock-up reference:** See Appendix E.7. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.7.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Complaint List | Read-only list | N/A | N/A | Current Resident complaints. |
| 2 | Status Badge | Read-only badge | N/A | N/A | Complaint status. |
| 3 | Response | Read-only text | No | N/A | Admin or Staff response. |
| 4 | Response Time | Read-only date-time | No | N/A | Time of response. |

##### 3.7.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-14|Complaint and Feedback Management]]

#### 3.7.3 UC-15 — Review and Respond to Complaint

##### 3.7.3.1 Screen Mock-up

**Screen or UI scope:** Complaint Management and Complaint Details

**Drawing requirements:** Draw status filter, complaint list, complaint details, Mark In Review, Response field, and Resolve action.

**Mock-up reference:** See Appendix E.7. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.7.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Status Filter | Dropdown | No | N/A | Filters complaint status. |
| 2 | Complaint Details | Read-only fields | N/A | N/A | Submitted complaint data. |
| 3 | Mark In Review | Button | N/A | N/A | Changes status to In Review. |
| 4 | Response | Multiline field | Yes for resolve | N/A | Response content. |
| 5 | Resolve | Button | N/A | N/A | Stores response and resolves complaint. |

##### 3.7.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-15|Complaint and Feedback Management]]

### 3.8 Bill and Manual Payment Management

#### 3.8.1 UC-16 — Create Bill

##### 3.8.1.1 Screen Mock-up

**Screen or UI scope:** Bill Create

**Drawing requirements:** Draw Apartment Identifier, Bill Type, Amount, Billing Month, Due Date, validation messages, and Create Bill.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Apartment Identifier | Text field | Yes | N/A | Billed apartment. |
| 2 | Bill Type | Dropdown | Yes | N/A | Electricity, Water, Service, or Parking. |
| 3 | Amount | Number field | Yes | N/A | Positive VND amount. |
| 4 | Billing Month | Text field | Yes | N/A | YYYY-MM. |
| 5 | Due Date | Date picker | Yes | N/A | Payment due date. |
| 6 | Create Bill | Button | N/A | N/A | Creates an Unpaid bill. |

##### 3.8.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-16|Bill and Manual Payment Management]]

#### 3.8.2 UC-17 — View and Manage Bills

##### 3.8.2.1 Screen Mock-up

**Screen or UI scope:** Bill List and Bill Details

**Drawing requirements:** Draw bill filters, bill cards, totals, and Bill Details containing bill data, payment information, and the actions available for the current status.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Apartment Filter | Text or dropdown | No | N/A | Filters apartment. |
| 2 | Billing Month Filter | Text or dropdown | No | N/A | Filters month. |
| 3 | Status Filter | Dropdown | No | N/A | Filters bill status. |
| 4 | Bill List | Read-only list | N/A | N/A | Matching bills. |
| 5 | Bill Details | Read-only fields | N/A | N/A | Selected bill data. |

##### 3.8.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-17|Bill and Manual Payment Management]]

#### 3.8.3 UC-18 — View My Bills

##### 3.8.3.1 Screen Mock-up

**Screen or UI scope:** My Bills

**Drawing requirements:** Draw Resident apartment context, bill summary, status filter or grouping, bill cards with amount and due date, and navigation to Bill Payment.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Apartment | Read-only text | Yes | N/A | Authenticated Resident apartment. |
| 2 | Bill List | Read-only list | N/A | N/A | Bills for the apartment. |
| 3 | Bill Type | Read-only label | N/A | N/A | Bill category. |
| 4 | Amount | Read-only currency | N/A | N/A | Bill amount. |
| 5 | Due Date | Read-only date | N/A | N/A | Bill due date. |
| 6 | Status | Read-only badge | N/A | N/A | Bill status. |

##### 3.8.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-18|Bill and Manual Payment Management]]

#### 3.8.4 UC-19 — Submit Bank-Transfer Payment Confirmation

##### 3.8.4.1 Screen Mock-up

**Screen or UI scope:** Bill Payment

**Drawing requirements:** Draw bill summary, bank name, account number, transfer reference, copy actions, payment amount, confirmation explanation, and Confirm Transfer button.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.4-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Bill Summary | Read-only fields | Yes | N/A | Selected bill information. |
| 2 | Bank Name | Read-only text | Yes | N/A | Building bank. |
| 3 | Account Number | Read-only text | Yes | N/A | Destination account. |
| 4 | Transfer Reference | Read-only text | Yes | N/A | Required transfer content. |
| 5 | Copy | Icon buttons | N/A | N/A | Copies bank information. |
| 6 | Confirm Transfer | Button | N/A | N/A | Creates a Pending payment request. |

##### 3.8.4.2 Use Case Description

[[USE_CASE_DETAIL|UC-19|Bill and Manual Payment Management]]

#### 3.8.5 UC-20 — Record Cash Payment

##### 3.8.5.1 Screen Mock-up

**Screen or UI scope:** Bill Details — Record Cash Payment

**Drawing requirements:** Draw the Bill Details state for an Unpaid bill, Record Cash Payment button, confirmation dialog, and successful Paid state.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.5-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Bill Details | Read-only fields | Yes | N/A | Selected unpaid bill. |
| 2 | Record Cash Payment | Button | N/A | N/A | Opens cash-receipt confirmation. |
| 3 | Confirmation | Dialog | Yes | N/A | Confirms cash was received. |

##### 3.8.5.2 Use Case Description

[[USE_CASE_DETAIL|UC-20|Bill and Manual Payment Management]]

#### 3.8.6 UC-21 — Approve or Reject Bank Transfer

##### 3.8.6.1 Screen Mock-up

**Screen or UI scope:** Bill Details — Pending Bank Transfer

**Drawing requirements:** Draw Pending payment information, amount, payment method, proof reference, Approve button, Reject button, and rejection-reason dialog.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.6-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Pending Payment | Read-only fields | Yes | N/A | Payment awaiting verification. |
| 2 | Proof Reference | Read-only text | No | N/A | Stored transfer proof reference. |
| 3 | Approve | Button | N/A | N/A | Approves payment and marks bill Paid. |
| 4 | Reject | Button | N/A | N/A | Opens rejection-reason dialog. |
| 5 | Rejection Reason | Multiline field | Yes for reject | N/A | Required reason. |

##### 3.8.6.2 Use Case Description

[[USE_CASE_DETAIL|UC-21|Bill and Manual Payment Management]]

#### 3.8.7 UC-22 — View Payment History

##### 3.8.7.1 Screen Mock-up

**Screen or UI scope:** Payment History

**Drawing requirements:** Draw a chronological payment list with amount, method, status, date-time, and empty or error state.

**Mock-up reference:** See Appendix E.6. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.8.7-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Payment List | Read-only list | N/A | N/A | Resident or apartment payments. |
| 2 | Amount | Read-only currency | N/A | N/A | Payment amount. |
| 3 | Method | Read-only label | N/A | N/A | Cash or Bank Transfer. |
| 4 | Status | Read-only badge | N/A | N/A | Pending, Approved, or Rejected. |
| 5 | Date and Time | Read-only date-time | N/A | N/A | Payment creation time. |

##### 3.8.7.2 Use Case Description

[[USE_CASE_DETAIL|UC-22|Bill and Manual Payment Management]]

### 3.9 Announcement Management

#### 3.9.1 UC-23 — View Announcements

##### 3.9.1.1 Screen Mock-up

**Screen or UI scope:** Announcement List and Announcement Details

**Drawing requirements:** Draw announcement cards with title, type, and date, followed by an Announcement Details frame. Show create or edit controls only for Admin and Staff.

**Mock-up reference:** See Appendix E.9. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.9.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Announcement List | Read-only list | N/A | N/A | In-app announcements. |
| 2 | Title | Read-only text | Yes | N/A | Announcement title. |
| 3 | Content | Read-only text | Yes | N/A | Announcement content. |
| 4 | Type | Read-only label | Yes | N/A | Announcement type. |
| 5 | Created Time | Read-only date-time | No | N/A | Creation time. |

##### 3.9.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-23|Announcement Management]]

#### 3.9.2 UC-24 — Manage Announcements

##### 3.9.2.1 Screen Mock-up

**Screen or UI scope:** Announcement Create or Edit and Announcement Details

**Drawing requirements:** Draw Title, Content, Type, Target Roles, Save, Edit, Delete, and the delete-confirmation dialog.

**Mock-up reference:** See Appendix E.9. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.9.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Title | Text field | Yes | N/A | Announcement title. |
| 2 | Content | Multiline field | Yes | N/A | Announcement content. |
| 3 | Type | Text or dropdown | Yes | N/A | Announcement type. |
| 4 | Target Roles | Multi-select | Yes | N/A | Stored role metadata. |
| 5 | Save | Button | N/A | N/A | Creates or updates announcement. |
| 6 | Delete | Button | N/A | N/A | Deletes after confirmation. |

##### 3.9.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-24|Announcement Management]]

### 3.10 Visitor Management

#### 3.10.1 UC-25 — Register Visitor

##### 3.10.1.1 Screen Mock-up

**Screen or UI scope:** Visitor Registration

**Drawing requirements:** Draw Visitor Name, Phone, Purpose, Expected Time, apartment context, validation messages, and Register Visitor.

**Mock-up reference:** See Appendix E.8. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.10.1-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Visitor Name | Text field | Yes | N/A | Visitor full name. |
| 2 | Visitor Phone | Phone field | Yes | N/A | Visitor phone number. |
| 3 | Purpose | Text field | Yes | N/A | Purpose of visit. |
| 4 | Expected Time | Date-time picker | No | N/A | Expected arrival. |
| 5 | Apartment | Read-only or selected value | Yes | N/A | Destination apartment. |
| 6 | Register Visitor | Button | N/A | N/A | Creates Registered visitor. |

##### 3.10.1.2 Use Case Description

[[USE_CASE_DETAIL|UC-25|Visitor Management]]

#### 3.10.2 UC-26 — View Visitor List

##### 3.10.2.1 Screen Mock-up

**Screen or UI scope:** Visitor List

**Drawing requirements:** Draw search, visitor cards, identity, apartment, expected time, status badge, check-in time, check-out time, and context-sensitive actions.

**Mock-up reference:** See Appendix E.8. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.10.2-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Search | Search field | No | N/A | Searches visitor information. |
| 2 | Visitor List | Read-only list | N/A | N/A | Registered visitors. |
| 3 | Apartment | Read-only text | Yes | N/A | Destination apartment. |
| 4 | Expected Time | Read-only date-time | No | N/A | Expected arrival. |
| 5 | Status | Read-only badge | Yes | N/A | Visitor status. |

##### 3.10.2.2 Use Case Description

[[USE_CASE_DETAIL|UC-26|Visitor Management]]

#### 3.10.3 UC-27 — Check In or Check Out Visitor

##### 3.10.3.1 Screen Mock-up

**Screen or UI scope:** Visitor List — Check-In and Check-Out Actions

**Drawing requirements:** Draw Registered state with Check In, Checked In state with Check Out, Checked Out final state, timestamps, and operation feedback.

**Mock-up reference:** See Appendix E.8. The hand-drawn image is inserted once in the shared mock-up group to avoid duplicating the same screen in multiple use cases.

**Table 3.10.3-1: Screen Definition**

| # | Field Name | Type | Mandatory | Max Length | Description |
|---|---|---|---|---|---|
| 1 | Visitor Details | Read-only fields | Yes | N/A | Selected visitor. |
| 2 | Check In | Button | N/A | N/A | Available only for Registered. |
| 3 | Check Out | Button | N/A | N/A | Available only for Checked In. |
| 4 | Check-In Time | Read-only date-time | No | N/A | Recorded arrival. |
| 5 | Check-Out Time | Read-only date-time | No | N/A | Recorded departure. |

##### 3.10.3.2 Use Case Description

[[USE_CASE_DETAIL|UC-27|Visitor Management]]

## 4. Non-Functional Requirements

### 4.1 External Interfaces

| Interface | Description |
|---|---|
| Android and iOS Mobile Application | The Flutter mobile application is the user interface for Admin, Staff, and Resident. The application is designed primarily for portrait orientation. |
| Firebase Authentication | Authenticates users by email and password, maintains the authentication session, supports password change, and provides Firebase user identifiers. |
| Cloud Firestore | Stores user profiles, apartments, maintenance requests, complaints, bills, payments, announcements, and visitor records. |
| Firebase Storage | Stores uploaded maintenance request images and provides their download URLs. |
| Device Clipboard | Allows the Resident to copy bank account or transfer-reference information from the manual payment screen. |

The following interfaces are not part of Release 1.0:

- VNPay, MoMo, or another payment gateway.
- An in-app wallet.
- A separate Web Admin application.
- Face recognition hardware or services.
- An Excel or PDF report export service.
- An automated backup and restore interface exposed by the application.

### 4.2 Quality Attributes

#### 4.2.1 Usability

The system shall meet the following usability requirements:

1. The user interface shall be Vietnamese-first and use the `vi_VN` locale for dates and currency.
2. Each role shall be redirected to a home screen containing only the functions intended for that role.
3. Frequently used functions shall be reachable from the role home screen or bottom navigation.
4. Forms shall identify required fields and display validation errors close to the invalid field.
5. Password fields shall mask entered characters and allow the user to toggle visibility.
6. List screens shall provide loading, error, empty, and data states.
7. Destructive actions, including apartment deletion, announcement deletion, and user deactivation, shall require explicit confirmation.
8. Statuses shall be displayed with readable labels and visually distinct status indicators.
9. Monetary values shall be displayed in Vietnamese currency format.
10. The application shall provide feedback after successful or failed create, update, approval, rejection, check-in, and check-out operations.

#### 4.2.2 Reliability

The system shall meet the following reliability requirements:

1. A failed Firestore operation shall not be presented as successful.
2. The application shall display an error message and retain a usable navigation state when a data operation fails.
3. Payment approval, payment rejection, cash recording, and related bill-status updates shall use Firestore batched writes so that related records are updated together.
4. If user account provisioning creates a Firebase Authentication account but fails to create the Firestore profile, the system shall attempt to roll back the new authentication account.
5. The application shall prevent duplicate submission by disabling or guarding a submit action while the corresponding request is being processed.
6. A missing or invalid user profile shall not grant access to a role home screen.
7. Firestore timestamps shall be recorded for creation and update events where supported by the entity.
8. Quantitative production availability, Mean Time Between Failures, and Mean Time To Repair targets shall be defined only when a deployed environment and an operational monitoring process are available.

#### 4.2.3 Performance

The system shall meet the following performance requirements for the Release 1.0 scope:

1. The apartment list shall support the expected building capacity of approximately 36 to 48 apartments.
2. Search and local filtering shall update without requiring a full application restart.
3. A screen shall display an immediate loading indicator when a network request begins.
4. Firestore list results shall be sorted or filtered without blocking normal user interaction.
5. Dashboard counters shall use Firestore count aggregation rather than downloading all documents solely to calculate totals.
6. Images displayed from remote URLs shall use loading placeholders and error handling where applicable.
7. Formal response-time and concurrent-user claims shall be accompanied by a documented test environment and measured results before being stated as verified Release 1.0 characteristics.

#### 4.2.4 Security

The system shall meet the following security requirements:

1. All protected application screens shall require an authenticated Firebase session.
2. Admin routes shall not be accessible to Staff or Resident through the application router.
3. Staff operational routes shall not be accessible to Resident through the application router.
4. User account creation, role changes, and account-status changes shall be restricted to Admin through the intended application flow.
5. An Inactive account shall not be allowed to continue using protected application data.
6. Passwords shall be managed by Firebase Authentication and shall not be stored in Cloud Firestore.
7. Password input shall be masked.
8. A user shall not be permitted to change the account role, status, or apartment assignment through personal profile editing.
9. Firestore Security Rules shall be reviewed before production deployment so that collection-level read and write permissions enforce the same authorization described in Section 3.1.3.
10. API keys and secrets that require confidentiality shall not be committed to the repository.

#### 4.2.5 Maintainability

The system shall meet the following maintainability requirements:

1. The Flutter source code shall follow Dart naming and formatting conventions.
2. Business data structures shall be represented by dedicated model classes.
3. Firebase operations shall be separated into service classes.
4. Screen state shall be managed through Provider-based state classes.
5. Route paths and Firestore collection names shall be defined as shared constants.
6. Reusable loading, empty, error, confirmation, form, and status widgets shall be shared across features.
7. New business logic shall include unit tests, and critical user-interface behaviour shall include widget tests.
8. Source code, comments, and variable names shall be written in English.

#### 4.2.6 Compatibility

1. The application shall support Android and iOS targets supported by the configured Flutter project.
2. The primary mobile interface shall support portrait-up and portrait-down orientations.
3. The application shall use a consistent Material theme and bundled font assets.
4. Release 1.0 does not require a separate browser-based Admin interface.

---

## 5. Requirement Appendix

### 5.1 Business Rules

| ID | Rule Definition |
|---|---|
| BR-01 | The system supports exactly three application roles in Release 1.0: Admin, Staff, and Resident. |
| BR-02 | A user account has either Active or Inactive status. Locked is not a Release 1.0 account status. |
| BR-03 | Only Admin can create accounts, assign roles, change another account status, and manage account apartment assignments through the intended application flow. |
| BR-04 | User accounts are deactivated instead of being permanently deleted in Release 1.0. |
| BR-05 | An Admin cannot deactivate the account currently being used. |
| BR-06 | A Resident account may be assigned to at most one apartment through `apartmentId`. |
| BR-07 | An apartment may contain multiple Resident identifiers and may have one optional owner identifier. |
| BR-08 | Maintenance request categories are Plumbing, Electrical, and General. |
| BR-09 | Maintenance request statuses are Pending, In Progress, and Completed. |
| BR-10 | Complaint statuses are Submitted, In Review, and Resolved. |
| BR-11 | Bill types are Electricity, Water, Service, and Parking. |
| BR-12 | Bill statuses are Unpaid, Pending, Paid, and Overdue. |
| BR-13 | Payment methods are Cash and Bank Transfer. |
| BR-14 | Payment statuses are Pending, Approved, and Rejected. |
| BR-15 | A submitted bank-transfer confirmation places both the payment and the related bill into Pending state. |
| BR-16 | Approval of a payment changes the payment to Approved and the related bill to Paid. |
| BR-17 | Rejection of a bank-transfer confirmation requires a reason, changes the payment to Rejected, and returns the related bill to Unpaid. |
| BR-18 | A cash payment recorded by Staff is created as Approved and changes the related bill to Paid. |
| BR-19 | Release 1.0 does not automatically deduct fees and does not process refunds through an in-app wallet. |
| BR-20 | Admin and Staff can create, edit, and delete announcements; Resident can only view announcements. |
| BR-21 | A new visitor registration has Registered status. A visitor must be Checked In before being Checked Out. |
| BR-22 | A destructive operation requires explicit confirmation before execution. |
| BR-23 | Application dates and currency values use Vietnamese display formatting. |

### 5.2 Common Requirements

| ID | Requirement |
|---|---|
| CR-01 | Required text fields shall reject empty input. |
| CR-02 | Email fields shall validate email format. |
| CR-03 | Vietnamese phone numbers shall be validated according to the application phone rules. |
| CR-04 | Submit actions shall display progress and shall not allow unintended repeated submission while processing. |
| CR-05 | Successful operations shall display a confirmation message. |
| CR-06 | Failed operations shall display a user-friendly Vietnamese error message. |
| CR-07 | Empty list results shall display a dedicated empty state rather than a blank screen. |
| CR-08 | Data-loading failures shall provide a retry action where the screen supports retry. |
| CR-09 | Search input shall be trimmed before matching. |
| CR-10 | Date-time values shall be stored as Firestore timestamps and displayed in Vietnamese format. |
| CR-11 | Currency amounts shall be stored as numeric values and displayed as Vietnamese currency. |
| CR-12 | Record creation and update operations shall maintain creation and update timestamps where defined by the entity. |
| CR-13 | The application shall use shared route constants instead of duplicating route path strings. |
| CR-14 | The application shall use shared collection-name constants for defined Firestore collections. |

### 5.3 Application Messages List

| # | Message Code | Message Type | Context | Content |
|---|---|---|---|---|
| 1 | MSG-001 | Inline | Email is empty | Vui lòng nhập email. |
| 2 | MSG-002 | Inline | Email format is invalid | Email không hợp lệ. |
| 3 | MSG-003 | Inline | Login password is empty | Vui lòng nhập mật khẩu. |
| 4 | MSG-004 | Error message | Login credentials are invalid | Email hoặc mật khẩu không đúng. |
| 5 | MSG-005 | Error message | Account is inactive | Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên. |
| 6 | MSG-006 | Success message | Password changed successfully | Đổi mật khẩu thành công. |
| 7 | MSG-007 | Empty state | Search has no matching result | Không tìm thấy kết quả phù hợp. |
| 8 | MSG-008 | Success message | User account created | Tạo tài khoản thành công. |
| 9 | MSG-009 | Confirmation dialog | Admin deactivates a user | Vô hiệu hóa tài khoản? Người dùng sẽ không thể truy cập ứng dụng cho đến khi được kích hoạt lại. |
| 10 | MSG-010 | Confirmation dialog | Admin deletes an apartment | Xóa căn hộ? Thao tác này không thể hoàn tác. |
| 11 | MSG-011 | Success message | Maintenance request submitted | Gửi yêu cầu thành công. |
| 12 | MSG-012 | Success message | Maintenance request status updated | Cập nhật trạng thái yêu cầu thành công. |
| 13 | MSG-013 | Success message | Complaint submitted | Gửi khiếu nại thành công. |
| 14 | MSG-014 | Success message | Complaint response saved | Phản hồi khiếu nại thành công. |
| 15 | MSG-015 | Success message | Bill created | Tạo hóa đơn thành công. |
| 16 | MSG-016 | Confirmation dialog | Resident submits bank-transfer confirmation | Bạn xác nhận đã thực hiện chuyển khoản số tiền này đến tài khoản Ban quản lý? |
| 17 | MSG-017 | Success message | Payment confirmation submitted | Yêu cầu thanh toán đã được gửi. Vui lòng chờ Ban quản lý đối soát và phê duyệt. |
| 18 | MSG-018 | Success message | Staff approves payment | Đã xác nhận thanh toán thành công. |
| 19 | MSG-019 | Success message | Staff rejects payment | Đã từ chối yêu cầu thanh toán. |
| 20 | MSG-020 | Confirmation dialog | Admin or Staff deletes an announcement | Xóa thông báo? Thao tác này không thể hoàn tác. |
| 21 | MSG-021 | Success message | Announcement created or updated | Lưu thông báo thành công. |
| 22 | MSG-022 | Success message | Visitor registered | Đăng ký khách thăm thành công. |
| 23 | MSG-023 | Success message | Visitor checked in | Check-in khách thành công. |
| 24 | MSG-024 | Success message | Visitor checked out | Check-out khách thành công. |
| 25 | MSG-025 | Error message | General Firestore operation fails | Không thể thực hiện thao tác. Vui lòng thử lại. |

### 5.4 Release Scope Exclusions

The following functions are explicitly excluded from Release 1.0:

1. Payment gateway integration with VNPay, MoMo, banks, or e-wallet providers.
2. In-app wallet balance, wallet top-up, automatic deduction, and automatic refund.
3. Automatic monthly invoice generation by a scheduled job.
4. Automatic late-fee calculation.
5. Contract management.
6. Amenity booking.
7. Separate service-order management.
8. Face registration and face authentication.
9. Vehicle management.
10. A separate Web Admin application.
11. Excel or PDF report export.
12. System settings management.
13. Audit-log screens.
14. Application-level database backup and restore.
15. Verified production uptime, MTBF, MTTR, and concurrent-user service-level claims without deployment monitoring and performance-test evidence.

---

# Diagram Redrawing Guide

Phần này dùng để vẽ tay. Tên actor, use case, screen và entity nên giữ bằng tiếng Anh để đồng nhất với nội dung SRS.

## A. Figure 1-1 — System Context Diagram

### Thành phần phải có

Vẽ một khối trung tâm:

- `Apartment Building Management System — Flutter Mobile App`

Vẽ ba actor người dùng ở bên trái:

1. `Admin`
2. `Staff`
3. `Resident`

Vẽ ba dịch vụ Firebase ở bên phải:

1. `Firebase Authentication`
2. `Cloud Firestore`
3. `Firebase Storage`

### Luồng dữ liệu cần ghi

Giữa `Admin` và hệ thống:

- User and role management.
- Apartment and Resident management.
- Announcements.
- Dashboard data.
- Request, complaint, and visitor review.

Giữa `Staff` và hệ thống:

- Maintenance processing.
- Bill creation.
- Payment verification.
- Complaint response.
- Visitor check-in and check-out.
- Announcement management.

Giữa `Resident` và hệ thống:

- Login and profile.
- Maintenance requests.
- Complaints and feedback.
- Bills and payment confirmations.
- Visitor registrations.
- Announcements.

Giữa hệ thống và `Firebase Authentication`:

- Login credentials.
- Authentication result.
- Session state.
- Password update.

Giữa hệ thống và `Cloud Firestore`:

- User profiles.
- Apartments.
- Requests.
- Complaints.
- Bills and payments.
- Announcements.
- Visitors.

Giữa hệ thống và `Firebase Storage`:

- Request images.
- Download URLs.

### Thành phần phải xóa khỏi sơ đồ cũ

- `Payment Gateway`.
- `Payment Request`.
- `Transaction Result`.
- `System Report` dưới dạng file export.
- `Task Assignment` nếu sơ đồ đang thể hiện một hệ thống phân công công việc riêng.
- `Worker order update`.
- `Configuration / User Management` nếu nó được nối với actor `System Admin` cũ; thay bằng các luồng Admin ở trên.

Không thêm `Web Admin`, `Wallet`, `VNPay`, `MoMo`, `Face Authentication`, `Vehicle`, `Contract`, `Amenity`, `Service Order`, `Backup`, hoặc `Audit Log`.

## B. Figure 2-1 — Use Case Diagram

### Actors

Chỉ dùng ba actor:

- `Admin`
- `Staff`
- `Resident`

Không dùng:

- `Payment Gateway`
- `System Admin` như một role tách biệt với Admin
- `Building Staff` nếu tài liệu đã chọn tên role là Staff
- `BQL Manager`
- `BQL Staff`
- `BQT Head`
- `BQT Member`

### Cách bố cục khuyến nghị

Nếu một sơ đồ duy nhất quá dày, chia thành ba hình:

1. `Figure 2-1a: Shared and Admin Use Cases`
2. `Figure 2-1b: Staff Use Cases`
3. `Figure 2-1c: Resident Use Cases`

Nếu giảng viên yêu cầu đúng một hình, dùng các package bên trong system boundary:

- Authentication and Profile.
- Administration.
- Maintenance and Complaint.
- Bill and Payment.
- Announcement.
- Visitor.

### Use case chung cho cả ba actor

Nối `Admin`, `Staff`, và `Resident` với:

- `Login`
- `Logout`
- `Change Password`
- `View and Update Own Profile`
- `View Announcements`

Quan hệ:

- `Login` `<<include>>` `Validate Credentials`
- `Login` `<<include>>` `Load User Profile`
- `Login` `<<include>>` `Redirect by Role`

Ba use case include có thể bỏ khỏi hình nếu cần giảm độ phức tạp, nhưng không được thêm Payment Gateway.

### Use case của Admin

Nối `Admin` với:

- `View Dashboard Statistics`
- `Manage User Accounts`
- `Manage Apartments`
- `Assign Resident`
- `Manage Resident Records`
- `Manage Maintenance Requests`
- `Review and Respond to Complaint`
- `Manage Announcements`
- `View Visitor List`
- `Check In or Check Out Visitor`

Quan hệ:

- `Manage User Accounts` `<<include>>` `Create User`
- `Manage User Accounts` `<<include>>` `Edit User`
- `Manage User Accounts` `<<include>>` `Assign Role`
- `Manage User Accounts` `<<include>>` `Activate or Deactivate User`
- `Manage Apartments` `<<include>>` `View Apartment List`
- `Manage Apartments` `<<include>>` `Create or Update Apartment`
- `Manage Apartments` `<<include>>` `View Apartment Details`
- `Assign Resident` có thể đặt là `<<extend>>` từ `View Apartment Details` vì chỉ thực hiện khi Admin mở chi tiết căn hộ.
- `Manage Resident Records` `<<include>>` `View Resident List`
- `Manage Resident Records` `<<include>>` `Create or Update Resident`
- `Manage Maintenance Requests` `<<include>>` `Update Request Status`
- `Review and Respond to Complaint` `<<include>>` `Update Complaint Status`
- `Manage Announcements` `<<include>>` `Create or Edit Announcement`
- `Delete Announcement` `<<extend>>` `Manage Announcements`
- `Check In or Check Out Visitor` `<<extend>>` `View Visitor List`

### Use case của Staff

Nối `Staff` với:

- `Manage Maintenance Requests`
- `Create Bill`
- `View and Manage Bills`
- `Record Cash Payment`
- `Approve or Reject Bank Transfer`
- `Review and Respond to Complaint`
- `Manage Announcements`
- `View Visitor List`
- `Check In or Check Out Visitor`

Quan hệ:

- `View and Manage Bills` `<<include>>` `View Bill Details`
- `Record Cash Payment` `<<extend>>` `View Bill Details`
- `Approve or Reject Bank Transfer` `<<extend>>` `View Bill Details`
- `Manage Maintenance Requests` `<<include>>` `Update Request Status`
- `Review and Respond to Complaint` `<<include>>` `Update Complaint Status`
- `Check In or Check Out Visitor` `<<extend>>` `View Visitor List`

### Use case của Resident

Nối `Resident` với:

- `Submit Maintenance Request`
- `View Own Maintenance Requests`
- `Submit Complaint or Feedback`
- `View Own Complaints`
- `View My Bills`
- `Submit Bank-Transfer Payment Confirmation`
- `View Payment History`
- `Register Visitor`

Quan hệ:

- `Submit Bank-Transfer Payment Confirmation` `<<extend>>` `View My Bills`
- `View Request Details` `<<extend>>` `View Own Maintenance Requests`
- `View Complaint Details` `<<extend>>` `View Own Complaints`

### Use case phải xóa khỏi sơ đồ cũ

- `Process Payment` qua Payment Gateway.
- `Generate Monthly Invoice`.
- `View Reports`.
- `Export Report`.
- `Confirm Request` như một trạng thái riêng.

### Use case phải đổi tên

- `Feedback` → `Submit Complaint or Feedback`
- `Manage Maintenance` → `Manage Maintenance Requests`
- `View Request Status` → `View Own Maintenance Requests`
- `Pay Invoice` → `Submit Bank-Transfer Payment Confirmation`
- `System Admin` → `Admin`
- `Building Staff` → `Staff`

## C. Figure 3-1 — Role-Based Screen Flow

### Luồng bắt đầu

Vẽ:

`Splash → Login`

Từ `Splash`, thêm nhánh:

- Có session hợp lệ và profile Active → `Role Decision`
- Không có session → `Login`
- Profile thiếu hoặc Inactive → `Login with Error Message`

Từ `Login`:

`Login → Role Decision`

Từ `Role Decision`, tạo ba nhánh:

- Role = Admin → `Admin Home`
- Role = Staff → `Staff Home`
- Role = Resident → `Resident Home`

### Nhánh Admin

Từ `Admin Home`, nối đến:

- `Dashboard`
- `User List`
- `Apartment List`
- `Resident List`
- `Announcement List`
- `Request Management`
- `Complaint Management`
- `Visitor List`
- `User Profile`

Các luồng con:

- `User List → User Create`
- `User List → User Edit`
- `Apartment List → Apartment Form`
- `Apartment List → Apartment Details`
- `Apartment Details → Apartment Form`
- `Apartment Details → Assign Resident Dialog`
- `Resident List → Resident Form`
- `Resident List → Resident Profile`
- `Announcement List → Announcement Details`
- `Announcement List → Announcement Create or Edit`
- `Request Management → Request Details`
- `Complaint Management → Complaint Details`
- `Visitor List → Check-In or Check-Out Action`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Nhánh Staff

Từ `Staff Home`, nối đến năm tab và một lối tắt:

- `Request Management`
- `Bill List`
- `Visitor List`
- `Complaint Management`
- `User Profile`
- `Announcement List`

Các luồng con:

- `Request Management → Request Details`
- `Bill List → Bill Create`
- `Bill List → Bill Details`
- `Bill Details → Record Cash Payment`
- `Bill Details → Approve or Reject Bank Transfer`
- `Visitor List → Check-In or Check-Out Action`
- `Complaint Management → Complaint Details`
- `Announcement List → Announcement Details`
- `Announcement List → Announcement Create or Edit`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Nhánh Resident

Từ `Resident Home`, nối đến:

- `My Bills`
- `My Request List`
- `My Complaint List`
- `Announcement List`
- `Visitor Registration`
- `Payment History`
- `User Profile`

Các luồng con:

- `My Bills → Bill Payment`
- `My Request List → Request Create`
- `My Request List → Request Details`
- `My Complaint List → Complaint Create`
- `My Complaint List → Complaint Details`
- `Announcement List → Announcement Details`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Node phải xóa khỏi screen flow cũ

- `ContractMgmt`
- `ContractList`
- `ContractDetail`
- `AmenityMgmt`
- `AmenityList`
- `BookingPage`
- `ServiceMgmt`
- `ServiceList`
- `ServiceOrder`
- `PaymentPage` nếu nó thể hiện gateway hoặc ví

### Node phải thêm so với screen flow cũ

- `Splash`
- `Admin Home`
- `Staff Home`
- `Resident Home`
- `User List`
- `User Create`
- `User Edit`
- `Resident Form`
- `Request Create`
- `Request Management`
- `Complaint List`
- `Complaint Create`
- `Complaint Details`
- `Complaint Management`
- `Bill Create`
- `Bill Details`
- `My Bills`
- `Bill Payment`
- `Payment History`
- `Announcement Create or Edit`
- `Visitor List`
- `Check-In or Check-Out Action`
- `Change Password`
- `User Profile`

## D. Figure 3-2 — Entity Relationship Diagram

### Entities

Vẽ đúng tám entity:

1. `User`
2. `Apartment`
3. `Request`
4. `Complaint`
5. `Bill`
6. `Payment`
7. `Notification`
8. `Visitor`

### Primary keys

- `User.uid`
- `Apartment.id`
- `Request.id`
- `Complaint.id`
- `Bill.billId`
- `Payment.paymentId`
- `Notification.id`
- `Visitor.id`

### Relationships và cardinality

1. `Apartment 1 — 0..* User`
   - Foreign key: `User.apartmentId → Apartment.id`
   - Ý nghĩa: một căn hộ có thể có nhiều Resident; một Resident được gán tối đa một căn hộ.

2. `Apartment 0..1 — 1 User as Owner`
   - Foreign key: `Apartment.ownerId → User.uid`
   - Ý nghĩa: một căn hộ có thể chưa có chủ hộ hoặc có một chủ hộ.

3. `Apartment 1 — 0..* Request`
   - Foreign key: `Request.apartmentId → Apartment.id`

4. `User 1 — 0..* Request as Submitter`
   - Foreign key: `Request.residentId → User.uid`

5. `User 0..1 — 0..* Request as Assigned Staff`
   - Foreign key: `Request.assignedStaffId → User.uid`
   - `assignedStaffId` là optional.

6. `Apartment 1 — 0..* Complaint`
   - Foreign key: `Complaint.apartmentId → Apartment.id`

7. `User 1 — 0..* Complaint as Submitter`
   - Foreign key: `Complaint.residentId → User.uid`

8. `User 0..1 — 0..* Complaint as Responder`
   - Foreign key: `Complaint.respondedBy → User.uid`

9. `Apartment 1 — 0..* Bill`
   - Foreign key: `Bill.apartmentId → Apartment.id`

10. `User 1 — 0..* Bill as Responsible Resident`
    - Foreign key: `Bill.residentId → User.uid`

11. `User 1 — 0..* Bill as Creator`
    - Foreign key: `Bill.createdBy → User.uid`

12. `Bill 1 — 0..* Payment`
    - Foreign key: `Payment.billId → Bill.billId`
    - Một bill có thể có nhiều lần xác nhận nếu lần trước bị từ chối.

13. `Apartment 1 — 0..* Payment`
    - Foreign key: `Payment.apartmentId → Apartment.id`

14. `User 1 — 0..* Payment as Payer`
    - Foreign key: `Payment.residentId → User.uid`

15. `User 0..1 — 0..* Payment as Recorder`
    - Foreign key: `Payment.recordedBy → User.uid`

16. `User 1 — 0..* Notification as Creator`
    - Foreign key: `Notification.createdBy → User.uid`
    - `targetRoles` là mảng role, không phải foreign key đến từng User.

17. `Apartment 1 — 0..* Visitor`
    - Foreign key: `Visitor.apartmentId → Apartment.id`

18. `User 1 — 0..* Visitor as Registering Resident`
    - Foreign key: `Visitor.registeredBy → User.uid`

19. `User 0..1 — 0..* Visitor as Check-In Processor`
    - Foreign key: `Visitor.checkedInBy → User.uid`

### Entity phải xóa khỏi ERD cũ

- `Meal`
- `Meal Subscription`
- `Product`
- Mọi entity mẫu không có model hoặc Firestore collection tương ứng.

### Lưu ý khi vẽ

- Gạch chân hoặc đánh dấu `PK` cho primary key.
- Đánh dấu `FK` cho các trường quan hệ.
- Ghi rõ enum cạnh entity hoặc trong phần ghi chú.
- Có thể không vẽ toàn bộ timestamp để sơ đồ dễ đọc, nhưng bảng Entity Details phải giữ đầy đủ timestamp.
- Không tạo entity `Role`; role đang được lưu bằng enum trong `User`.
- Không tạo entity `Payment Gateway`; Release 1.0 không có tích hợp này.
- Không tạo entity `Report`; Dashboard chỉ tổng hợp số lượng từ các collection hiện có.

## E. Screen Mock-Up Insertion Areas

The ten groups below are composite mock-up groups rather than ten individual screens. A group may contain multiple related frames. The hand-drawn image or image board shall be pasted inside the reserved bordered area.

### E.1 Login

**Use cases covered:** UC-01

**Frames to include:**

- Login

[[MOCKUP_AREA|E.1|Login]]

**Required content:**

- App logo or building illustration.
- Title: Welcome Back or the title currently used by the application.
- Email field with email icon.
- Password field with visibility toggle.
- Login button.
- Loading state on the Login button.
- Area for inline validation or authentication error.

**Do not draw:**

- Username field.
- Close button.
- Browser URL bar.
- LMS label.

### E.2 Admin Dashboard

**Use cases covered:** UC-02, UC-05, UC-06, and UC-09

**Frames to include:**

- Admin Dashboard

[[MOCKUP_AREA|E.2|Admin Dashboard]]

**Required content:**

- App bar with Admin Dashboard, Refresh, and Logout.
- Five counters: Apartments, Residents, Pending Requests, Unpaid Bills, and Visitors Inside.
- Quick access: User Accounts, Apartments, Maintenance Requests, Complaints, Visitors, and Announcements.
- Bottom navigation: Dashboard, Apartments, Residents, and Profile.

**Do not draw:**

- Functions or role labels that do not exist in the current application.
- Report export, system settings, audit logs, backup, or restore controls.

### E.3 Staff Home

**Use cases covered:** UC-02 and Staff entry points

**Frames to include:**

- Staff Home

[[MOCKUP_AREA|E.3|Staff Home]]

**Required content:**

- Indexed content area.
- Bottom navigation: Requests, Bills, Visitors, Complaints, and Profile.
- Announcement floating action button.

**Do not draw:**

- Admin-only apartment or user-account administration.
- Payment Gateway or wallet controls.

### E.4 Resident Home

**Use cases covered:** UC-02 and Resident entry points

**Frames to include:**

- Resident Home

[[MOCKUP_AREA|E.4|Resident Home]]

**Required content:**

- Resident greeting or apartment summary.
- Quick actions: Bills, Maintenance Requests, Complaints, and Announcements.
- Visitor Registration card.
- Payment History card.
- Bottom navigation matching the implemented Resident Home structure.

**Do not draw:**

- Admin or Staff management actions.
- Wallet balance or automatic deduction controls.

### E.5 Request Create

**Use cases covered:** UC-10, representative of the Maintenance Request feature

**Frames to include:**

- Request Create

[[MOCKUP_AREA|E.5|Request Create]]

**Required content:**

- Title.
- Category selector: Plumbing, Electrical, and General.
- Description.
- Image picker and image preview list.
- Submit button.
- Inline validation.

**Do not draw:**

- Confirmed status.
- A separate Service Order module.

### E.6 Bill Details and Payment Verification

**Use cases covered:** UC-17, UC-19, UC-20, and UC-21

**Frames to include:**

- Staff version
- Resident version

[[MOCKUP_AREA|E.6|Bill Details and Payment Verification]]

**Required content:**

- Staff version: bill type, apartment, amount, month, due date, and status.
- Staff version: pending payment information when available.
- Staff version: Record Cash Payment.
- Staff version: Approve Bank Transfer.
- Staff version: Reject Bank Transfer.
- Staff version: reject-reason dialog.
- Resident version: bill information.
- Resident version: building bank name and account number.
- Resident version: transfer reference.
- Resident version: copy actions.
- Resident version: confirmation button.
- Resident version: text explaining that Staff must verify the transfer.

**Do not draw:**

- VNPay, MoMo, or another Payment Gateway.
- In-app wallet, automatic deduction, or automatic refund.

### E.7 Complaint Management

**Use cases covered:** UC-13, UC-14, and UC-15

**Frames to include:**

- Complaint Management

[[MOCKUP_AREA|E.7|Complaint Management]]

**Required content:**

- Status filter.
- Complaint list.
- Complaint content and Resident or apartment information.
- Mark In Review action.
- Response input.
- Resolve action.

**Do not draw:**

- A separate feedback system unrelated to complaints.

### E.8 Visitor Management

**Use cases covered:** UC-25, UC-26, and UC-27

**Frames to include:**

- Resident version
- Staff or Admin version

[[MOCKUP_AREA|E.8|Visitor Management]]

**Required content:**

- Resident version: visitor name.
- Resident version: phone number.
- Resident version: purpose.
- Resident version: expected time.
- Resident version: Register button.
- Staff or Admin version: search.
- Staff or Admin version: visitor list.
- Staff or Admin version: status badge.
- Staff or Admin version: Check-In action for Registered.
- Staff or Admin version: Check-Out action for Checked In.
- Staff or Admin version: check-in and check-out timestamps.

**Do not draw:**

- Face verification.
- Vehicle registration.

### E.9 Announcement

**Use cases covered:** UC-23 and UC-24

**Frames to include:**

- Announcement List
- Announcement Create or Edit
- Announcement Details

[[MOCKUP_AREA|E.9|Announcement]]

**Required content:**

- List: announcement cards with title, type, and date.
- List: Create button visible only to Admin and Staff.
- Create or Edit: Title.
- Create or Edit: Content.
- Create or Edit: Type.
- Create or Edit: Target Roles.
- Create or Edit: Save button.
- Details: title, content, type, creator, and time.
- Details: Edit and Delete visible only to Admin and Staff.

**Do not draw:**

- A claim that push-notification delivery is already implemented.
- Resident create, edit, or delete controls.

### E.10 Apartment Details

**Use cases covered:** UC-07 and UC-08

**Frames to include:**

- Apartment Details

[[MOCKUP_AREA|E.10|Apartment Details]]

**Required content:**

- Apartment number, floor, building, area, type, price, and status.
- Owner section.
- Resident member list.
- Assign Resident.
- Edit.
- Delete with confirmation.

**Do not draw:**

- Contract Management.
- Amenity Booking.

# Final Consistency Checklist

Trước khi đưa nội dung vào `SRS.docx`, kiểm tra đủ các điểm sau:

- Toàn bộ tài liệu chỉ dùng ba role: Admin, Staff, Resident.
- Không còn BQL Manager, BQL Staff, BQT Head, hoặc BQT Member.
- Không còn Payment Gateway trong Release 1.0.
- Không còn wallet, automatic deduction, automatic refund, hoặc payment retry.
- Thanh toán được mô tả là manual cash hoặc manual bank transfer với Staff verification.
- Request status là Pending, In Progress, Completed.
- Complaint status là Submitted, In Review, Resolved.
- User status là Active hoặc Inactive.
- Visitor status là Registered, Checked In, Checked Out.
- Không còn Contract, Amenity, Service Order, Face Authentication, Vehicle, System Settings, Audit Log, Backup/Restore, hoặc Export Report trong scope Release 1.0.
- Screen flow có ba nhánh sau Login.
- Use case diagram có đúng ba actor.
- ERD có đúng tám entity.
- Không còn `Meal`, `Meal Subscription`, `Product`, `LMS User`, `HungNV`, hoặc ngày `11/05/2013`.
- Giao diện được mô tả là Vietnamese-first, không phải English-only.
- Mobile App phục vụ cả ba role; không mô tả một Web Admin riêng.
- Push notification không được tuyên bố là đã triển khai; Release 1.0 chỉ có in-app announcements.
- Các chỉ tiêu uptime, MTBF, MTTR, response time, và concurrent users chỉ được ghi là verified nếu nhóm có test evidence.
- Authorization table chỉ có ba cột role.
- Application messages phản ánh đúng ngữ cảnh và loại message.
