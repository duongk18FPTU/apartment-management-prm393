# Quy Trình Làm Việc Với Git & GitHub (Git Workflow)

Tài liệu này quy định quy trình làm việc với Git, cách quản lý nhánh (branch), và các quy tắc bảo vệ nhánh chính (`main`) đã được thiết lập trên GitHub cho dự án **Apartment Building Management System**. Tất cả 5 thành viên trong nhóm bắt buộc phải tuân thủ quy trình này để tránh xung đột mã nguồn (conflict) và mất mát dữ liệu.

---

## 🛡️ 1. Các Quy Tắc Bảo Vệ Nhánh Chính (`main`)

Nhánh `main` là nhánh chứa mã nguồn ổn định nhất của dự án (luôn ở trạng thái có thể chạy được). Chúng ta đã thiết lập **Branch Ruleset** trên GitHub để bảo vệ nhánh `main` với các cấu hình bắt buộc sau:

| Quy tắc bảo vệ | Trạng thái | Mô tả |
| :--- | :---: | :--- |
| **Bấm chặn đẩy mã trực tiếp** (No Direct Push) | 🚫 **Bắt buộc** | Không thành viên nào (kể cả Admin) được phép sử dụng `git push origin main` trực tiếp từ máy cá nhân lên GitHub. |
| **Yêu cầu Pull Request trước khi Merge** | 🔄 **Bắt buộc** | Mọi thay đổi code muốn đưa vào `main` đều phải thông qua việc tạo **Pull Request (PR)** từ một nhánh phụ. |
| **Số lượng phê duyệt tối thiểu (Approvals)** | 👤 **0** | Hiện tại quy định phê duyệt là **0** (có thể tự merge PR của chính mình sau khi tạo PR), tuy nhiên khuyến khích nhờ thành viên khác review nếu code phức tạp. |
| **Hủy phê duyệt cũ khi có commit mới** | 🔄 **Bật** | Nếu PR đã được duyệt nhưng bạn push thêm commit mới lên nhánh phụ đó, toàn bộ phê duyệt cũ sẽ bị hủy để bắt đầu review lại từ đầu. |
| **Ngăn chặn xóa nhánh** (Restrict deletions) | 🚫 **Bật** | Không ai được phép xóa nhánh `main` trên GitHub. |
| **Chặn ép buộc đẩy** (Block force pushes) | 🚫 **Bật** | Tuyệt đối cấm sử dụng lệnh `git push --force` hoặc `git push -f` lên nhánh `main` để tránh ghi đè làm mất code của người khác. |

---

## 🔄 2. Quy Trình Phát Triển Tính Năng (GitHub Flow)

Chúng ta sử dụng mô hình **GitHub Flow** tối giản và hiệu quả. Luồng công việc diễn ra như sau:

```mermaid
gitgraph
    commit id: "Khởi tạo"
    branch feature/login
    checkout feature/login
    commit id: "Giao diện đăng nhập"
    commit id: "Logic đăng nhập"
    checkout main
    merge feature/login id: "PR #1 (Merge vào main)"
    branch feature/dashboard
    checkout feature/dashboard
    commit id: "Giao diện dashboard"
    checkout main
    merge feature/dashboard id: "PR #2 (Merge vào main)"
    branch bugfix/payment
    checkout bugfix/payment
    commit id: "Sửa lỗi thanh toán"
    checkout main
    merge bugfix/payment id: "PR #3 (Merge vào main)"
```

### Chi tiết các bước thực hiện:

#### Bước 1: Cập nhật code mới nhất từ nhánh `main` về máy
Trước khi làm tính năng mới, hãy đảm bảo local repo của bạn đồng bộ với GitHub:
```bash
git checkout main
git pull origin main
```

#### Bước 2: Tạo nhánh phụ mới từ `main`
Tạo nhánh phụ để viết tính năng mới hoặc sửa lỗi. Tên nhánh phải đặt theo quy định:
- **Tính năng mới:** `feature/<tên-tính-năng>` (Ví dụ: `feature/apartment-list`, `feature/resident-card`)
- **Sửa lỗi:** `bugfix/<tên-lỗi>` (Ví dụ: `bugfix/fix-payment-crash`)

Lệnh tạo nhánh:
```bash
git checkout -b feature/apartment-list
```

#### Bước 3: Lập trình và commit
Lập trình trên nhánh phụ vừa tạo. Commit thường xuyên với tin nhắn rõ ràng theo chuẩn **Conventional Commits**:
- `feat(scope): ...` (Thêm tính năng)
- `fix(scope): ...` (Sửa lỗi)
- `docs(scope): ...` (Viết tài liệu)

Ví dụ:
```bash
git add .
git commit -m "feat(apartment): create visual list of apartments"
```

#### Bước 4: Đẩy nhánh phụ lên GitHub
Sau khi hoàn thành tính năng và test chạy thử không lỗi:
```bash
git push -u origin feature/apartment-list
```

#### Bước 5: Tạo Pull Request (PR) trên GitHub
- Truy cập vào giao diện GitHub của repo: [apartment-management-prm393](https://github.com/duongk18FPTU/apartment-management-prm393).
- Nhấp chọn nút **Compare & pull request** màu vàng vừa hiển thị.
- Điền đầy đủ mô tả PR (những gì bạn đã làm) và tạo PR.

#### Bước 6: Merge Pull Request và Dọn dẹp
- Kiểm tra các xung đột (conflict) nếu có. Nếu không có conflict, nhấn nút **Merge pull request** màu xanh để gộp code vào `main`.
- Xóa nhánh phụ trên GitHub sau khi đã merge thành công để giữ repo sạch sẽ.
- Quay lại máy cá nhân, chuyển sang `main` và cập nhật lại code:
  ```bash
  git checkout main
  git pull origin main
  git branch -d feature/apartment-list
  ```

---

## ⚠️ 3. Xử Lý Xung Đột Code (Resolve Conflict)

Nếu hai người cùng sửa đổi trên một dòng code ở hai nhánh khác nhau, khi tạo PR hoặc merge sẽ xảy ra hiện tượng **Conflict**.

### Cách xử lý:
1. Chuyển sang nhánh phụ của bạn trên máy cá nhân:
   ```bash
   git checkout feature/apartment-list
   ```
2. Pull code mới nhất từ `main` đè vào nhánh của bạn:
   ```bash
   git pull origin main
   ```
3. Git sẽ báo các file bị conflict. Mở các file đó lên bằng VS Code hoặc Android Studio, chọn giữ lại code của bạn, của `main`, hoặc kết hợp cả hai.
4. Sau khi sửa hết lỗi conflict, thực hiện commit và push lại:
   ```bash
   git add .
   git commit -m "chore: resolve merge conflicts with main"
   git push origin feature/apartment-list
   ```
5. Quay lại GitHub và tiến hành merge PR bình thường.
