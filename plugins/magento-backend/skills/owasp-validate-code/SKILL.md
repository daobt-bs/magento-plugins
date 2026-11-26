---
name: owasp-validate-code
description: Review code Magento 2 (backend PHP, XML cấu hình, .phtml, JS của module) theo bộ rule bảo mật OWASP Top 10:2025 của team (mã rule M2-Axx-yy). Dùng skill này mỗi khi user nhờ review/validate/kiểm tra bảo mật một PR, diff, module trong app/code hay một file Magento 2, hoặc hỏi "code này có lỗi bảo mật không", "check OWASP", "review security", "validate code", kể cả khi user không nhắc OWASP. Cũng dùng để tự rà lại code Magento vừa viết trước khi báo hoàn thành. Chỉ tập trung bảo mật (phân quyền, injection, upload, payment/webhook, secret, log, xử lý lỗi); coding standard và hiệu năng không thuộc skill này.
---

# Validate code Magento 2 theo OWASP

Skill này review một thay đổi Magento 2 bằng bộ rule `references/magento2-rules.md` (mã `M2-…`) và, khi cần, `references/general-rules.md` (mã `G-…`). Mỗi phát hiện phải trỏ về một mã rule, để dev biết đọc lý do ở đâu trong tài liệu dev `magento2/owasp-rules.md`.

Rule được đối chiếu với Magento 2.4.6-p4. Nếu dự án ở version khác, nói rõ trong kết quả rằng các lời khuyên gắn với class/API cụ thể (ví dụ `CspNonceProvider` chỉ có từ 2.4.7) chưa được xác nhận trên version đó.

## Quy trình

1. **Chốt phạm vi.** Lấy danh sách file cần review: `git diff --name-only <base>` cho PR, hoặc đường dẫn user đưa. Không có git thì hỏi đường dẫn. Review diff trước, đọc cả file đầy đủ khi cần hiểu ngữ cảnh (một dòng thêm vào controller chỉ có nghĩa khi biết class cha và interface).
2. **Đọc rule.** Đọc `references/magento2-rules.md` (khoảng 125 dòng). Chỉ mở `references/general-rules.md` khi code chạm thứ file M2 không phủ: luồng nhiều bước kiểm trạng thái (`G-A06-06`), export CSV/XLSX (`G-A05-02`), output của LLM (`G-A05-07`).
3. **Chạy quét tự động** để có danh sách ứng viên rẻ và đầy đủ:
   ```bash
   bash <skill-dir>/scripts/scan.sh <path> [<path>...]
   ```
   Script gom các lệnh tự kiểm của bộ rule (kèm `phpcs --standard=Magento2` nếu có). Nếu không có `phpcs` hoặc `php`, script tự báo; hãy nói điều đó trong kết quả và không tuyên bố đã chạy.
4. **Xác minh từng ứng viên bằng cách đọc code.** Grep chỉ tìm dấu hiệu cú pháp, nên nhiều hit là false positive (ví dụ `md5` cho cache key, `exit` trong CLI, controller public có chủ đích). Loại các hit không phải vi phạm, và ghi lý do loại nếu không hiển nhiên.
5. **Review tay phần grep không thấy.** Đây là phần tạo giá trị chính, vì lỗi phân quyền và logic không có dấu hiệu cú pháp. Với mỗi file thay đổi, tự hỏi theo nhóm:
   - **A01:** mỗi entity load theo ID từ request có kiểm chủ sở hữu không (kể cả ở REST, GraphQL)? Action ghi dữ liệu có là POST không? Controller admin có ACL riêng?
   - **A06:** giá/tổng/ID khách có đến từ request không? Có kiểu "đọc rồi ghi" trên coupon, tồn kho, số dư, giới hạn theo ngày mà không có update có điều kiện hoặc lock? Form public có captcha/giới hạn trên mọi đường vào? Module thanh toán có xác minh với cổng và so số tiền?
   - **A07/A08:** có tự viết đăng nhập/reset/session? Webhook có kiểm chữ ký, chống replay, xử lý một lần?
   - **A05:** output nào trong template chưa escape đúng ngữ cảnh; HTML dựng trong PHP; upload dùng allow-list rỗng hoặc lấy đuôi từ config.
   - **A10:** exception message có đến tay người dùng? Ghi nhiều bảng không transaction?
