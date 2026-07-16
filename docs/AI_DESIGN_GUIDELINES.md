# Hướng Dẫn Sử Dụng Taste Skill & Google DESIGN.md

Tài liệu này hướng dẫn cách áp dụng hệ thống thiết kế **Google DESIGN.md** kết hợp với bộ kỹ năng **Taste Skill** để giúp các thành viên trong nhóm làm việc với AI Coding Agents (Gemini, Cursor, Claude Code, Copilot) nhằm tạo ra các giao diện di động chất lượng cao, thẩm mỹ và nhất quán cho dự án **Apartment Building Management System**.

---

## 🎨 1. Google DESIGN.md là gì?

[DESIGN.md](DESIGN.md) là file đặc tả hệ thống thiết kế (Design System) kết hợp giữa:
1. **Dữ liệu máy đọc (YAML Front Matter):** Chứa các Design Tokens như bảng màu (colors), cỡ chữ (typography), góc bo tròn (rounded), khoảng cách (spacing), và các thông số của component.
2. **Dữ liệu người đọc (Markdown Prose):** Giải thích lý do và cách áp dụng các token này trong thiết kế thực tế.

### Cấu trúc cơ bản của DESIGN.md trong dự án:
```yaml
---
name: Modern Haven
colors:
  primary: "#1E293B"      # Màu Slate chính
  secondary: "#D97706"    # Màu Amber dùng làm điểm nhấn
  background: "#F8FAFC"   # Nền sáng dịu mắt
rounded:
  md: 12px
spacing:
  md: 16px
---
## Colors
Giải thích cách sử dụng màu...
```

### Công cụ CLI hữu ích:
*   **Kiểm tra tính hợp lệ (Lint):** Đảm bảo cú pháp YAML đúng và độ tương phản màu sắc đạt tiêu chuẩn tiếp cận (WCAG).
    ```bash
    npx @google/design.md lint DESIGN.md
    ```
*   **So sánh phiên bản (Diff):** Kiểm tra sự thay đổi giữa các phiên bản thiết kế của nhóm.
    ```bash
    npx @google/design.md diff DESIGN.md DESIGN-v2.md
    ```

---

## ⚡ 2. Taste Skill là gì?

**Taste Skill** là tập hợp các bộ quy tắc thẩm mỹ được cài đặt trực tiếp trong thư mục [.agents/skills/](.agents/skills/). Chúng định hướng và ép buộc AI Coding Agents phải từ bỏ thói quen sinh code UI mặc định, nhàm chán (AI template slop) để hướng tới các tiêu chuẩn giao diện hiện đại:
- **Tránh xa placeholder:** Bắt buộc AI sử dụng dữ liệu thực tế thay vì dùng text giả vô nghĩa.
- **Micro-animations:** Tích hợp các chuyển động mượt mà khi người dùng tương tác.
- **Layout hiện đại:** Sử dụng bento grid, cấu trúc bất đối xứng tinh tế, khoảng cách thoáng đãng.

---

## 🚀 3. Hướng dẫn cách làm việc với AI

Khi lập trình viên trong nhóm yêu cầu AI sinh code giao diện (Widget, Screen hoặc Components), hãy sử dụng các câu lệnh (prompts) có nhắc đến hai tệp tin này để AI tự động cấu hình đúng chuẩn.

### Quy trình 3 bước chuẩn khi yêu cầu AI code UI:
1. **Chỉ định Nguồn thiết kế:** Nhắc AI đọc file `DESIGN.md`.
2. **Chỉ định Phong cách thẩm mỹ:** Yêu cầu áp dụng một skill cụ thể trong thư mục `.agents/skills/` (ví dụ: `minimalist-ui`, `high-end-visual-design`).
3. **Mô tả tính năng màn hình:** Nêu rõ các yêu cầu nghiệp vụ của màn hình đó.

---

## 💬 4. Mẫu câu lệnh gợi ý (Prompts Templates)

Dưới đây là một số câu lệnh mẫu các thành viên có thể copy để chat trực tiếp với AI:

### Mẫu 1: Dựng màn hình Danh sách căn hộ (Phong cách Tối giản - Minimalist)
> *"Dựng cho tôi màn hình Danh sách căn hộ. Hãy tuân thủ nghiêm ngặt **DESIGN.md** ở gốc dự án và sử dụng phong cách **minimalist-ui** từ **Taste Skill** để giao diện trông thật cao cấp, thoáng đãng, các thẻ căn hộ có bo tròn và đổ bóng đúng theo đặc tả."*

### Mẫu 2: Dựng màn hình Dashboard / Số liệu thống kê (Phong cách Dashboard Hiện đại)
> *"Hãy thiết kế Widget Dashboard hiển thị doanh thu dịch vụ và tỷ lệ lấp đầy căn hộ. Tham chiếu các token màu sắc từ **DESIGN.md** (dùng màu Primary và Tertiary cho biểu đồ). Áp dụng các nguyên tắc từ **high-end-visual-design** của **Taste Skill** để các biểu đồ và card thông tin có khoảng cách (spacing) hợp lý và hiệu ứng tải (loading shimmer) mượt mà."*

### Mẫu 3: Thiết kế các nút bấm & Form nhập liệu (Components chuẩn)
> *"Tạo form nhập thông tin cư dân mới. Sử dụng component `button-primary` và các input field bo tròn `rounded.sm` được định nghĩa trong **DESIGN.md**. Đảm bảo code Flutter sử dụng đúng hệ 8dp spacing và không sử dụng màu sắc hardcode ngoài hệ thống."*

---

## 📌 Lưu ý quan trọng cho cả nhóm

1. **Không hardcode màu sắc:** Không viết trực tiếp `Colors.blue` hoặc `Color(0xFF...)` trong code widget. Hãy khai báo chúng trong Theme của ứng dụng (ánh xạ từ `DESIGN.md`) hoặc sử dụng file hằng số màu sắc được đồng bộ.
2. **Kiểm tra lints trước khi PR:** Trước khi tạo Pull Request, hãy chắc chắn đã chạy lệnh check định dạng code để AI không sinh ra các đoạn mã dư thừa:
   ```bash
   flutter analyze
   dart format .
   ```
