# OWASP Top 10:2025 — Coding rule chung cho mọi platform

> **Bản v2.4, chờ duyệt để phát hành** · cập nhật 2026-11-18 · dành cho dev mọi platform (PHP, Python, JavaScript…).
> Đọc kèm: [bản Magento 2](owasp-rules-m2.md) (cụ thể hoá từng rule) · [bản cho AI](../references/general-rules.md) (cùng mã rule, rút gọn).
> Nguồn nội dung: [OWASP Top 10:2025](https://top10.owasp.org/2025) và [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/), cả hai theo giấy phép [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Tài liệu này diễn đạt lại và link tới nguồn, không phải bản dịch.

**Tóm tắt 1 dòng:** 48 rule code trung lập với framework, rút từ 10 nhóm rủi ro của OWASP Top 10:2025 và cheat sheet tương ứng, cộng 8 rule khi dùng AI để viết code (Phần B). Mỗi rule có ví dụ sai/đúng hoặc cách làm đúng, cách kiểm khi review, và link nguồn.

## OWASP Top 10 là gì

OWASP Top 10 là danh sách 10 **nhóm rủi ro** bảo mật phổ biến nhất của ứng dụng web, do tổ chức phi lợi nhuận OWASP tổng hợp từ dữ liệu lỗ hổng thật và cập nhật vài năm một lần. Bản dùng ở đây là bản 2025, bản final mới nhất; OWASP đã đánh dấu bản 2021 là bị thay thế.

Ba điều cần nhớ:
1. Nó là danh sách rủi ro, không phải coding rule. Tài liệu này là bước dịch từ rủi ro sang việc cụ thể khi viết code.
2. Làm đủ các rule dưới đây không có nghĩa là ứng dụng an toàn tuyệt đối; nó chỉ chặn các lỗi phổ biến nhất.
3. Một phần của Top 10 thuộc hạ tầng và quy trình, không phải việc của dev khi code (xem phụ lục).

## Cách đọc

- **Mã rule** `G-A05-01` = rule chung (General), nhóm A05, số 01. Bản Magento 2 dùng mã `M2-…` và ghi rõ nó cụ thể hoá rule `G-…` nào.
- **Mức:** 🔴 bắt buộc (vi phạm thì không merge) · 🟠 nên làm (bỏ qua phải ghi lý do trong PR) · 🟡 khuyến nghị.
- **Nguồn:** 📎 là yêu cầu lấy từ OWASP (trang Top 10:2025 và Cheat Sheet Series); 🔧 là cách team cụ thể hoá. Dòng **Nguồn:** dưới mỗi rule mới link thẳng tới cheat sheet; Phụ lục C ghi nguồn của mọi rule.
- **Nhóm A-số** theo nhóm của OWASP Top 10:2025. Vài rule cũ giữ mã cũ dù CWE chính của nó thuộc nhóm khác ở bản 2025; Phụ lục C ghi nhóm đúng.
- Ví dụ viết bằng PHP thuần và Python để minh hoạ; nguyên tắc áp dụng cho mọi ngôn ngữ.

## Mục lục

[Năm nguyên tắc nền](#năm-nguyên-tắc-nền) · [Checklist review PR](#checklist-review-pr-1-trang) · A01 Phân quyền · A02 Cấu hình · A03 Chuỗi cung ứng · A04 Mã hoá · A05 Injection · A06 Thiết kế · A07 Xác thực · A08 Toàn vẹn · A09 Log · A10 Xử lý lỗi · Phần B Khi dùng AI · Phụ lục A Ngoài phạm vi · Phụ lục B Bảng 2025/2021 · Phụ lục C Nguồn từng rule. Tìm nhanh một rule: Ctrl+F theo mã, ví dụ `G-A06-05`.

## Thuật ngữ và ký hiệu

| Ký hiệu / từ | Nghĩa |
|---|---|
| 📎 | Lấy từ nguồn OWASP (Top 10:2025 hoặc Cheat Sheet Series) |
| 🔧 | Lựa chọn của team, nguồn không nói |
| CS | Cheat Sheet (thuộc OWASP Cheat Sheet Series) |
| CWE | Mã loại điểm yếu phần mềm do MITRE quản lý, ví dụ CWE-89 là SQL injection |
| X01, X03 | Mục "Next Steps" ngoài Top 10 chính: X01 thiếu khả năng chống chịu và phục hồi (Lack of Application Resilience), X03 tin code AI sinh mà không kiểm |
| CSPRNG | Bộ sinh số ngẫu nhiên an toàn cho mật mã (`random_bytes`, `secrets`) |
| Idempotent | Chạy lại nhiều lần cho cùng kết quả như chạy một lần |
| OIDC | OpenID Connect, chuẩn đăng nhập qua bên thứ ba (Google, Microsoft…) |
| Checklist: tick | ☑ = đã kiểm và đạt; gạch dòng = không liên quan tới PR |

## Năm nguyên tắc nền

Hầu hết rule bên dưới là hệ quả của năm ý này. Gặp tình huống không có rule, quay về đây.

1. **Không tin dữ liệu từ bên ngoài.** Request, cookie, header, file upload, webhook, cả dữ liệu đọc lại từ database do người dùng nhập đều có thể bị sửa.
2. **Mặc định từ chối.** Quyền truy cập phải được cấp rõ ràng; quên cấu hình thì kết quả phải là bị chặn, không phải mở.
3. **Dùng cơ chế có sẵn của framework.** Phân quyền, đăng nhập, mã hoá, escape, truy vấn database đều đã có; tự viết lại là tự tạo lỗ hổng.
4. **Tách dữ liệu khỏi lệnh.** Dữ liệu không bao giờ được ghép vào SQL, HTML, dòng lệnh shell, đường dẫn file bằng nối chuỗi.
5. **Lỗi thì dừng an toàn.** Khi có lỗi: từ chối, rollback, ghi log, và không kể chi tiết cho người dùng.

## Checklist review PR (1 trang)

**A01 Phân quyền**
- [ ] 🔴 `G-A01-01` Mọi endpoint không public đều kiểm quyền ở server
- [ ] 🔴 `G-A01-02` Truy cập bản ghi theo ID có kiểm chủ sở hữu
- [ ] 🔴 `G-A01-03` Thao tác ghi dữ liệu có chống CSRF và không chạy bằng GET
- [ ] 🔴 `G-A01-04` Server không gọi tới URL do người dùng cung cấp
- [ ] 🟠 `G-A01-05` Redirect không lấy URL đích từ request

**A02 Cấu hình**
- [ ] 🔴 `G-A02-01` Không có file debug, backup, công cụ trong repo và thư mục public
- [ ] 🔴 `G-A02-02` Secret không nằm trong code; không bật debug hay hiển thị lỗi
- [ ] 🟠 `G-A02-03` Không làm yếu security header (CSP, CORS)
- [ ] 🟠 `G-A02-04` Cookie tự tạo có `Secure`, `HttpOnly`, `SameSite`; không lưu token trong `localStorage`
- [ ] 🟠 `G-A02-05` Parse XML không tin cậy với external entity bị chặn

**A03 Chuỗi cung ứng**
- [ ] 🔴 `G-A03-01` Thư viện cài qua package manager, không copy tay
- [ ] 🔴 `G-A03-02` Lock file được commit; công cụ audit không báo lỗ hổng
- [ ] 🟠 `G-A03-03` Package mới được nêu lý do trong PR

**A04 Mã hoá**
- [ ] 🔴 `G-A04-01` Không dùng MD5, SHA1 cho bảo mật; mật khẩu dùng hàm băm chuyên dụng
- [ ] 🔴 `G-A04-02` Giá trị ngẫu nhiên bảo mật lấy từ nguồn an toàn
- [ ] 🔴 `G-A04-03` Secret lưu trữ được mã hoá, không tự viết thuật toán
- [ ] 🔴 `G-A04-04` Không tắt kiểm chứng chỉ TLS
- [ ] 🔴 `G-A04-05` Response chứa dữ liệu riêng không được cache chung

**A05 Injection**
- [ ] 🔴 `G-A05-01` Truy vấn database dùng tham số hoá
- [ ] 🔴 `G-A05-02` Output được escape theo ngữ cảnh
- [ ] 🔴 `G-A05-03` Không ghép dữ liệu vào lệnh shell, `eval`, `include`
- [ ] 🔴 `G-A05-04` Upload và đường dẫn file được kiểm soát
- [ ] 🟠 `G-A05-05` Không dựng template từ dữ liệu; input không chọn template
- [ ] 🔴 `G-A05-06` URL tuyệt đối lấy từ cấu hình, không từ `Host`; không đưa input chưa kiểm vào header response
- [ ] 🟡 `G-A05-07` (nếu có tính năng LLM) Output của LLM được xử lý như input không tin cậy

**A06 Thiết kế**
- [ ] 🔴 `G-A06-01` Giá trị quan trọng tính ở server
- [ ] 🟠 `G-A06-02` Chức năng public có giới hạn tần suất
- [ ] 🟡 `G-A06-03` Có test cho trường hợp bị lạm dụng
- [ ] 🟠 `G-A06-04` Endpoint danh sách và bulk có giới hạn kích thước
- [ ] 🔴 `G-A06-05` "Kiểm rồi ghi" (coupon, tồn kho, số dư) chống được hai request đồng thời
- [ ] 🟠 `G-A06-06` Luồng nhiều bước kiểm trạng thái ở server trước mỗi bước
- [ ] 🔴 `G-A06-07` Thanh toán: xác minh với cổng ở server, khớp số tiền, xử lý một lần

**A07 Xác thực**
- [ ] 🔴 `G-A07-01` Dùng cơ chế xác thực của framework
- [ ] 🔴 `G-A07-02` Không hardcode tài khoản, mật khẩu, key
- [ ] 🟠 `G-A07-03` Thông báo lỗi không tiết lộ tài khoản tồn tại
- [ ] 🟠 `G-A07-04` Session ID mới sau đăng nhập; xác thực lại trước thao tác nhạy cảm
- [ ] 🔴 `G-A07-05` (nếu tự xử lý JWT) Cố định thuật toán, kiểm `exp`, `iss`, `aud`

**A08 Toàn vẹn dữ liệu**
- [ ] 🔴 `G-A08-01` Không deserialize dữ liệu không tin cậy bằng định dạng native
- [ ] 🔴 `G-A08-02` Không gán hàng loạt từ request vào model
- [ ] 🔴 `G-A08-03` Webhook kiểm chữ ký, chống gửi lại, xử lý một lần
- [ ] 🟠 `G-A08-04` Script bên thứ ba tự host hoặc có SRI

**A09 Log**
- [ ] 🟠 `G-A09-01` Sự kiện bảo mật được log kèm ngữ cảnh
- [ ] 🔴 `G-A09-02` Log không chứa dữ liệu nhạy cảm
- [ ] 🔴 `G-A09-03` Không còn output debug

**A10 Xử lý lỗi**
- [ ] 🔴 `G-A10-01` Không nuốt lỗi
- [ ] 🔴 `G-A10-02` Không lộ chi tiết lỗi cho người dùng
- [ ] 🟠 `G-A10-03` Thao tác nhiều bước có rollback
- [ ] 🔴 `G-A10-04` Kiểm giá trị trả về và trường hợp null

**B Khi code có AI tham gia** (áp cho mọi PR có code do AI viết hoặc sửa; PR không dùng AI thì gạch mục này)
- [ ] 🔴 `G-AI-01` Người tạo PR hiểu và chịu trách nhiệm mọi dòng, kể cả dòng AI viết
- [ ] 🔴 `G-AI-02` Đã đọc từng file trong diff, kể cả file ngoài phạm vi task
- [ ] 🔴 `G-AI-03` Không có test bị xoá, bị nới assertion, hoặc mock chính đối tượng đang test
- [ ] 🔴 `G-AI-04` Thay đổi ở file build, dependency, CI do AI tạo đã được review riêng
- [ ] 🔴 `G-AI-05` Không có secret, `.env`, key trong code hay context đưa cho AI
- [ ] 🟠 `G-AI-06` Thay đổi sau khi agent đọc nội dung từ bên ngoài (ticket, repo lạ) đã được review kỹ
- [ ] 🔴 `G-AI-07` Package mới do AI gợi ý đã kiểm có thật trên registry và đã audit
- [ ] 🔴 `G-AI-08` Không sửa file rule cho AI trong PR này, hoặc có reviewer duyệt riêng

---

## A01 — Broken Access Control (phân quyền hỏng)

📎 OWASP: người dùng làm được việc ngoài quyền của mình. Trừ tài nguyên public, mặc định từ chối; kiểm quyền sở hữu bản ghi; triển khai phân quyền một lần rồi tái sử dụng.

### G-A01-01 — Mọi endpoint không public đều kiểm quyền ở server
**Mức:** 🔴

**Vì sao:** ẩn nút trên giao diện không phải phân quyền. Ai biết URL hoặc đọc được JavaScript đều gọi thẳng được endpoint.

**❌ Sai** (Python/Flask)
```python
@app.route("/admin/users/<int:user_id>/delete", methods=["POST"])
def delete_user(user_id):
    User.query.filter_by(id=user_id).delete()
```

**✅ Đúng**
```python
@app.route("/admin/users/<int:user_id>/delete", methods=["POST"])
@require_permission("user.delete")
def delete_user(user_id):
    User.query.filter_by(id=user_id).delete()
```
Dùng cơ chế phân quyền khai báo của framework (ACL, policy, decorator). Endpoint mới mặc định yêu cầu quyền; endpoint public phải được đánh dấu rõ là public. Cùng một dữ liệu có nhiều đường vào (trang web, REST, GraphQL, export) thì mọi đường đều phải kiểm; 📎 OWASP yêu cầu kiểm quyền ở mọi request, kể cả với tài nguyên tĩnh.

📎 Authorization Decisions and Output Handling CS: kiểm quyền ở **mọi đường lấy dữ liệu**: list, search, export, count, aggregate. Có quyền xem danh sách không có nghĩa là được sửa hay xoá. Khi bộ kiểm quyền lỗi, timeout, hoặc không trả về điều kiện lọc thì **từ chối**; thiếu điều kiện lọc không có nghĩa là không giới hạn.

🔧 Đánh dấu endpoint public bằng cơ chế có trong code (decorator, attribute, danh sách trong config), không chỉ bằng comment, để kiểm được tự động.

**Kiểm:** liệt kê route mới trong PR; mỗi route trả lời được "ai được gọi, kiểm ở dòng nào".

### G-A01-02 — Truy cập bản ghi theo ID phải kiểm chủ sở hữu
**Mức:** 🔴

**Vì sao:** lỗi IDOR: đổi `id=1001` thành `1002` là xem hoặc sửa được dữ liệu của người khác. Đã đăng nhập không có nghĩa được truy cập mọi bản ghi.

**❌ Sai** (PHP)
```php
$invoice = $invoiceRepo->find((int)$_GET['id']);
return render($invoice);
```

**✅ Đúng**
```php
$invoice = $invoiceRepo->findOneBy(['id' => (int)$request->get('id'), 'ownerId' => $currentUser->getId()]);
if ($invoice === null) {
    throw new NotFoundException();
}
```
Đưa điều kiện chủ sở hữu vào chính câu truy vấn. Trả 404 thay vì 403 để không tiết lộ bản ghi có tồn tại. Định danh người dùng lấy từ session hoặc token, không lấy từ tham số request. 📎 IDOR Prevention CS: ID khó đoán (UUID) **không thay** cho kiểm quyền; ứng dụng phải từ chối dù ID có đoán được hay không. 📎 Multi-Tenant Security CS: ứng dụng nhiều tenant thì gắn ngữ cảnh tenant vào danh tính đã được server xác minh và tư cách thành viên tenant hiện tại. Tenant ID do client gửi (header, tham số) chỉ là **bộ chọn**; server phải kiểm người đang đăng nhập có quyền trong tenant đó.

**Nguồn:** [IDOR Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html) · [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) · [Multi-Tenant Security](https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html)

**Kiểm:** tìm mọi chỗ đọc `id` từ request rồi load dữ liệu.

### G-A01-03 — Thao tác ghi dữ liệu có chống CSRF và không chạy bằng GET
**Mức:** 🔴

**Vì sao:** CSRF là khi trang web khác khiến trình duyệt của người dùng đang đăng nhập tự gửi request. Thao tác ghi chạy được bằng GET thì chỉ cần một link hoặc thẻ `<img>`.

**✅ Đúng:** tạo, sửa, xoá chỉ nhận POST/PUT/PATCH/DELETE và đi qua cơ chế CSRF token của framework. Không tắt kiểm CSRF cho tiện; ngoại lệ: 📎 webhook có chữ ký, chỉ miễn đúng route đó và kiểm chữ ký trước tiên (Webhook Security CS); 🔧 API xác thực bằng header token, không dùng cookie đăng nhập. 🔧 Form trong trình duyệt vẫn cần CSRF token dù nó có gửi kèm token khác, ví dụ form reset mật khẩu. 📎 OWASP: token không đặt trong URL; thuộc tính `SameSite` của cookie session là lớp bổ sung, không thay cho token.

**Kiểm:** tìm các chỗ tắt CSRF (`csrf_exempt`, `validateForCsrf`, `VerifyCsrfToken::$except`…) trong diff.

### G-A01-04 — Server không gọi tới URL do người dùng cung cấp
**Mức:** 🔴

**Vì sao:** 📎 lỗi SSRF, thuộc A01 từ bản 2025. Kẻ tấn công dùng server làm bàn đạp gọi vào dịch vụ nội bộ mà từ ngoài không chạm được.

**❌ Sai** (Python)
```python
resp = requests.get(request.args["url"])
```

**✅ Đúng**
```python
ALLOWED = {"products": "/v1/products", "stock": "/v1/stock"}
path = ALLOWED.get(request.args.get("type"))
if path is None:
    abort(400)
resp = requests.get(settings.ERP_BASE_URL + path, timeout=10)
```
Host cố định trong cấu hình; phần thay đổi chọn từ danh sách cho phép. 🔧 Phần thay đổi là ID (ví dụ `/v1/transactions/{id}`) thì kiểm định dạng bằng regex chặt rồi URL-encode; host trong cấu hình cũng được kiểm là tên miền thuần, không có scheme, port hay đường dẫn. 📎 SSRF Prevention CS bổ sung:
- Cố định giao thức (`https`); không nhận `file://`, `gopher://`, `phar://`.
- Tắt tự động follow redirect ở HTTP client (`allow_redirects=False`, `CURLOPT_FOLLOWLOCATION => false`).
- 📎 X01:2025: giới hạn kích thước response. 🔧 Đọc theo luồng và dừng khi vượt giới hạn (Python `requests`: `stream=True` rồi đọc `iter_content()` tới giới hạn; PHP cURL: xem `M2-A01-07`). Header `Content-Length` do server đích gửi, không tin được.
- 📎 X01:2025: không trả nguyên response của hệ thống đích cho client, xử lý ở server. 🔧 Với dịch vụ cố định (cổng thanh toán, LLM), chỉ trả dữ liệu đã chọn lọc và xử lý như input không tin cậy (`G-A05-07`).

Tính năng bắt buộc nhận URL (ví dụ tải ảnh từ link) phải kiểm IP sau khi phân giải tên miền, chặn dải nội bộ và địa chỉ metadata của cloud, và cần review riêng; danh sách chặn rất dễ bị vượt qua.

**Kiểm:** lần ngược tham số URL của mọi lời gọi HTTP client.

### G-A01-05 — Redirect không lấy URL đích từ request
**Mức:** 🟠

**Vì sao:** 📎 open redirect (CWE-601), thuộc A01:2025. Link `https://shop.vn/login?return=https://shop-gia.vn` mang tên miền thật nên người dùng tin, rồi bị đưa sang trang lừa đảo.

**❌ Sai** (PHP)
```php
header('Location: ' . $_GET['return_url']);
```

**✅ Đúng:** 📎 theo Unvalidated Redirects CS:
- Không nhận URL làm tham số đích. Nhận một tên ngắn hoặc ID, rồi map sang URL ở server.
- Redirect quay lại trang nội bộ: dùng helper của framework, loại helper từ chối đích không thuộc site mình.
- Buộc phải cho đích ngoài: parse URL bằng parser chuẩn, so **scheme, host, port** với allow-list. Từ chối URL có userinfo (`user@host`) và input mơ hồ. Redirect bằng đúng URL đã kiểm, không biến đổi sau khi kiểm.
- Không so khớp prefix hoặc suffix của chuỗi URL.

**Kiểm:** tìm `Location:`, `redirect(`, `setUrl(` dùng giá trị lấy từ request.

**Nguồn:** [Unvalidated Redirects and Forwards](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html)

---

## A02 — Security Misconfiguration (cấu hình hở)

📎 OWASP: tính năng thừa bật sẵn, tài khoản mặc định, thông báo lỗi chi tiết, thiếu security header.

### G-A02-01 — Không có file debug, backup, công cụ trong repo và thư mục public
**Mức:** 🔴

**Vì sao:** scanner tự động thử các tên quen thuộc (`info.php`, `adminer.php`, `backup.sql`, `.env`, `.git/`) trên mọi website.

**✅ Đúng:** script chạy một lần viết thành command của framework. File dump, export, log để ngoài thư mục dự án. `.gitignore` chặn các đuôi `.sql`, `.zip`, `.log`, `.env`.

**Kiểm:** `git status --short` trước khi commit; xem danh sách file mới trong PR.

### G-A02-02 — Secret không nằm trong code; không bật debug hay hiển thị lỗi
**Mức:** 🔴

**Vì sao:** secret trong repo tồn tại mãi trong lịch sử git. Trang lỗi chi tiết lộ đường dẫn, câu SQL, version, đôi khi cả biến môi trường.

**❌ Sai**
```python
DEBUG = True
DB_PASSWORD = "Sup3rS3cret!"
```

**✅ Đúng**
```python
DEBUG = os.environ.get("APP_DEBUG") == "1"
DB_PASSWORD = os.environ["DB_PASSWORD"]
```
Mỗi môi trường có secret riêng. Lỡ commit secret thì đổi secret đó ngay; xoá commit là không đủ. 🔧 Test được dùng giá trị giả có nhãn rõ (`test-only-…`), không bao giờ dùng secret thật.

📎 Trang tài liệu và debug do framework tự sinh: quyết định chúng có cần public không; nếu không thì tắt hoặc chặn ở production. Ví dụ FastAPI CS: `/docs`, `/redoc`, `/openapi.json` (`FastAPI(openapi_url=None)`); việc này không thay cho phân quyền từng API. A02:2025 khuyên nền tảng tối giản, bỏ tính năng thừa.

**Kiểm:** công cụ quét secret (ví dụ `gitleaks`) trên diff; tìm `debug`, `display_errors` trong diff.

### G-A02-03 — Không làm yếu security header
**Mức:** 🟠

**Vì sao:** Content Security Policy (CSP) bảo trình duyệt chỉ chạy script từ nguồn được phép; CORS quy định trang nào được đọc response của API. Nới lỏng cho "chạy được" là gỡ một lớp bảo vệ của cả site.

**❌ Sai:** phản chiếu nguyên header `Origin` của request vào `Access-Control-Allow-Origin` kèm `Access-Control-Allow-Credentials: true` (trình duyệt đã tự từ chối `*` kèm credentials, nên lỗi thật thường là phản chiếu); thêm `unsafe-inline`, `unsafe-eval` vào CSP; viết script inline và `onclick="…"`.

**✅ Đúng:** Script đặt trong file, hoặc inline có nonce do framework cấp.

📎 CORS theo CORS Security CS:
- **Không gửi header CORS là mặc định an toàn**; chỉ thêm cho endpoint mà origin khác thật sự cần đọc.
- Không phản chiếu header `Origin` khi chưa kiểm. Không so khớp prefix, suffix hay regex lỏng (`example.com` khớp cả `attackerexample.com`). Không cho phép origin `null`. Chỉ cho origin `https://`.
- Có `Vary: Origin` khi giá trị `Access-Control-Allow-Origin` phụ thuộc request.
- CORS không phải phân quyền và không chống CSRF.

📎 HTTP Headers CS:
- Trang HTML có `Content-Type` kèm `charset`.
- Có `X-Content-Type-Options: nosniff`.
- Chống nhúng trang vào iframe: dùng `frame-ancestors` của CSP nếu được, hoặc `X-Frame-Options: DENY`.
- Không bật `X-XSS-Protection`: không gửi header này, hoặc gửi `X-XSS-Protection: 0`.

**Kiểm:** tìm `Access-Control-Allow-Origin`, `unsafe-inline`, `<script>` inline trong diff.

**Nguồn:** [CORS Security](https://cheatsheetseries.owasp.org/cheatsheets/CORS_Security_Cheat_Sheet.html) · [HTTP Security Response Headers](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html) · [Content Security Policy](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)

### G-A02-04 — Cookie tự tạo có `Secure`, `HttpOnly`, `SameSite`; không lưu token trong `localStorage`
**Mức:** 🟠

**Vì sao:** 📎 CWE-614, CWE-1004, CWE-315 thuộc A02:2025. Cookie thiếu `HttpOnly` thì JavaScript đọc được, nên một lỗi XSS đủ để lấy cắp. Thiếu `Secure` thì cookie đi qua HTTP thường.

**✅ Đúng:** 📎 theo Session Management CS:
- Cookie phiên: `Secure; HttpOnly; SameSite`, ưu tiên `SameSite=Strict`, `Lax` khi cần giữ phiên lúc người dùng đến từ link của site khác. Không đặt `Domain` khi không cần chia sẻ cho subdomain. Nên dùng tiền tố `__Host-`.
- 🔧 Team áp cùng cách cho cookie chứa dữ liệu riêng hoặc token khác.
- Cookie không chứa dữ liệu nhạy cảm dạng rõ.
- **Không lưu token, session ID, JWT, refresh token trong `localStorage` hay `sessionStorage`**, vì mọi script trên trang đều đọc được.

```http
Set-Cookie: __Host-SessionID=<value>; Secure; HttpOnly; SameSite=Strict; Path=/
```

**Kiểm:** tìm `setcookie(`, `set_cookie(`, `localStorage.setItem` chứa token.

**Nguồn:** [Session Management → Cookies, HTML5 Web Storage API](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)

### G-A02-05 — Parse XML không tin cậy với external entity bị chặn
**Mức:** 🟠

**Vì sao:** 📎 XXE (CWE-611) thuộc A02:2025. File XML chứa khai báo entity trỏ tới `file:///etc/passwd` hoặc URL nội bộ làm parser đọc file hoặc gọi mạng thay kẻ tấn công. Entity lồng nhau (CWE-776) làm cạn bộ nhớ.

**✅ Đúng:** 📎 theo XXE Prevention CS:
- Tắt DTD và external entity, tắt XInclude. Parser không hỗ trợ tuỳ chọn an toàn thì coi là lỗi cấu hình, không xử lý tiếp.
- **PHP:** libxml 2.9.0 trở lên đã tắt entity substitution mặc định. **Không bật** `LIBXML_NOENT`, `LIBXML_DTDLOAD`, `LIBXML_DTDVALID` với XML không tin cậy. Muốn chặn hẳn, đặt callback trả `null`. **Truyền thẳng `null` vào hàm này không có tác dụng chặn.**
  ```php
  libxml_set_external_entity_loader(function () {
      return null;
  });
  ```
- **Python:** dùng `defusedxml` thay cho parser của thư viện chuẩn khi đọc XML không tin cậy.
- 📎 Tắt DTD khi có thể (XXE CS, General Guidance). 🔧 File dữ liệu không cần DTD thì từ chối mọi tài liệu có DOCTYPE: kiểm sau khi parse (PHP: `$dom->doctype !== null`), không tìm chuỗi `<!DOCTYPE`, vì input UTF-16 vượt qua được phép tìm chuỗi.
- `[RUN]` (giả lập, PHP 8.2) Khi callback trả `null` đang bật, `DOMDocument::load($file)` thất bại. Đọc file thành chuỗi rồi `loadXML()`. Callback có hiệu lực cho cả tiến trình: trả về mặc định bằng `libxml_set_external_entity_loader(null)` trong `finally`.

**Kiểm:** tìm `LIBXML_NOENT`, `LIBXML_DTDLOAD`, `xml.etree`, `lxml` trên dữ liệu từ upload, API, feed.

**Nguồn:** [XML External Entity Prevention → PHP, Python](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)

---

## A03 — Software Supply Chain Failures (chuỗi cung ứng phần mềm)

📎 OWASP: biết mình dùng thành phần nào, version nào; lấy từ nguồn tin cậy; gỡ thứ không dùng; theo dõi lỗ hổng.

### G-A03-01 — Thư viện cài qua package manager, không copy tay
**Mức:** 🔴

**Vì sao:** thư viện copy vào source không có trong lock file, công cụ quét lỗ hổng không thấy, và không ai cập nhật.

**✅ Đúng:** composer, pip, npm với version ghim. Không tải file `.js` hay thư mục SDK rồi commit vào dự án.

**Kiểm:** tìm thư mục `vendor`, `lib`, `third_party` mới trong source của mình.

### G-A03-02 — Lock file được commit; công cụ audit không báo lỗ hổng
**Mức:** 🔴

**Vì sao:** không có lock file thì mỗi lần cài có thể kéo về version khác, kể cả version đã bị cài mã độc.

**✅ Đúng:** commit `composer.lock`, `package-lock.json`, `poetry.lock`. Chạy `composer audit`, `npm audit`, `pip-audit` khi đổi dependency và trước release. Không sửa trực tiếp code trong thư mục dependency.

**Kiểm:** PR đổi file khai báo dependency phải đổi cả lock file và có kết quả audit.

### G-A03-03 — Package mới phải được nêu lý do trong PR
**Mức:** 🟠

**Vì sao:** mỗi package là code của người lạ chạy với đầy đủ quyền của ứng dụng. Package bỏ hoang hoặc tên gần giống package nổi tiếng (typosquatting) là đường tấn công phổ biến.

**✅ Đúng:** trước khi thêm, xem lần release gần nhất, số lượt tải, người bảo trì, và viết đúng tên. Việc nhỏ viết được trong vài dòng thì không thêm package.

Package do AI gợi ý: xem `G-AI-07`.

📎 A03:2025: gỡ dependency không dùng; chỉ lấy thành phần từ nguồn chính thức qua kết nối an toàn, ưu tiên package có chữ ký; chủ động chọn version và chỉ nâng khi cần; theo dõi thư viện không còn được bảo trì.

**Kiểm:** mô tả PR có mục "dependency mới" khi có thay đổi.

**Nguồn:** [A03:2025](https://top10.owasp.org/2025/A03_2025-Software_Supply_Chain_Failures/) · [Vulnerable Dependency Management](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html) · [Secure Coding with AI §1–2](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html)

---

## A04 — Cryptographic Failures (mã hoá sai hoặc thiếu)

📎 OWASP: thuật toán lỗi thời, key trong source, không kiểm chứng chỉ, mật khẩu băm yếu. Dùng thư viện đáng tin, không tự viết.

### G-A04-01 — Không dùng MD5, SHA1 cho bảo mật; mật khẩu dùng hàm băm chuyên dụng
**Mức:** 🔴

**Vì sao:** MD5 và SHA1 tính rất nhanh nên dò được hàng tỷ mật khẩu mỗi giây, và đã có va chạm nên không dùng làm chữ ký.

**❌ Sai**
```php
$hash = md5($password);
```

**✅ Đúng**
```php
$hash = password_hash($password, PASSWORD_ARGON2ID);
$ok = password_verify($password, $hash);

$signature = hash_hmac('sha256', $payload, $secret);
$valid = hash_equals($signature, $received);
```
Python: `argon2-cffi` hoặc hàm băm của framework; `hmac.compare_digest()` để so sánh. So sánh secret bằng hàm thời gian hằng, không dùng `==`.

📎 Tham số tối thiểu theo OWASP Password Storage Cheat Sheet:

| Thuật toán | Tham số tối thiểu |
|---|---|
| Argon2id (ưu tiên) | bộ nhớ 19 MiB, 2 vòng, 1 luồng |
| scrypt | N=2^17, r=8, p=1 |
| bcrypt (chỉ cho hệ thống cũ) | work factor từ 10; mật khẩu tối đa 72 byte |
| PBKDF2-HMAC-SHA256 (khi cần FIPS) | 600.000 vòng |

Ưu tiên để framework chọn tham số; bảng này dùng để kiểm khi phải tự cấu hình.

**Kiểm:** tìm `md5(`, `sha1(`, `hashlib.md5`, `hashlib.sha1` trong diff.

### G-A04-02 — Giá trị ngẫu nhiên bảo mật lấy từ nguồn an toàn
**Mức:** 🔴

**Vì sao:** `rand()`, `mt_rand()`, `uniqid()`, `random.random()`, `Math.random()` đoán được. Token, mã OTP, link reset sinh từ chúng là tính ra được.

**✅ Đúng:** PHP `random_bytes()`, `random_int()`; Python module `secrets`; JavaScript `crypto.getRandomValues()`.

**Kiểm:** tìm các hàm random thường trong code sinh token, mã, tên file bí mật.

### G-A04-03 — Secret lưu trữ được mã hoá, không tự viết thuật toán
**Mức:** 🔴

**Vì sao:** API key, token của bên thứ ba lưu dạng thường sẽ lộ qua mọi bản dump database. `base64` là mã hoá ký tự, không phải mã hoá bảo mật.

**✅ Đúng:** dùng cơ chế mã hoá của framework hoặc thư viện chuẩn (libsodium, `cryptography`), key nằm ngoài database. Mật khẩu người dùng thì băm (`G-A04-01`), không mã hoá hai chiều. Không lưu dữ liệu nhạy cảm nếu không thật sự cần.

📎 Phải tự chọn thuật toán thì theo A04:2025 và Cryptographic Storage CS:
- Luôn dùng **authenticated encryption**, ví dụ AES-GCM.
- Không dùng ECB. Không dùng lại IV hoặc nonce với cùng một key.
- RSA dùng padding OAEP.
- UUID version 1 không ngẫu nhiên, không dùng làm token.

**Nguồn:** [Cryptographic Storage](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) · [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

**Kiểm:** field mới chứa `key`, `secret`, `token`, `password` phải nêu được cách bảo vệ.

### G-A04-04 — Không tắt kiểm chứng chỉ TLS
**Mức:** 🔴

**Vì sao:** tắt kiểm chứng chỉ thì HTTPS không còn bảo đảm đang nói chuyện với đúng server; kẻ đứng giữa đọc và sửa được toàn bộ dữ liệu.

**❌ Sai**
```python
requests.post(url, json=data, verify=False)
```
```php
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
```

**✅ Đúng:** để mặc định. Lỗi chứng chỉ ở local thì sửa môi trường local.

**Kiểm:** tìm `verify=False`, `SSL_VERIFYPEER`, `SSL_VERIFYHOST`, `rejectUnauthorized`.

Ghi chú nhóm: 📎 CWE-295 và CWE-297 (kiểm chứng chỉ, kiểm hostname) thuộc **A07:2025**. Mã rule giữ là A04 để không phải đổi checklist cũ.

### G-A04-05 — Response chứa dữ liệu riêng không được cache chung
**Mức:** 🔴

**Vì sao:** 📎 A04:2025 yêu cầu tắt cache cho response chứa dữ liệu nhạy cảm, ở cả CDN, web server và cache của ứng dụng. Nếu trang "tài khoản của tôi" bị cache chung, người sau sẽ thấy dữ liệu của người trước. Ngược lại, nếu input không nằm trong cache key mà vẫn làm thay đổi response được cache (ví dụ header `X-Forwarded-Host` chèn vào link), kẻ tấn công đầu độc được trang cache của mọi người (cache poisoning).

**✅ Đúng:** 📎 theo Web Cache Security CS và HTTP Headers CS:
- Response chứa dữ liệu riêng của người dùng: `Cache-Control: no-store`. **`no-cache` vẫn cho phép lưu**, chỉ bắt kiểm lại trước khi dùng.
- **`Set-Cookie` không làm response thành riêng tư.** Không đánh dấu `public` hay đặt `s-maxage` cho response phụ thuộc session hoặc header `Authorization`.
- Đổi một route sang `no-store` không xoá bản đã cache; phải purge cache.
- Input không nằm trong cache key (header lạ, body của request GET) không được làm thay đổi response cacheable. Không phản chiếu metadata của request chưa kiểm vào HTML, JSON, redirect hay header đã cache.
- Trang có token CSRF gắn với session **trong HTML** là response phụ thuộc session, nên không được vào shared cache (📎 Web Cache Security CS mục 1). 🔧 Muốn cache trang đó thì để token ra ngoài HTML: trình duyệt lấy token sau khi tải trang, như Magento làm (`M2-A04-05`).
- Redirect kèm message trong session: message không nằm trong response redirect, nên chỉ cần redirect không bị đánh `public`.
- Cache của ứng dụng (Redis…) có key gồm user hoặc tenant khi dữ liệu phụ thuộc user hoặc tenant. Định danh lấy từ ngữ cảnh đã xác thực, không lấy từ header hay query. Không đưa token hay secret vào cache key.

**Kiểm:** endpoint mới trả dữ liệu riêng: xem header `Cache-Control` thật bằng `curl -I`. Tìm chỗ đưa header của request vào response.

**Nguồn:** [Web Cache Security](https://cheatsheetseries.owasp.org/cheatsheets/Web_Cache_Security_Cheat_Sheet.html) · [HTTP Security Response Headers → Cache-Control](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html) · [A04:2025](https://top10.owasp.org/2025/A04_2025-Cryptographic_Failures/)

---

## A05 — Injection (chèn mã)

📎 OWASP: dữ liệu không tin cậy bị trình thông dịch (database, trình duyệt, shell) chạy như lệnh. Gồm SQL injection, XSS, command injection. Ưu tiên API tham số hoá; validate theo danh sách cho phép; escape theo ngữ cảnh.

### G-A05-01 — Truy vấn database dùng tham số hoá
**Mức:** 🔴

**❌ Sai**
```python
cur.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

**✅ Đúng**
```python
cur.execute("SELECT * FROM users WHERE email = %s", (email,))
```
```php
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);
```
Ưu tiên ORM hoặc query builder. Tên bảng, tên cột, chiều sắp xếp không tham số hoá được: đối chiếu với danh sách cố định trong code. 📎 Stored procedure vẫn bị injection nếu bên trong nối chuỗi. 📎 SQL Injection Prevention CS: **không tự escape** giá trị để ghép SQL; quy tắc escape khác nhau giữa các dialect và phụ thuộc cấu hình database.

**Kiểm:** tìm chuỗi SQL có biến nội suy hoặc phép nối.

**Nguồn:** [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) · [Query Parameterization](https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html)

### G-A05-02 — Output được escape theo ngữ cảnh
**Mức:** 🔴

**Vì sao:** XSS: dữ liệu người dùng nhập được in ra trang và chạy như script trong trình duyệt của người khác, lấy được session và thao tác thay họ.

**❌ Sai**
```php
<div class="<?= $class ?>"><?= $comment ?></div>
```
```javascript
element.innerHTML = response.message;
```

**✅ Đúng**
```php
<div class="<?= htmlspecialchars($class, ENT_QUOTES) ?>"><?= htmlspecialchars($comment, ENT_QUOTES) ?></div>
```
```javascript
element.textContent = response.message;
```
Mỗi ngữ cảnh (HTML, thuộc tính, URL, JavaScript, CSS) có cách escape riêng; dùng hàm của framework. Giữ auto-escape của template engine luôn bật; mỗi chỗ tắt (`|safe`, `{!! !!}`, `@noEscape`) phải giải thích được. Dữ liệu sang JavaScript đi qua JSON encoder.

📎 DOM based XSS Prevention CS: cần hiển thị HTML không tin cậy thì làm sạch bằng sanitizer như DOMPurify. Chuyển JSON thành object bằng `JSON.parse()`, không dùng `eval()`.

🔧 Hai trường hợp nguồn không nói, team chọn:
- Template email **plain text** (không phải HTML) được tắt HTML escape, ghi lý do ngay trong code. Giá trị đưa vào header email (tiêu đề, người nhận) không chứa `\r` hay `\n`.
- File CSV/XLSX export: ô bắt đầu bằng `=`, `+`, `-`, `@`, tab hoặc `\r` được thêm `'` ở đầu, để Excel không hiểu là công thức.

**Kiểm:** tìm các chỗ tắt escape và `innerHTML`, `.html(`, `document.write` trong diff.

**Nguồn:** [Cross Site Scripting Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html) · [DOM based XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html)

### G-A05-03 — Không ghép dữ liệu vào lệnh shell, `eval`, `include`
**Mức:** 🔴

**❌ Sai**
```python
os.system("convert " + filename + " out.png")
```

**✅ Đúng**
```python
subprocess.run(["convert", filename, "out.png"], check=True)
```
Truyền tham số dạng mảng, không qua shell. Ưu tiên thư viện thay cho lệnh ngoài. Không dùng `eval`, `exec` với dữ liệu động; không `include`/`import` theo đường dẫn từ request.

📎 Buộc phải gọi lệnh OS thì theo OS Command Injection Defense CS:
- **Hardcode lệnh và các option bắt buộc**; người dùng không chọn được chạy lệnh nào.
- Argument kiểm theo allow-list hoặc regex cho phép, có độ dài tối đa. Không cho phép metacharacter của shell và khoảng trắng.
- Với lệnh hỗ trợ, đặt `--` trước dữ liệu để chặn argument injection, tức giá trị bắt đầu bằng `-` bị hiểu thành option.
- PHP: dùng `escapeshellarg()`, không dùng `escapeshellcmd()`, cho dữ liệu người dùng.

**Kiểm:** tìm `exec`, `system`, `shell_exec`, `passthru`, `eval`, `os.system`, `shell=True`.

**Nguồn:** [OS Command Injection Defense](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html) · [Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Injection_Prevention_Cheat_Sheet.html)

### G-A05-04 — Upload và đường dẫn file được kiểm soát
**Mức:** 🔴

**Vì sao:** upload file thực thi được vào thư mục web là chạy mã từ xa. Tên file chứa `../` (path traversal) cho đọc hoặc ghi file ngoài thư mục dự định.

**✅ Đúng:**
- Danh sách đuôi file cho phép cố định; không cho `.php`, `.phtml`, `.html`, `.svg`, `.js`, file thực thi. Kiểm sau khi decode tên file, chú ý đuôi kép (`a.php.jpg`).
- 📎 OWASP: không tin header `Content-Type` do client gửi.
- Server tự đặt tên file khi lưu; tên gốc chỉ để hiển thị.
- Lưu ngoài thư mục chạy được mã; giới hạn dung lượng. File riêng tư lưu ngoài thư mục public và tải về qua endpoint có kiểm quyền.
- Upload cần đăng nhập và chống CSRF.
- Lấy file theo ID bản ghi, không theo đường dẫn từ request. Buộc phải nhận tên file thì chuẩn hoá đường dẫn rồi kiểm nó vẫn nằm trong thư mục gốc.

📎 Path Traversal Prevention CS, khi buộc phải nhận tên file:
1. Decode hết input một lần.
2. Nối vào thư mục gốc cố định, rồi resolve thành đường dẫn tuyệt đối (cả symlink).
3. Kiểm đường dẫn vẫn nằm trong thư mục gốc. So sánh chuỗi chỉ sau khi thư mục gốc có dấu `/` cuối, để `/srv/uploads-old` không lọt qua phép kiểm `/srv/uploads`.
4. Dùng đúng đường dẫn đã kiểm.

**Không** tự lọc `../` khỏi input. Cheat sheet liệt kê các cách vượt qua bộ lọc: dùng `\` trên hệ thống chấp nhận nó làm dấu phân cách, chuỗi còn sót `../` khi chỉ xoá một lần, input được decode sau khi lọc.

📎 **Giải nén archive** (zip, tar) do người dùng gửi:
- Kiểm từng entry bằng phép kiểm trên; có một entry sai thì từ chối cả archive.
- Bỏ entry là symlink hoặc hardlink.
- Python `tarfile` dùng `filter='data'`.

📎 Theo File Upload CS:
- Không nên nhận ZIP nếu không bắt buộc, vì ZIP chứa được mọi loại file.
- Có giải nén hoặc xử lý thì **giới hạn dung lượng tính sau khi giải nén**, để chặn ZIP bomb.
- Ngoài `Content-Type` (chỉ để kiểm nhanh, không dùng làm biện pháp bảo mật): kiểm **file signature** (magic bytes) khớp loại file mong đợi. 📎 Cheat sheet lưu ý: kiểm signature **không dùng một mình**, vì rất dễ vượt qua. 🔧 Vì vậy luôn đi cùng các biện pháp khác trong cùng cheat sheet: allow-list đuôi file, đặt tên mới, lưu ngoài thư mục chạy được mã.
- Ảnh: decode rồi encode lại sang định dạng cho phép, bỏ metadata không cần. Cách này không bảo đảm loại hết nội dung độc.
- 🔧 File tải về từ host khác (ảnh của nhà cung cấp, file của đối tác) kiểm như file upload. Ảnh đặt giới hạn số pixel trước khi decode (nguồn không nói cụ thể).

Ghi chú nhóm: 📎 upload file nguy hiểm (CWE-434) thuộc A06:2025, path traversal (CWE-22) thuộc A01:2025.

**Kiểm:** lần ngược tham số của mọi hàm mở, ghi, xoá file.

**Nguồn:** [File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html) · [Path Traversal Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Path_Traversal_Prevention_Cheat_Sheet.html)

### G-A05-05 — Không dựng template từ dữ liệu; input không chọn template
**Mức:** 🟠

**Vì sao:** 📎 server-side template injection (SSTI): khi dữ liệu trở thành **mã nguồn** của template, cú pháp template trong dữ liệu sẽ chạy trên server. Tuỳ engine, hậu quả có thể là đọc biến nội bộ hoặc chạy lệnh. **Auto-escape không chống được SSTI**: escape áp dụng cho giá trị được in ra, không áp dụng cho code template mà engine đã parse.

**❌ Sai** (Python/Jinja2)
```python
template = env.from_string("Xin chào " + request.form["name"])
```

**✅ Đúng**
```python
template = env.get_template("greeting.html")
html = template.render(name=request.form["name"])
```
📎 Theo SSTI Prevention CS:
- Template nằm cùng source, review như code, **không bao giờ dựng từ dữ liệu không tin cậy**.
- Input không được chọn tên template, đường dẫn template, hay target của `include`. Map lựa chọn của người dùng sang danh sách cố định ở server.
- Chỉ truyền vào template giá trị nó cần; không truyền secret hay object có method nguy hiểm.
- Áp dụng cho cả email, PDF, report, và prompt gửi cho LLM. 📎 Dữ liệu chỉ được truyền vào template như **biến khi render**; sai là khi dữ liệu trở thành **mã nguồn template** mà engine sẽ parse. 🔧 Chèn dữ liệu vào prompt cố định bằng `str.format` hay f-string không phải SSTI, nhưng vẫn có rủi ro prompt injection (`G-A05-07`).
- Người dùng buộc phải tự soạn template thì dùng sandbox của engine, chỉ cho vai trò được phép, và log thay đổi template.

**Kiểm:** tìm `from_string(`, `render_template_string(`, `createTemplate(`, `template_from_string(`; tìm chỗ tên template lấy từ request.

**Nguồn:** [Server-Side Template Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Template_Injection_Prevention_Cheat_Sheet.html)

### G-A05-06 — URL tuyệt đối lấy từ cấu hình, không từ `Host`; không đưa input chưa kiểm vào header response
**Mức:** 🔴

**Vì sao:** 📎 header `Host` và `X-Forwarded-*` do client chọn. Nếu link reset mật khẩu được tạo từ `Host`, kẻ tấn công gửi yêu cầu reset cho email nạn nhân kèm `Host: attacker.com`. Email gửi đi chứa link sang site của kẻ tấn công, mang theo token reset. Đưa input có ký tự xuống dòng (CRLF) vào header response thì chèn được header hoặc nội dung giả (CWE-93, CWE-113, thuộc A05:2025).

**❌ Sai** (PHP)
```php
$link = 'https://' . $_SERVER['HTTP_HOST'] . '/reset?token=' . $token;
```

**✅ Đúng:** 📎 theo Input Validation CS và Forgot Password CS:
- URL tuyệt đối (link reset, link trong email, URL callback) lấy base URL từ cấu hình.
- Chỉ nhận hostname mà ứng dụng phục vụ. Dùng setting có sẵn của framework, ví dụ `ALLOWED_HOSTS` của Django.
- Chỉ dùng `Forwarded` / `X-Forwarded-*` khi do proxy của mình đặt.
- 📎 Web Cache Security CS: không phản chiếu metadata chưa kiểm của request vào header response. 🔧 Giá trị đưa vào header (`Location`, `Content-Disposition`, header tự đặt) lấy từ danh sách cố định hoặc được kiểm, và không chứa `\r` hay `\n` (chặn CRLF injection, CWE-93/113 thuộc A05:2025).

**Kiểm:** tìm `HTTP_HOST`, `X-Forwarded-Host`, `getHttpHost`, `request.host` dùng để dựng URL; tìm `header(` hoặc `setHeader(` chứa giá trị từ request.

**Nguồn:** [Input Validation → Host and Forwarded Headers](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) · [Forgot Password → URL Tokens](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html) · [Web Cache Security](https://cheatsheetseries.owasp.org/cheatsheets/Web_Cache_Security_Cheat_Sheet.html) · [A05:2025](https://top10.owasp.org/2025/A05_2025-Injection/)

### G-A05-07 — (nếu có tính năng LLM) Output của LLM được xử lý như input không tin cậy
**Mức:** 🟡 · chỉ áp dụng khi ứng dụng gọi LLM (chatbot, sinh mô tả, tóm tắt…)

**Vì sao:** 📎 prompt injection: nội dung mà LLM đọc (input người dùng, trang web, email, tài liệu) có thể chứa chỉ thị ẩn làm LLM trả về nội dung độc hại hoặc gọi tool ngoài ý muốn.

**✅ Đúng:** 📎 theo LLM Prompt Injection Prevention CS:
- Output của LLM có thể chứa HTML hoặc Markdown được chèn vào (mục "HTML and Markdown Injection"), nên escape hoặc sanitize trước khi render (`G-A05-02`). 📎 Coi output của model là không tin cậy ở **mọi** chỗ dùng tiếp theo, áp đúng biện pháp của chỗ đó, ví dụ render HTML an toàn, truy vấn SQL tham số hoá (`G-A05-01`); lọc từ khoá trên output là không đủ. 🔧 Team áp cùng cách cho shell và `eval` (`G-A05-03`).
- Tách rõ chỉ thị tin cậy và nội dung không tin cậy trong prompt (mục "Structured Prompts with Clear Separation"), ví dụ chỉ thị ở system message, nội dung người dùng hay tài liệu ở message riêng. 📎 Nhãn chữ hay cách viết prompt **không phải** ranh giới bảo vệ; ví dụ trong cheat sheet chỉ minh hoạ định dạng. Quyền phải chặn ở tầng tool (mục dưới).
- Tool mà LLM gọi được thì có quyền tối thiểu và kiểm tham số ở phía tool. Thao tác có hậu quả (ghi, xoá, gửi, thanh toán) cần người duyệt trước khi chạy.

**Nguồn:** [LLM Prompt Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html)

---

## A06 — Insecure Design (thiết kế không an toàn)

📎 OWASP: thiếu hoặc sai biện pháp kiểm soát ngay từ thiết kế; code đúng theo thiết kế vẫn hở. Cần threat modeling cho luồng quan trọng, kiểm tính hợp lý ở mọi tầng, test cả trường hợp lạm dụng.

### G-A06-01 — Giá trị quan trọng tính ở server
**Mức:** 🔴

**Vì sao:** mọi thứ gửi từ client đều sửa được, kể cả field ẩn và giá trị JavaScript đã tính.

**❌ Sai:** nhận `price`, `total`, `discount`, `role`, `user_id`, `is_admin` từ request rồi dùng luôn.

**✅ Đúng:** client gửi định danh và lựa chọn (mã sản phẩm, số lượng, mã giảm giá); server tra giá, tính tổng, xác định quyền. Số được ép kiểu và kiểm giới hạn: không âm, không vượt mức tối đa.

**Kiểm:** với mỗi field nhận từ request, hỏi "nếu người dùng tự đổi giá trị này thì sao".

### G-A06-02 — Chức năng public có giới hạn tần suất
**Mức:** 🟠

**Vì sao:** form và API không cần đăng nhập bị dùng để spam email, dò mã giảm giá, dò mật khẩu, làm đầy database.

**✅ Đúng:** đăng nhập, quên mật khẩu, đăng ký, liên hệ, kiểm tra mã, gửi OTP đều có ít nhất một lớp: captcha, giới hạn theo IP hoặc tài khoản, hoặc độ trễ tăng dần.

📎 Business Logic Security CS: mọi tính năng gửi email, gọi HTTP ra ngoài hay chạy việc nặng theo yêu cầu đều là đường DoS và spam nếu không rate limit. 🔧 Team áp cả khi người dùng đã đăng nhập, giới hạn theo tài khoản (ví dụ "gửi cho bạn bè" tới địa chỉ do người dùng nhập); request ẩn danh thì giới hạn thêm theo địa chỉ nhận. Chức năng dễ bị lạm dụng (mã giảm giá, giới thiệu bạn, thưởng khi đăng ký) cần **giới hạn riêng cho từng chức năng**; một rate limit chung ở biên là không đủ. Đặt giới hạn ở nhiều tầng: mỗi lượt, mỗi tài khoản, mỗi nguồn (phương thức thanh toán, thiết bị). Mọi lần cấp giá trị (credit, coupon, bonus) đều ghi audit: ai kích hoạt, cho ai, IP, thời điểm. 📎 Denial of Service CS: cơ chế khoá tài khoản sau nhiều lần đăng nhập sai có thể bị lợi dụng để khoá người khác. 📎 Forgot Password CS: **không** khoá tài khoản vì có yêu cầu quên mật khẩu.

**Nguồn:** [Business Logic Security → Protect Abuse-friendly Features](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) · [Credential Stuffing Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Credential_Stuffing_Prevention_Cheat_Sheet.html)

Con số giới hạn: OWASP **không** quy định. Authentication CS chỉ nêu các yếu tố phải chọn: ngưỡng, thời gian khoá, khoá tăng dần, đếm theo tài khoản chứ không theo IP. Laravel CS có ví dụ `throttle:10,1` (10 request/phút) nhưng chỉ là ví dụ. 🔧 Không có yêu cầu riêng thì lấy mặc định của framework, nếu framework có (Magento: `M2-A06-02`).

**Kiểm:** liệt kê endpoint không cần đăng nhập mà gửi email, ghi database hoặc trả lời đúng/sai.

### G-A06-03 — Có test cho trường hợp bị lạm dụng
**Mức:** 🟡

**Vì sao:** 📎 OWASP yêu cầu test cả "misuse case". Test chỉ đi luồng đúng không phát hiện được lỗi phân quyền và lỗi logic.

**✅ Đúng:** với luồng quan trọng (thanh toán, phân quyền, điểm thưởng, reset mật khẩu, webhook, upload), viết thêm test: người dùng A truy cập dữ liệu của B, số lượng âm, gọi lặp hoặc gọi song song một request, bỏ qua một bước, chữ ký sai, file bị cấm. 🔧 Mỗi loại rủi ro mà PR động tới có ít nhất một test; test cần môi trường tích hợp mà chưa viết được thì ghi rõ trong PR.

**Kiểm:** PR động vào luồng quan trọng có ít nhất một test tiêu cực.

### G-A06-04 — Endpoint danh sách và bulk có giới hạn kích thước
**Mức:** 🟠

**Vì sao:** một request xin một triệu bản ghi hoặc gửi mảng trăm nghìn phần tử đủ làm cạn bộ nhớ, khoá database và kéo sập dịch vụ. 📎 OWASP A10 yêu cầu giới hạn tài nguyên và throttling.

**❌ Sai**
```python
limit = int(request.args["limit"])
rows = Order.query.limit(limit).all()
```

**✅ Đúng**
```python
MAX_PAGE_SIZE = 100
limit = min(max(int(request.args.get("limit", 20)), 1), MAX_PAGE_SIZE)
rows = Order.query.limit(limit).all()
```
Giới hạn cả kích thước trang, số phần tử của mảng đầu vào và dung lượng body. Việc nặng (export, xử lý hàng loạt) chạy nền qua queue thay vì trong request.

📎 Denial of Service CS:
- Kiểm rẻ trước, kiểm đắt sau.
- Input không được quyết định số lần lặp hay lượng bộ nhớ cấp phát mà không có giới hạn.
- **Không chạy regex có quantifier lồng nhau hoặc chồng nhau (ví dụ `^(a+)+$`) trên input không tin cậy**, vì thời gian chạy có thể tăng theo hàm mũ (ReDoS).

📎 GraphQL CS: giới hạn độ sâu và độ phức tạp của query, chặn brute force qua batching, tắt introspection và GraphiQL ở môi trường production.

📎 X01:2025: gọi dịch vụ ngoài có timeout; không chặn đồng bộ trong request.

**Kiểm:** tìm tham số `limit`, `page_size`, `ids[]` lấy từ request; mỗi chỗ phải có giới hạn trên. Đọc mọi regex mới chạy trên input.

**Nguồn:** [Denial of Service](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html) · [GraphQL](https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html) · [X01:2025](https://top10.owasp.org/2025/X01_2025-Next_Steps/)

### G-A06-05 — "Kiểm rồi ghi" chống được hai request đồng thời
**Mức:** 🔴

**Vì sao:** 📎 race condition (CWE-362) thuộc A06:2025. Hai request đến cùng lúc đều qua bước kiểm ("coupon chưa dùng", "còn hàng", "đủ số dư") rồi cả hai cùng ghi: coupon một lần dùng được hai lần, trừ tiền vượt số dư.

**❌ Sai** (Python)
```python
if not coupon.used:
    apply_discount(order, coupon)
    coupon.used = True
    coupon.save()
```

**✅ Đúng:** 📎 một trong ba cách theo Business Logic Security CS:
```sql
-- 1. Update có điều kiện, rồi kiểm số dòng bị ảnh hưởng
UPDATE coupon SET used = 1 WHERE id = :id AND used = 0;   -- 0 dòng: đã bị dùng, báo lỗi
```
2. Khoá dòng bằng `SELECT … FOR UPDATE` rồi `UPDATE`, trong cùng transaction.
3. Unique constraint, ví dụ trên `(user_id, bonus_type)`, để database từ chối bản ghi trùng.

Nhiều dòng phải nhất quán với nhau thì dùng transaction `SERIALIZABLE`, kèm logic thử lại.

📎 **Giới hạn số lần cũng là "kiểm rồi ghi"**: cheat sheet liệt kê mẫu "kiểm người dùng có ít hơn N mục, rồi thêm một". Đếm rồi mới ghi thì request song song vượt được giới hạn. 🔧 Dùng dòng đếm theo (người dùng, kỳ) tăng bằng update có điều kiện `count < N`, hoặc khoá theo người dùng quanh bước đếm và ghi.

**Kiểm:** tìm mẫu "đọc, kiểm `if`, rồi ghi" trên số dư, tồn kho, coupon, điểm, giới hạn số lần. Viết test gửi hai request song song (`G-A06-03`).

**Nguồn:** [Business Logic Security → Prevent Race Conditions](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html)

### G-A06-06 — Luồng nhiều bước kiểm trạng thái ở server trước mỗi bước
**Mức:** 🟠

**Vì sao:** 📎 CWE-841 thuộc A06:2025. Giao diện dẫn người dùng đi theo thứ tự, nhưng ai cũng gọi thẳng được endpoint của bước cuối (xác nhận đơn, duyệt, chuyển tiền) mà bỏ qua bước thanh toán hay xác minh.

**✅ Đúng:** 📎 theo Business Logic Security CS, coi luồng là state machine:
1. Bắt đầu luồng: tạo bản ghi có trạng thái đầu, ví dụ `awaiting_payment`.
2. Mỗi endpoint của bước kiểm trạng thái hiện tại, làm việc của mình, rồi chuyển sang trạng thái kế tiếp hợp lệ.
3. Request đến cho bước không khớp trạng thái hiện tại thì từ chối.
4. Thao tác cuối chỉ chạy khi trạng thái đúng bằng trạng thái yêu cầu.

**Kiểm:** với mỗi endpoint của luồng nhiều bước, hỏi "gọi thẳng endpoint này khi chưa qua bước trước thì sao".

**Nguồn:** [Business Logic Security → Enforce Workflows as Explicit State Machines](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) · [Transaction Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Transaction_Authorization_Cheat_Sheet.html)

### G-A06-07 — Thanh toán: xác minh với cổng ở server, khớp số tiền, xử lý một lần
**Mức:** 🔴

**Vì sao:** 📎 sau khi thanh toán, người dùng được chuyển về site kèm tham số như `?status=success&order=123`. Tham số này sửa được. Callback từ cổng có thể bị giả mạo, gửi lại, gửi nhiều lần, hoặc đến không đúng thứ tự.

**✅ Đúng:** 📎 theo Third Party Payment Gateway Integration CS:
- Tính lại giỏ hàng và tổng tiền ở server trước khi tạo đơn (`G-A06-01`).
- **Trước khi giao hàng: xác minh trạng thái thanh toán ở server bằng API của cổng.** Tham số trên URL quay về là không tin cậy.
- Khớp **số tiền, tiền tệ và mã đơn** của giao dịch với đơn trong hệ thống.
- Chỉ tin thông báo server-to-server, và phải kiểm chữ ký (`G-A08-03`).
- **Idempotent:** dù callback đến bao nhiêu lần, đơn chỉ được xử lý một lần.
- Callback đến muộn sau khi checkout hết hạn: không bỏ qua, mà đối chiếu lại trạng thái thanh toán hiện tại.
- Log mọi lần callback để điều tra sau.

📎 Xác minh qua API của cổng là bắt buộc trước khi giao hàng, kể cả khi đã nhận callback có chữ ký hợp lệ. 🔧 Lời gọi API chỉ đọc này đặt trước transaction ghi DB.

**Kiểm:** đọc đường xử lý trang "quay về" và callback: chỉ ra dòng gọi API xác minh, dòng so số tiền, dòng chặn xử lý lặp. PR chỉ có lớp xử lý (nhận `array $event`) thì tìm controller gọi nó để xem bước kiểm chữ ký (`G-A08-03`).

**Nguồn:** [Secure Integration of Third-Party Payment Gateways](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Payment_Gateway_Integration_Cheat_Sheet.html)

---

## A07 — Authentication Failures (xác thực yếu)

📎 OWASP: hệ thống nhận nhầm người. Ưu tiên hệ thống xác thực có sẵn; không tài khoản mặc định; thông báo giống nhau cho mọi kết quả; đổi session ID sau đăng nhập; huỷ session khi đăng xuất.

### G-A07-01 — Dùng cơ chế xác thực của framework
**Mức:** 🔴

**Vì sao:** cơ chế có sẵn đã xử lý khoá tài khoản, đổi session ID, hết hạn token. Tự viết thường thiếu ít nhất một phần.

**✅ Đúng:** không tự viết đăng nhập, quản lý session, reset mật khẩu, "ghi nhớ đăng nhập". Tính năng đăng nhập thay người khác hoặc SSO cần review bảo mật trước khi code. Session ID và access token không nằm trên URL. 📎 Ngoại lệ: link reset mật khẩu dùng **URL token** là cách Forgot Password CS khuyến nghị, kèm các điều kiện bên dưới.

🔧 Framework không có sẵn tính năng (ví dụ FastAPI không có đăng nhập, session, CSRF, reset mật khẩu): dùng thư viện chuẩn, được bảo trì của stack. Không có, hoặc không kiểm được thư viện (`G-AI-07`), thì viết phần tối thiểu theo các rule ở đây, đánh dấu PR cần review bảo mật và báo người phụ trách; đây là ngoại lệ có chủ đích của câu "không tự viết".

🔧 Link hành động gửi qua email khác (mời tham gia, xác minh email, đăng nhập không mật khẩu) theo cùng cách với token reset: CSPRNG, lưu hash, dùng một lần, có hạn (thời hạn tuỳ loại: đăng nhập ≤ 15 phút, lời mời ≤ 7 ngày). Trang mở từ link (GET) chỉ hiện form xác nhận, bước POST mới dùng token, vì trình quét thư có thể tự mở link. Che việc tài khoản có tồn tại (thông báo và thời gian như nhau) áp cho mọi luồng gửi email tới tài khoản. 🔧 Link qua email **không bao giờ** đổi mật khẩu hay email của tài khoản đã tồn tại; người đã có tài khoản phải đăng nhập để chấp nhận lời mời. Hai ý này nguồn không nói.

📎 Phải tự viết hoặc phải review luồng **quên mật khẩu**, kiểm theo Forgot Password CS:
- Thông báo **và thời gian phản hồi** giống nhau dù tài khoản có tồn tại hay không; 📎 cheat sheet nêu hai cách: gọi bất đồng bộ, hoặc chạy cùng một logic cho cả hai trường hợp thay vì thoát sớm. 🔧 Team thường làm: tra tài khoản và gửi email trong job nền.
- Có giới hạn số lần gửi yêu cầu.
- Token sinh bằng CSPRNG, đủ dài, gắn với một user, chỉ dùng một lần, hết hạn "sau một khoảng thích hợp", lưu an toàn theo Password Storage CS. Cheat sheet không nêu thuật toán hay thời hạn cụ thể. 🔧 Team chọn: token ngẫu nhiên ≥ 128 bit lưu dạng SHA-256 (phải tra được theo token, nên không dùng hàm băm có salt ngẫu nhiên như Argon2); hạn ≤ 1 giờ; token mới làm token cũ mất hiệu lực.
- Link reset lấy host từ cấu hình (`G-A05-06`) và dùng HTTPS.
- Trang reset gửi `Referrer-Policy: no-referrer`.
- Không thay đổi tài khoản (kể cả khoá) trước khi token hợp lệ được gửi lên.
- Sau khi đổi: gửi email thông báo (không kèm mật khẩu); không tự đăng nhập; cho huỷ hoặc tự huỷ các session đang có.

**Kiểm:** PR có code tạo session hoặc đặt trạng thái "đã đăng nhập" phải có người thứ hai review.

**Nguồn:** [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html)

### G-A07-02 — Không hardcode tài khoản, mật khẩu, key
**Mức:** 🔴

**Vì sao:** tài khoản tạo sẵn bằng migration với mật khẩu cố định là cửa hậu trên mọi môi trường.

**✅ Đúng:** secret đọc từ cấu hình (`G-A02-02`). Dữ liệu mẫu có tài khoản chỉ chạy ở môi trường dev.

**Kiểm:** công cụ quét secret; đọc migration và seed có tạo user.

### G-A07-03 — Thông báo lỗi không tiết lộ tài khoản tồn tại
**Mức:** 🟠

**❌ Sai:** "Email chưa đăng ký" / "Sai mật khẩu" / "Tài khoản đã bị khoá".

**✅ Đúng:** "Thông tin đăng nhập không đúng"; quên mật khẩu: "Nếu email tồn tại, chúng tôi đã gửi hướng dẫn". Áp dụng cho cả API và endpoint kiểm tra email.

**Kiểm:** đọc mọi response sau khi tra cứu tài khoản.

### G-A07-04 — Session ID mới sau đăng nhập; xác thực lại trước thao tác nhạy cảm
**Mức:** 🟠

**Vì sao:** 📎 session fixation (CWE-384): kẻ tấn công cài trước một session ID cho nạn nhân. Nếu ID không đổi sau khi nạn nhân đăng nhập, kẻ tấn công dùng chính ID đó để vào tài khoản. Cửa sổ quên đăng xuất trên máy công cộng đủ để người khác đổi mật khẩu hoặc email.

**✅ Đúng:** 📎 theo Session Management CS và Authentication CS:
- **Sinh session ID mới sau đăng nhập và sau mọi lần đổi quyền.** PHP: `session_regenerate_id(true)`. Thường framework đã làm sẵn; code tự đặt trạng thái đăng nhập phải tự làm.
- Huỷ session ở server khi đăng xuất, khi hết thời gian không hoạt động, và khi hết hạn tuyệt đối.
- **Xác thực lại** trước khi đổi mật khẩu, đổi email, thao tác quan trọng (📎 Authentication CS, "Require Re-authentication for Sensitive Features"; 🔧 team tính cả việc tải toàn bộ dữ liệu cá nhân). **Đổi mật khẩu khi đang đăng nhập** phải hỏi mật khẩu hiện tại (Authentication CS, "Change Password Feature"). Luồng quên mật khẩu không có mật khẩu hiện tại: token reset hợp lệ đóng vai trò xác thực (`G-A07-01`).
- Session ID không nằm trên URL, không chứa thông tin cá nhân.

**Kiểm:** code đặt trạng thái đăng nhập có gọi hàm sinh session ID mới; form đổi email hoặc mật khẩu có trường mật khẩu hiện tại.

**Nguồn:** [Session Management → Renew the Session ID, Session Expiration](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) · [Authentication → Change Password Feature](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

### G-A07-05 — (nếu tự xử lý JWT) Cố định thuật toán, kiểm `exp`, `iss`, `aud`
**Mức:** 🔴 khi code tự tạo hoặc tự kiểm JWT (nhận token không ký là bỏ qua xác thực); không áp dụng nếu không đụng JWT

**Vì sao:** 📎 thư viện JWT từng chấp nhận token `"alg":"none"`, tức không có chữ ký. Token có thể tự khai key hoặc URL tới key (`jwk`, `jku`, `x5u`). Token cấp cho dịch vụ A có thể bị đem dùng ở dịch vụ B cùng issuer.

**✅ Đúng:** 📎 theo JSON Web Token CS và A07:2025:
- Không chấp nhận `"alg":"none"`. Chỉ nhận thuật toán trong allow-list; **không để header của token chọn thuật toán**; mỗi key gắn với một thuật toán.
- Key xác minh lấy từ cấu hình của issuer, không lấy từ `jwk`, `jku`, `x5u` trong header của token.
- Kiểm `exp`. Kiểm `iss` và `aud`: `aud` phải có định danh của chính dịch vụ mình. Kiểm scope.
- Secret của HMAC sinh ngẫu nhiên, đủ dài; không dùng mật khẩu hay chuỗi hardcode.
- JWT sống ngắn; cần dài hơn thì dùng refresh token và cơ chế thu hồi (A01:2025).

**Nguồn:** [JSON Web Token](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html) · [A07:2025](https://top10.owasp.org/2025/A07_2025-Authentication_Failures/)

---

## A08 — Software or Data Integrity Failures (không kiểm tra tính toàn vẹn)

📎 OWASP: tin code hoặc dữ liệu mà không xác minh nguồn gốc và tính nguyên vẹn. Gồm deserialize không an toàn, script từ nguồn ngoài, cập nhật không kiểm chữ ký.

### G-A08-01 — Không deserialize dữ liệu không tin cậy bằng định dạng native
**Mức:** 🔴

**Vì sao:** `unserialize()` của PHP và `pickle` của Python dựng lại object và chạy code trong quá trình đó. Dữ liệu người dùng tác động được dẫn tới chạy mã tuỳ ý.

**❌ Sai**
```python
data = pickle.loads(request.data)
```
```php
$data = unserialize($_COOKIE['prefs']);
```

**✅ Đúng:** dùng JSON (`json.loads`, `json_decode`) rồi validate cấu trúc. YAML dùng `yaml.safe_load`.

**Kiểm:** tìm `unserialize(`, `pickle.load`, `yaml.load(`, `marshal.load`.

### G-A08-02 — Không gán hàng loạt từ request vào model
**Mức:** 🔴

**Vì sao:** mass assignment: client gửi thêm field không có trên form (`is_admin`, `owner_id`, `status`) và chúng được lưu.

**❌ Sai**
```python
user.update(**request.json)
```

**✅ Đúng**
```python
user.name = str(payload["name"])
user.phone = str(payload["phone"])
```
Hoặc dùng danh sách field cho phép của framework (form class, serializer, `$fillable`).

**Kiểm:** tìm chỗ truyền nguyên request vào `create`, `update`, `setData`, `fill`.

### G-A08-03 — Webhook kiểm chữ ký, chống gửi lại, xử lý một lần
**Mức:** 🔴

**Vì sao:** endpoint nhận callback là public; không kiểm chữ ký thì ai cũng gửi được "đã thanh toán".

**✅ Đúng**
```python
expected = hmac.new(secret, request.get_data(), hashlib.sha256).hexdigest()
if not hmac.compare_digest(expected, request.headers.get("X-Signature", "")):
    abort(401)
```
📎 Theo Webhook Security CS:
- HMAC tính trên **raw body**, trước khi framework parse; so sánh bằng hàm constant-time, không dùng `==`.
- Dùng thư viện xác minh của bên gửi nếu có, theo đúng format ký của họ.
- Giao thức mới do mình định nghĩa: ký cùng lúc **event ID, timestamp và raw body**, ví dụ theo Standard Webhooks. Bên gửi có format riêng (Stripe, GitHub…) thì theo đúng format của họ.
- Chữ ký thiếu hoặc sai: trả `401`, không nói lý do.
- Mỗi webhook một secret. Secret để trong nơi lưu secret, không hardcode. Không log secret hay header chữ ký.
- **Chữ ký đúng chưa đủ chống gửi lại**, vì request bị bắt được vẫn mang chữ ký hợp lệ:
  - Với giao thức có timestamp trong phần được ký: từ chối nếu lệch đồng hồ quá một khoảng nhỏ. Thư viện của Stripe mặc định 5 phút.
  - Lưu event ID đã xử lý và bỏ qua lần lặp. Lần lặp đã xử lý xong thì trả `200`, không chạy lại side effect.
  - Side effect (ghi database, gửi email, thanh toán) idempotent.
- Không giả định thứ tự đến. Cần trạng thái mới nhất thì gọi API của bên gửi.
- Nhận nhanh, xử lý qua queue. 📎 Webhook CS: GitHub đòi `2xx` trong 10 giây.
- 📎 Chữ ký sai là lỗi xác thực, luôn log (Logging CS). Log thời gian, IP nguồn, method, status, event ID, loại sự kiện, độ trễ; không log toàn bộ body (thường chứa dữ liệu cá nhân).
- 📎 Mã trả về: `200` **chỉ sau khi** sự kiện đã vào queue bền vững hoặc đã xử lý xong; `400` cho payload sai định dạng; `401` cho chữ ký sai; `429` kèm `Retry-After` khi quá tải. Body chung chung, không có stack trace. Sự kiện xử lý lỗi nhiều lần thì chuyển vào dead-letter queue và cảnh báo, không bỏ.
- 📎 Lưu event ID **sau khi** xác minh chữ ký, giữ đủ lâu để phủ thời gian bên gửi còn retry. 🔧 Hai cách đều được: (1) xử lý ngay thì ghi event ID trong cùng transaction với thay đổi nghiệp vụ; (2) đưa vào queue trước thì chống trùng ngay lúc đưa vào queue (unique event ID), còn worker dùng update có điều kiện (`G-A06-05`).
- 📎 Payload vượt giới hạn dung lượng: `400` hoặc `413`. Chỉ đăng ký những loại sự kiện mình xử lý. 🔧 Sự kiện hợp lệ nhưng mình bỏ qua (loại không xử lý, đơn không tồn tại): trả `200` và log.

**Kiểm:** mỗi endpoint callback chỉ ra được dòng kiểm chữ ký và dòng chặn xử lý lặp.

**Nguồn:** [Webhook Security](https://cheatsheetseries.owasp.org/cheatsheets/Webhook_Security_Cheat_Sheet.html)

### G-A08-04 — Script bên thứ ba tự host hoặc có SRI
**Mức:** 🟠

**Vì sao:** 📎 CWE-830 thuộc A08:2025. Script tải từ CDN hay từ nhà cung cấp bị chiếm quyền sẽ chạy trên trang của mình, kể cả trang thanh toán.

**✅ Đúng:** tự host, hoặc thêm `integrity` (SRI) và `crossorigin`. 📎 Third Party JavaScript Management CS gợi ý ghi vào chuẩn nội bộ một câu kiểu: script của tag chỉ được đọc giá trị trong data layer của trang, không đọc DOM hay URL.

**Kiểm:** tìm `<script src="http` trong diff.

**Nguồn:** [Third Party JavaScript Management](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Javascript_Management_Cheat_Sheet.html)

---

## A09 — Security Logging and Alerting Failures (thiếu log và cảnh báo)

📎 OWASP: không log thì không phát hiện được tấn công. Log đăng nhập, lỗi phân quyền, lỗi validate kèm ngữ cảnh; chống chèn dữ liệu vào log; không log dữ liệu nhạy cảm.

### G-A09-01 — Sự kiện bảo mật được log kèm ngữ cảnh
**Mức:** 🟠

**✅ Đúng**
```python
logger.warning("access denied", extra={"user_id": user.id, "resource": "invoice", "resource_id": invoice_id, "ip": ip})
```
Cần log (📎 Logging CS, mục "Which events to log"): đăng nhập thành công và thất bại; bị từ chối quyền; lỗi validate đầu vào ở server; lỗi quản lý session, ví dụ JWT không hợp lệ; thao tác quản trị user và đổi quyền; import và export dữ liệu; upload file; lỗi deserialize; hành vi nghiệp vụ đáng ngờ như làm sai thứ tự bước hay vượt giới hạn. 🔧 Team thêm: webhook sai chữ ký. Mỗi dòng trả lời được: khi nào, ở đâu, ai, làm gì. Dữ liệu biến đổi đưa vào trường có cấu trúc, không ghép vào message, để tránh chèn dòng log giả.

📎 A09:2025: log mọi chỗ có kiểm soát bảo mật, **cả thành công lẫn thất bại**; encode dữ liệu log để chống log injection (CWE-117); giao dịch có audit trail khó sửa, khó xoá. 📎 Input Validation CS: không log nguyên văn input bị từ chối.

**Kiểm:** mỗi nhánh từ chối có một dòng log.

**Nguồn:** [Logging](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) · [Application Logging Vocabulary](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Vocabulary_Cheat_Sheet.html) · [A09:2025](https://top10.owasp.org/2025/A09_2025-Security_Logging_and_Alerting_Failures/)

### G-A09-02 — Log không chứa dữ liệu nhạy cảm
**Mức:** 🔴

**Vì sao:** log được chia sẻ rộng hơn và bảo vệ kém hơn database.

**❌ Sai:** log nguyên request body, header, object user, response của cổng thanh toán.

**✅ Đúng:** log định danh và kết quả. Lọc `password`, `token`, `authorization`, `api_key`, session ID, số thẻ, CVV trước khi ghi. 📎 Logging CS: không log dữ liệu cá nhân nhạy cảm (sức khoẻ, số giấy tờ). Với dữ liệu cá nhân thường (tên, số điện thoại, email), cân nhắc xoá, che, hoặc thay bằng mã giả khi không cần biết danh tính; ví dụ log `user_id` thay cho email. 🔧 Token trong URL (link reset) cũng phải được che trong access log của web server.

**Kiểm:** đọc mọi lời gọi logger truyền nguyên request hoặc response.

### G-A09-03 — Không còn output debug
**Mức:** 🔴

**✅ Đúng:** xoá `var_dump`, `print_r`, `print()`, `console.log` chứa dữ liệu, `die`, và file log tự ghi vào thư mục public trước khi commit.

**Kiểm:** tìm các hàm trên trong diff.

---

## A10 — Mishandling of Exceptional Conditions (xử lý tình huống bất thường kém)

📎 OWASP (nhóm mới của bản 2025): bắt lỗi tại nơi xảy ra; lỗi thì rollback và từ chối (fail closed); không lộ chi tiết; có handler chung làm lớp chặn cuối.

### G-A10-01 — Không nuốt lỗi
**Mức:** 🔴

**Vì sao:** nuốt lỗi làm code chạy tiếp với trạng thái sai. Nếu bước bị nuốt là kiểm tra quyền hoặc validate, hệ thống mặc nhiên cho qua (fail open).

**❌ Sai**
```python
try:
    verify_signature(payload, signature)
except Exception:
    pass
process(payload)
```

**✅ Đúng**
```python
try:
    verify_signature(payload, signature)
except InvalidSignature:
    logger.warning("invalid webhook signature")
    abort(401)
process(payload)
```
Bắt loại exception cụ thể. Bắt rồi thì xử lý, hoặc log và ném lại. PHP: không dùng toán tử `@`. 📎 Error Handling CS: có một **global error handler** trả response chung cho lỗi chưa lường trước. 🔧 Bắt để dọn dẹp (rollback, đóng file) rồi ném lại ngay là hợp lệ; thư viện chỉ ném exception chung thì bắt exception chung quanh đúng lời gọi đó. 🔧 Vòng lặp xử lý hàng loạt (cron, queue) được bắt exception chung **cho từng phần tử**, log, đánh dấu phần tử đó lỗi, rồi chạy tiếp phần tử sau.

**Kiểm:** đọc mọi khối `catch`/`except` rỗng hoặc chỉ có `pass`, `continue`, `return`.

### G-A10-02 — Không lộ chi tiết lỗi cho người dùng
**Mức:** 🔴

**Vì sao:** message exception và stack trace chứa câu SQL, đường dẫn, tên host nội bộ, version; đó là bản đồ cho kẻ tấn công.

**✅ Đúng:** người dùng nhận thông báo chung kèm mã tham chiếu; chi tiết vào log. Chỉ hiển thị message của loại exception được thiết kế cho người dùng (lỗi validate, lỗi nghiệp vụ). Có handler chung bắt mọi lỗi chưa xử lý.

**Kiểm:** tìm chỗ đưa `getMessage()`, `str(e)`, `traceback` vào response.

### G-A10-03 — Thao tác nhiều bước có rollback
**Mức:** 🟠

**Vì sao:** lỗi giữa chừng để lại dữ liệu nửa vời: đã trừ tiền nhưng chưa tạo đơn.

**✅ Đúng**
```python
with db.transaction():
    wallet.debit(amount)
    order.create()
```
Gọi dịch vụ ngoài không rollback được: đặt sau khi commit, hoặc thiết kế cho phép chạy lại an toàn (idempotent). 🔧 Để không mất việc khi lời gọi sau commit thất bại: ghi việc cần làm vào bảng outbox trong cùng transaction, worker xử lý và retry. 📎 Webhook Security CS (mục Fail Securely) dùng cùng ý cho bên nhận webhook: chỉ trả `200` khi đã vào queue bền vững; lỗi nhiều lần thì vào dead-letter queue và cảnh báo. Job import hàng loạt: 🔧 commit theo từng lô và lưu trạng thái job, không gói cả triệu dòng vào một transaction.

**Kiểm:** tìm hàm ghi từ hai nơi trở lên mà không có transaction.

### G-A10-04 — Kiểm giá trị trả về và trường hợp null
**Mức:** 🔴

**Vì sao:** hàm tìm kiếm trả `null`, `false` hoặc object rỗng khi không có kết quả. Không kiểm thì code chạy tiếp với dữ liệu sai, hoặc bước kiểm tra bị bỏ qua.

**❌ Sai**
```php
$user = $repo->findByToken($token);
$user->activate();
```

**✅ Đúng**
```php
$user = $repo->findByToken($token);
if ($user === null) {
    throw new NotFoundException();
}
$user->activate();
```
Chú ý so sánh lỏng: trong PHP dùng `===`; `strpos()` trả `0` khác `false`.

**Kiểm:** mỗi lời gọi tìm kiếm có nhánh xử lý "không tìm thấy".

**Nguồn cho G-A10-01…04:** [Error Handling](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html) · [A10:2025](https://top10.owasp.org/2025/A10_2025-Mishandling_of_Exceptional_Conditions/)

---

## Phần B — Khi dùng AI để viết code

📎 OWASP xếp "tin code do AI sinh mà không kiểm" vào mục **X03:2025 Inappropriate Trust in AI Generated Code ("Vibe Coding")**. Theo OWASP, mục này chưa có CVE hay CWE riêng, nhưng thực tế đã được ghi nhận rộng rãi: code do AI sinh thường có nhiều lỗ hổng hơn code người viết. Trong mục này OWASP gợi ý tổ chức cân nhắc cho AI dựa vào tài liệu đã review, "such as your organization's security coding guideline", và lập danh sách prompt tốt có tính tới guideline nội bộ. File `references/general-rules.md` (và `references/magento2-rules.md`) đóng vai guideline đó. Phần A ở trên là rule AI phải theo khi sinh code. Phần B là rule **dev** phải theo khi làm việc với AI.

Nguồn chung của phần này: [X03:2025](https://top10.owasp.org/2025/X01_2025-Next_Steps/) · [Secure Coding with AI](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html) (viết tắt SCwAI, số § là số mục).

### G-AI-01 — Người commit hiểu và chịu trách nhiệm mọi dòng
**Mức:** 🔴 · 📎 X03; SCwAI §14

Phải đọc hiểu được mọi đoạn code mình commit, kể cả code do AI viết hay copy từ mạng. "AI viết" không miễn trách nhiệm. Review do AI làm không thay review của người. 📎 X03 **không** khuyến nghị vibe coding cho chức năng phức tạp, chương trình quan trọng với nghiệp vụ, hoặc chương trình dùng lâu dài.

### G-AI-02 — Đọc từng file trong diff, không duyệt theo mô tả PR
**Mức:** 🔴 · 📎 SCwAI §7

Agent hay sửa cả file ngoài phạm vi task: lockfile, cấu hình CI, test không liên quan, format lại code. Reviewer bám theo mô tả task sẽ bỏ sót. Mở từng file trong diff; file ngoài phạm vi phải có lý do.

### G-AI-03 — Không chấp nhận test bị xoá, bị nới, hoặc mock chính đối tượng đang test
**Mức:** 🔴 · 📎 SCwAI §8

Agent có thể làm CI xanh bằng cách xoá test đang fail, nới assertion (`assertEquals` thành `assertNotNull`), mock chính đơn vị đang test, hoặc viết test xác nhận đúng hành vi đang sai. Test do AI sửa phải được người review. Test cho xác thực, phân quyền, validate và mã hoá do người viết. "Test pass hết" không chứng minh được code an toàn.

### G-AI-04 — Thay đổi do AI tạo ở file build, dependency, CI được review riêng
**Mức:** 🔴 · 📎 SCwAI §10, §1–2

Các file này tự chạy với quyền cao khi cài đặt, build hoặc deploy: `composer.json` (mục `scripts`), `package.json` (`postinstall`…), `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Dockerfile`, `Makefile`, `setup.py`, `pyproject.toml`. Đánh dấu mọi thay đổi do AI tạo có thêm truy cập mạng, tải tài nguyên ngoài, hoặc chạy lệnh shell. GitHub Action của bên thứ ba ghim theo commit SHA. Package mới thì theo `G-A03-03`.

### G-AI-05 — Không để secret trong tầm đọc của công cụ AI
**Mức:** 🔴 · 📎 SCwAI §9

Công cụ AI gửi context (file đang mở, cấu trúc dự án, output terminal) tới nhà cung cấp model.
- Đưa `.env`, `.env.*`, `*.pem`, `*.key`, file credential vào danh sách loại trừ của công cụ (`.cursorignore` hoặc file tương đương). **`.gitignore` không ngăn AI đọc file.**
- Không mở file `.env` hay private key trong IDE khi AI assistant đang bật.
- Không dán key hay token vào terminal khi công cụ AI đọc được terminal.

### G-AI-06 — Nội dung bên ngoài mà agent đọc có thể chứa lệnh ẩn
**Mức:** 🟠 · 📎 SCwAI §3, §13

Issue, mô tả PR, comment, README, changelog của dependency, log lỗi, trang web mà agent đọc đều là input không tin cậy và có thể chứa chỉ thị ẩn. Sau khi agent xử lý nội dung đến từ bên ngoài (ticket của khách, repo lạ), review kỹ thay đổi của nó. Output của agent này là input không tin cậy với agent khác.

### G-AI-07 — Package và version do AI gợi ý phải được kiểm
**Mức:** 🔴 · 📎 SCwAI §1–2

AI hay gợi ý package **không tồn tại**. Kẻ tấn công đăng ký sẵn những tên này để cài mã độc. AI cũng gợi ý version cũ có CVE. Trước khi cài:
- Kiểm package có trên registry chính thức.
- Xem trang package, số lượt tải, lịch sử người bảo trì, ngày tạo. Nghi ngờ package có ít lượt tải, được tạo chưa tới 30 ngày, hoặc chỉ có một người bảo trì mà người đó không có package nào khác.
- Chạy audit (`G-A03-02`). Version chọn theo quy trình quản lý dependency của dự án, không theo gợi ý của AI.
- 🔧 Không vào được registry để kiểm thì **không thêm**: liệt kê package cần dùng và hỏi người phụ trách.

### G-AI-08 — File rule cho AI là cấu hình bảo mật
**Mức:** 🔴 · 📎 SCwAI §6

`CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, `*.ai.md` điều khiển mọi lần sinh code về sau. Ai sửa được chúng là điều khiển được AI.
- Thay đổi các file này được review kỹ như thay đổi CI. 📎 Đặt `CODEOWNERS` để file rule bắt buộc có reviewer chỉ định (SCwAI §7).
- Agent không tự sửa file rule nếu dev chưa duyệt.
- Định kỳ kiểm file rule có câu nào làm yếu kiểm soát bảo mật, ví dụ "bỏ qua thư mục X", "không cần escape".

---

## Phụ lục A — Ngoài phạm vi coding rule

| OWASP | Việc | Thường thuộc về |
|---|---|---|
| A02 | Hardening server, tắt directory listing, security header ở web server, tách môi trường | DevOps / hosting |
| A03 | Danh mục thành phần (SBOM), theo dõi CVE, lịch nâng cấp | Tech lead |
| A03, A08 | Bảo vệ CI/CD, phân quyền repo, MFA cho tài khoản dev, ký bản build | Tech lead / DevOps |
| A04 | TLS 1.2 trở lên, HSTS, quản lý và xoay vòng key, HSM | DevOps / hosting |
| A06 | Threat modeling, đưa yêu cầu bảo mật vào user story | Tech lead / BA |
| A07 | Chính sách mật khẩu, MFA, kiểm mật khẩu đã lộ | Chủ sản phẩm / admin |
| A09 | Gom log tập trung, cảnh báo, quy trình ứng phó sự cố | DevOps / vận hành |
| A10 | Giới hạn tài nguyên, rate limit ở web server/WAF, stress test | DevOps |

## Phụ lục B — Bảng đối chiếu OWASP Top 10 2025 và 2021

| 2025 | Tên | So với 2021 |
|---|---|---|
| A01 | Broken Access Control | Giữ hạng 1; gộp thêm SSRF |
| A02 | Security Misconfiguration | Lên từ hạng 5 |
| A03 | Software Supply Chain Failures | Mở rộng từ "Vulnerable and Outdated Components" |
| A04 | Cryptographic Failures | Xuống từ hạng 2 |
| A05 | Injection | Xuống từ hạng 3 |
| A06 | Insecure Design | Xuống từ hạng 4 |
| A07 | Authentication Failures | Giữ hạng 7; tên cũ "Identification and Authentication Failures" |
| A08 | Software or Data Integrity Failures | Giữ hạng 8 |
| A09 | Security Logging and Alerting Failures | Giữ hạng 9; tên cũ "…Logging and Monitoring Failures" |
| A10 | Mishandling of Exceptional Conditions | Mới |

Nguồn: https://top10.owasp.org/2025 (đọc ngày 2026-11-16).

Trạng thái: bản 2025 là bản final (README của repo `OWASP/Top10` ghi "OWASP Top10:2025 (Final)"). Các trang của OWASP không ghi ngày phát hành.

## Phụ lục C — Nguồn của từng rule

Đọc ngày 2026-11-17 từ repo nguồn `OWASP/Top10` (commit 3a31f35) và `OWASP/CheatSheetSeries` (commit 7af0ef1). Trang chỉ mục "Top Ten" của Cheat Sheet Series vẫn theo bản **2021**, nên cột "Nhóm 2025 theo CWE" do tài liệu này đối chiếu với danh sách CWE của từng nhóm trên trang Top 10:2025. Chữ **đậm** đánh dấu nhóm khác với mã rule.

| Rule | Nhóm 2025 theo CWE | 📎 Cheat sheet |
|---|---|---|
| G-A01-01, 02 | A01 | [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) · [IDOR Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html) · [Authorization Decisions and Output Handling](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Decisions_And_Output_Handling_Cheat_Sheet.html) |
| G-A01-03 | A01 (CWE-352) | [CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html) |
| G-A01-04 | A01 (CWE-918) | [SSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html) |
| G-A01-05 | A01 (CWE-601) | [Unvalidated Redirects and Forwards](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html) |
| G-A02-01 | A02; A01 (CWE-538, CWE-552) | Top 10 A01, A02 (How to prevent) |
| G-A02-02 | A02 (CWE-489, CWE-547) | [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) |
| G-A02-03 | A02 (CWE-942) | [CORS Security](https://cheatsheetseries.owasp.org/cheatsheets/CORS_Security_Cheat_Sheet.html) · [HTTP Security Response Headers](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html) · [Content Security Policy](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) |
| G-A02-04 | A02 (CWE-614, CWE-1004, CWE-315) | [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) |
| G-A02-05 | A02 (CWE-611, CWE-776) | [XXE Prevention](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html) |
| G-A03-01, 02, 03 | A03 | [Vulnerable Dependency Management](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html) · [Secure Coding with AI §1–2](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html) |
| G-A04-01 | A04 (CWE-916, CWE-759) | [Password Storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) |
| G-A04-02 | A04 (CWE-330, CWE-331, CWE-338) | [Cryptographic Storage → Secure Random Number Generation](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) |
| G-A04-03 | A04 (CWE-327) · A06 (CWE-311, CWE-312) | [Cryptographic Storage](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) · [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) |
| G-A04-04 | **A07** (CWE-295, CWE-297) | [Transport Layer Security](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html) |
| G-A04-05 | A04 (How to prevent: tắt cache); A06 (CWE-525) | [Web Cache Security](https://cheatsheetseries.owasp.org/cheatsheets/Web_Cache_Security_Cheat_Sheet.html) · [HTTP Security Response Headers](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html) |
| G-A05-01 | A05 (CWE-89) | [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) · [Query Parameterization](https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html) |
| G-A05-02 | A05 (CWE-79) | [XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html) · [DOM based XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html) |
| G-A05-03 | A05 (CWE-77, 78, 88, 94, 98) | [OS Command Injection Defense](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html) · [Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Injection_Prevention_Cheat_Sheet.html) |
| G-A05-04 | **A06** (CWE-434) · **A01** (CWE-22) | [File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html) · [Path Traversal Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Path_Traversal_Prevention_Cheat_Sheet.html) |
| G-A05-05 | A05 (CWE-94, CWE-917) | [SSTI Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Template_Injection_Prevention_Cheat_Sheet.html) |
| G-A05-06 | A05 (CWE-93, CWE-113) | [Input Validation](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html) |
| G-A05-07 | A05 (🔧 xếp nhóm) | [LLM Prompt Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html) |
| G-A06-01 | A06 (CWE-472, CWE-602, CWE-642) | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) |
| G-A06-02 | A06 (CWE-799) | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) · [Credential Stuffing Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Credential_Stuffing_Prevention_Cheat_Sheet.html) · [Denial of Service](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html) |
| G-A06-03 | A06 (How to prevent: misuse case) | [Abuse Case](https://cheatsheetseries.owasp.org/cheatsheets/Abuse_Case_Cheat_Sheet.html) |
| G-A06-04 | X01 (CWE-400); A10 (How to prevent: giới hạn) | [Denial of Service](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html) · [GraphQL](https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html) |
| G-A06-05 | A06 (CWE-362) | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) |
| G-A06-06 | A06 (CWE-841) | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) · [Transaction Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Transaction_Authorization_Cheat_Sheet.html) |
| G-A06-07 | A06 (🔧 xếp nhóm) | [Secure Integration of Third-Party Payment Gateways](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Payment_Gateway_Integration_Cheat_Sheet.html) |
| G-A07-01 | A07 (CWE-287, CWE-640) | [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html) |
| G-A07-02 | A07 (CWE-798, CWE-259) | [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) |
| G-A07-03 | A07 (How to prevent: thông báo giống nhau) | [Authentication → Authentication and Error Messages](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) |
| G-A07-04 | A07 (CWE-384, CWE-613, CWE-620) | [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) · [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) |
| G-A07-05 | A07 (How to prevent: kiểm aud, iss) | [JSON Web Token](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html) |
| G-A08-01 | A08 (CWE-502) | [Deserialization](https://cheatsheetseries.owasp.org/cheatsheets/Deserialization_Cheat_Sheet.html) |
| G-A08-02 | A08 (CWE-915) | [Mass Assignment](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html) |
| G-A08-03 | A08 (CWE-345) · A04 (CWE-347) | [Webhook Security](https://cheatsheetseries.owasp.org/cheatsheets/Webhook_Security_Cheat_Sheet.html) |
| G-A08-04 | A08 (CWE-830) | [Third Party JavaScript Management](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Javascript_Management_Cheat_Sheet.html) |
| G-A09-01 | A09 (CWE-778, CWE-117) | [Logging](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) · [Application Logging Vocabulary](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Vocabulary_Cheat_Sheet.html) |
| G-A09-02 | A09 (CWE-532) | [Logging → Data to exclude](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) |
| G-A09-03 | **A02** (CWE-489) · **A10** (CWE-215) | Top 10 A02, A10 |
| G-A10-01 … 04 | A10 (CWE-390, 209, 636, 252, 476) | [Error Handling](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html) |
| G-AI-01 … 08 | X03 (không có CWE) | [Secure Coding with AI](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html) · [Secure Code Review](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html) |

Trang Top 10:2025 của từng nhóm: `https://top10.owasp.org/2025/A0x_2025-<Tên>/`. Trang X01–X03: https://top10.owasp.org/2025/X01_2025-Next_Steps/

## Lịch sử cập nhật
- 2026-11-16: bản nháp đầu tiên.
- 2026-11-16: bản đề xuất cuối sau khi đối chiếu với OWASP Cheat Sheet Series. Thêm `G-A06-04`; bổ sung `G-A01-01`, `G-A01-03`, `G-A01-04`, `G-A03-03`, `G-A04-01`, `G-A05-04`, `G-A09-01`, `G-A09-02`; thêm Phụ lục C.
- 2026-11-17: **v2** sau research đợt 2, chỉ dùng Top 10:2025 và Cheat Sheet Series. Thêm 12 rule: `G-A01-05`, `G-A02-04`, `G-A02-05`, `G-A04-05`, `G-A05-05`, `G-A05-06`, `G-A05-07`, `G-A06-05`, `G-A06-06`, `G-A06-07`, `G-A07-04`, `G-A07-05`. Thêm Phần B (`G-AI-01…08`). Bổ sung `G-A01-01`, `G-A01-02`, `G-A02-03`, `G-A03-03` (bỏ số liệu từ nguồn ngoài OWASP), `G-A04-03`, `G-A05-01…04`, `G-A06-02`, `G-A06-04`, `G-A07-01`, `G-A08-03`, `G-A09-01`. Viết lại Phụ lục C với link và nhóm theo CWE của bản 2025.
- 2026-11-17: **v2.1** sau vòng giả lập 1. Sửa 19 điểm do kiểm chứng nguồn chỉ ra (ghi 📎 sai chỗ, trích sai cheat sheet, viết mạnh hơn nguồn, tên cheat sheet). Tách `G-A08-04` (SRI) khỏi `G-A08-03`. Trả lời câu hỏi của AI agent bằng nguồn: mã trả về của webhook, ký event ID + timestamp + body, ngoại lệ URL token cho reset mật khẩu, mật khẩu hiện tại chỉ áp khi đang đăng nhập, ZIP bomb và file signature, PII trong log, global error handler, queue bền vững thay cho gọi sau commit, tắt trang docs của framework, không kiểm được package thì không thêm. Checklist có mức, đủ mục Phần B; thêm mục lục và bảng thuật ngữ. (nhật ký giả lập nội bộ, không kèm trong plugin).
- 2026-11-17: **v2.3** sau vòng giả lập 2 và 3. Sửa theo kiểm chứng nguồn (thêm nhãn 🔧 ở chỗ viết mạnh hơn nguồn: CSRF, X01, FastAPI docs, f-string, bất đồng bộ, outbox, rate limit email). Thêm: link hành động qua email (mời, magic login) và link không đổi credential của tài khoản có sẵn (🔧), mã 413 (📎) và sự kiện bỏ qua (🔧) của webhook, chống trùng khi đưa vào queue trước, xác minh qua API cả khi webhook đã ký, CSV formula injection và email plain text (🔧), đánh dấu endpoint public bằng code, catch theo từng phần tử, xác thực lại trước khi export dữ liệu cá nhân. `G-A07-05` nâng lên 🔴 khi có dùng JWT.
- 2026-11-18: **v2.4** sau vòng kiểm chứng riêng cho phần sửa của v2.3 và research nốt các mục ❓. Sửa nhãn ở `G-A05-04` ("đi cùng biện pháp khác" là 🔧) và mục lịch sử v2.3. File AI: thêm link Multi-Tenant Security và X01; `G-A07-05` khớp bản dev (tạo hoặc kiểm JWT, secret HMAC, JWT sống ngắn). Thêm từ research: trang có token CSRF và redirect kèm message (`G-A04-05`), giới hạn của tách prompt (`G-A05-07`), OWASP không có con số rate limit (`G-A06-02`), tiêu chí "việc nặng" (🔧), log khi chữ ký webhook sai (`G-A08-03`). Bổ sung sau thí nghiệm D-12 (user duyệt thêm, 2026-11-18): giới hạn kích thước response khi đọc (`G-A01-04`, 📎 X01); giới hạn số lần cũng là "kiểm rồi ghi" (`G-A06-05`, 📎 Business Logic Security CS).