6. **Báo cáo** theo mẫu dưới.

## Mức độ

Bộ rule dev gắn mỗi rule một mức. Dùng nó làm mặc định, và hạ mức khi bạn chỉ ra được lý do cụ thể (không khai thác được, chạy trong cron nội bộ…), vì nếu mọi thứ đều "chặn merge" thì reviewer sẽ ngừng đọc.

- **Chặn merge (🔴):** mọi rule M2 *trừ* danh sách dưới.
- **Nên sửa (🟠):** `M2-A01-09`, `A02-03`, `A02-04`, `A02-05`, `A05-06`, `A06-02`, `A06-03`, `A07-03`, `A07-04`, `A08-04`, `A09-01`, `A10-03`.

## Mẫu báo cáo

Viết bằng ngôn ngữ user đang dùng. Chỉ liệt kê phát hiện thật; không viết "không có lỗi" cho nhóm trống.

```markdown
## Review bảo mật Magento 2 — <phạm vi: PR/module/file>

### 🔴 Chặn merge
1. **<tên ngắn>** — `<file>:<dòng>` — `M2-A01-05`
   - Vấn đề: <code đang làm gì, 1–2 câu>
   - Hậu quả: <kẻ tấn công/khách làm được gì>
   - Sửa: <thay đổi cụ thể, kèm đoạn code nếu ngắn>

### 🟠 Nên sửa
2. ...

### Đã kiểm, cần người quyết định
- <điểm chưa chắc: cần chạy thử/hỏi nghiệp vụ, ví dụ "hạ tầng có bật reCAPTCHA ở tầng khác không">

### Tóm tắt
- File đã review: <n> · Phát hiện: <a> 🔴, <b> 🟠
- Công cụ đã chạy: scan.sh <đã chạy / lỗi gì>; phpcs <đã chạy / không có trong môi trường>
- Chưa kiểm: <ví dụ: không chạy được code, không có source vendor để đối chiếu>
- Kết luận: <Chặn merge / Duyệt kèm góp ý / Duyệt>
```

Đánh số liên tục qua các mục để dev có thể trả lời "mục 3 sửa rồi".

## Nguyên tắc khi review

- **Mỗi phát hiện dẫn một mã rule và `file:dòng`.** Không có mã thì đó là ý kiến, không phải vi phạm của bộ rule; nêu như góp ý riêng hoặc bỏ.
- **Đừng tự bịa API Magento.** Khi đề xuất cách sửa, dùng đúng class/method trong rule. Rule không nêu thì nói "cần kiểm tra trên version của dự án" thay vì đoán.
- **Báo trung thực phần chưa kiểm.** Rule tự nhận chúng "giảm rủi ro chứ không loại bỏ". Review không chạy code thì không khẳng định khai thác được, chỉ nói "theo luồng code".
- **Rule yêu cầu dừng thì dừng.** Nếu việc đang review (hoặc code mới viết) buộc phải phá một rule, nói rõ rule nào và vì sao, thay vì lách.
- **Code do chính bạn vừa viết** cũng qua đúng quy trình này (bước 3–6) trước khi báo xong; hai lượt: rà diff theo rule, sửa, rồi rà lại.

## Nguồn của rule

`references/*.md` là bản sao của `magento2/owasp-rules.ai.md` và `general/owasp-rules.ai.md` trong bộ final-solution (DMAGENTOBE-12). Khi bộ rule đổi, copy lại hai file đó và cập nhật `scripts/scan.sh` nếu lệnh tự kiểm đổi. Lý do và ví dụ đầy đủ của từng rule nằm ở `magento2/owasp-rules.md` (bản dev); mở nó khi cần giải thích cho dev vì sao một rule tồn tại.
