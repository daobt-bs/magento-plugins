# OWASP Top 10:2025 — Coding rule cho Magento 2

> **Bản v2.4, chờ duyệt để phát hành** · cập nhật 2026-11-18 · dành cho dev Magento 2.
> Đọc kèm: [bản chung](../general/owasp-rules.md) (nguyên tắc cho mọi platform) · [bản cho AI](owasp-rules.ai.md) (cùng mã rule, rút gọn).

> Nguồn nội dung rule: [OWASP Top 10:2025](https://top10.owasp.org/2025) và [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) (CC BY-SA 4.0, diễn đạt lại). Tên class và method Magento lấy từ source Magento 2.4.6-p4 và tài liệu Adobe Commerce; OWASP không có cheat sheet cho Magento.

**Tóm tắt 1 dòng:** 50 rule code (cộng `M2-AI-05` cho phần dùng AI), mỗi rule nói rõ trong Magento 2 phải dùng API nào, cấm viết gì, và reviewer kiểm bằng lệnh nào. Rule khi dùng AI để viết code nằm ở Phần B của [bản chung](../general/owasp-rules.md); bản này chỉ bổ sung phần riêng của Magento (`M2-AI-05`).

## Cách đọc

- **Mã rule** `M2-A05-02` = rule Magento 2, thuộc nhóm A05 của OWASP Top 10:2025, số thứ tự 02. Mã `G-…` là rule tương ứng ở bản chung.
- **Mức:** 🔴 bắt buộc (vi phạm thì không merge) · 🟠 nên làm (bỏ qua phải ghi lý do trong PR) · 🟡 khuyến nghị.
- **Nguồn:** 📎 là yêu cầu lấy từ OWASP (Top 10:2025, Cheat Sheet Series); 🔧 là cách team cụ thể hoá. Tên API Magento ghi kèm `file:line` trong `vendor/magento` (2.4.6-p4) khi rule mới dựa vào hành vi của core. Phụ lục D ghi nguồn của từng rule.
- **API Magento** nêu trong tài liệu đã được đối chiếu với source Magento 2.4.6-p4 (`vendor/magento/...`). API chỉ có từ version cao hơn được ghi chú tại chỗ. Version khác cần kiểm lại tên class.
- **Ví dụ "sai"** là pattern có thật, gặp khi rà một dự án Magento 2.4.6; tên module và đường dẫn đã được đổi.
- Lệnh `grep` ở mục "Kiểm" chỉ tìm ứng viên; có kết quả chưa chắc là lỗi, phải đọc ngữ cảnh.

## Mục lục và ký hiệu

[Checklist review PR](#checklist-review-pr-1-trang) · A01 Phân quyền · A02 Cấu hình · A03 Chuỗi cung ứng · A04 Mã hoá · A05 Injection · A06 Thiết kế · A07 Xác thực · A08 Toàn vẹn · A09 Log · A10 Xử lý lỗi · Phần B Khi dùng AI · Phụ lục A Kiểm tự động · B Ngoài phạm vi · C Bảng 2025/2021 · D Nguồn từng rule. Tìm nhanh: Ctrl+F theo mã rule.

| Ký hiệu | Nghĩa |
|---|---|
| 📎 / 🔧 | Theo nguồn OWASP / lựa chọn của team |
| `[CODE]` | Hành vi đọc trực tiếp trong `vendor/magento` của dự án 2.4.6-p4, kèm `file:line` |
| `[RUN]` | Đã chạy thử thật (ghi rõ môi trường) |
| `[Adobe]` | Theo tài liệu Adobe Commerce, chỉ dùng cho tên API hay version |
| CS, CWE, X01/X03, CSPRNG | Xem bảng thuật ngữ trong [bản chung](../general/owasp-rules.md) |

Version: tài liệu kiểm trên Magento **2.4.6-p4**. Kiểm version của dự án bằng `composer show magento/product-community-edition` hoặc `bin/magento --version`. Dự án ở version khác thì kiểm lại các dòng `[CODE]`.

## Checklist review PR (1 trang)

Dán vào PR. ☑ = đã kiểm và đạt; gạch dòng = không liên quan. Mức 🔴 sai thì không merge. Số thứ tự của rule M2 không trùng với rule chung; dòng **Cụ thể hoá** dưới mỗi rule cho biết rule chung tương ứng.

**A01 Phân quyền**
- [ ] 🔴 `M2-A01-01` Controller admin có `ADMIN_RESOURCE` riêng, khai báo trong `acl.xml`
- [ ] 🔴 `M2-A01-02` Controller trong `Controller/Adminhtml` kế thừa `Magento\Backend\App\Action`
- [ ] 🔴 `M2-A01-03` `webapi.xml` không dùng `anonymous` cho dữ liệu nội bộ
- [ ] 🔴 `M2-A01-04` API của khách hàng dùng `self` và ép `%customer_id%`
- [ ] 🔴 `M2-A01-05` Load theo ID từ request có kiểm chủ sở hữu
- [ ] 🔴 `M2-A01-06` Action ghi dữ liệu chỉ nhận POST, không tắt kiểm CSRF
- [ ] 🔴 `M2-A01-07` Không gọi HTTP tới URL do người dùng cung cấp; client HTTP có timeout, chỉ cho HTTPS
- [ ] 🔴 `M2-A01-08` UI component admin có `aclResource`
- [ ] 🟠 `M2-A01-09` Redirect dùng `setRefererOrBaseUrl()` / `_redirect`, không `setUrl()` với giá trị từ request
- [ ] 🔴 `M2-A01-10` Controller frontend cần đăng nhập implement `AccountInterface` (tránh tên action `create`, `confirm`…)

**A02 Cấu hình**
- [ ] 🔴 `M2-A02-01` Không có file công cụ, backup, script test trong repo và web root
- [ ] 🔴 `M2-A02-02` Không commit secret; không sửa mode, không bật hiển thị lỗi
- [ ] 🟠 `M2-A02-03` Script inline đi qua `SecureHtmlRenderer`, domain ngoài khai trong `csp_whitelist.xml`
- [ ] 🟠 `M2-A02-04` Cookie đặt qua `CookieManagerInterface`; cookie riêng tư dùng `setSensitiveCookie()`
- [ ] 🟠 `M2-A02-05` XML từ bên ngoài không parse với `LIBXML_NOENT` / `LIBXML_DTDLOAD`

**A03 Chuỗi cung ứng**
- [ ] 🔴 `M2-A03-01` Thư viện bên thứ ba cài bằng composer, không copy vào module
- [ ] 🔴 `M2-A03-02` Không sửa `vendor/`; `composer.lock` được commit; `composer audit` sạch; hotfix bảo mật được ghi lại

**A04 Mã hoá**
- [ ] 🔴 `M2-A04-01` Không dùng `md5`/`sha1` cho mục đích bảo mật; so sánh token bằng `compareStrings`
- [ ] 🔴 `M2-A04-02` Giá trị ngẫu nhiên bảo mật lấy từ `Math\Random`
- [ ] 🔴 `M2-A04-03` Secret trong system config được mã hoá
- [ ] 🔴 `M2-A04-04` Không tắt kiểm chứng chỉ TLS
- [ ] 🔴 `M2-A04-05` Dữ liệu riêng của khách không nằm trong trang được full page cache

**A05 Injection**
- [ ] 🔴 `M2-A05-01` Không nối biến vào SQL
- [ ] 🔴 `M2-A05-02` Mọi output trong `.phtml` được escape đúng ngữ cảnh
- [ ] 🔴 `M2-A05-03` Dữ liệu PHP đưa sang JS đi qua JSON serializer, template dùng `$block`/`$escaper`
- [ ] 🔴 `M2-A05-04` Không gọi shell, `eval`, `include` với biến
- [ ] 🔴 `M2-A05-05` Upload có whitelist đuôi file; đường dẫn file không lấy từ request
- [ ] 🟠 `M2-A05-06` Không đưa nội dung do người dùng nhập qua template filter (`{{var}}`, `{{block}}`…)
- [ ] 🔴 `M2-A05-07` URL tuyệt đối lấy từ `UrlInterface` / store base URL, không từ `getHttpHost()`

**A06 Thiết kế**
- [ ] 🔴 `M2-A06-01` Giá, số lượng, giảm giá tính lại ở server
- [ ] 🟠 `M2-A06-02` Form và API public có chống gửi tự động
- [ ] 🟠 `M2-A06-03` Endpoint danh sách và bulk có giới hạn kích thước
- [ ] 🔴 `M2-A06-04` Coupon, tồn kho, điểm, số dư custom: update có điều kiện hoặc `forUpdate()` trong transaction
- [ ] 🔴 `M2-A06-05` Module thanh toán: xác minh với cổng ở server, khớp `getGrandTotal()` và tiền tệ, xử lý một lần (PR chỉ có lớp xử lý thì tìm controller gọi nó để kiểm `M2-A08-03`)

**A07 Xác thực**
- [ ] 🔴 `M2-A07-01` Không tự viết đăng nhập, session, reset password
- [ ] 🔴 `M2-A07-02` Không hardcode tài khoản, mật khẩu, API key
- [ ] 🟠 `M2-A07-03` Thông báo lỗi không tiết lộ tài khoản có tồn tại hay không
- [ ] 🟠 `M2-A07-04` Đăng nhập custom đi qua `setCustomerDataAsLoggedIn()`; đổi mật khẩu dùng `changePassword()` có mật khẩu hiện tại
- [ ] 🔴 `M2-A07-05` (nếu tự kiểm JWT) `JwtManagerInterface::read()` với một thuật toán, không có `NoEncryption`; tự kiểm `exp`, `iss`, `aud`

**A08 Toàn vẹn dữ liệu**
- [ ] 🔴 `M2-A08-01` Không dùng `unserialize()` của PHP
- [ ] 🔴 `M2-A08-02` Không đổ nguyên request vào model
- [ ] 🔴 `M2-A08-03` Webhook kiểm chữ ký, chống gửi lại, xử lý một lần
- [ ] 🟠 `M2-A08-04` Script ngoài có SRI hoặc tự host

**A09 Log**
- [ ] 🟠 `M2-A09-01` Sự kiện bảo mật được log qua `LoggerInterface`
- [ ] 🔴 `M2-A09-02` Log không chứa mật khẩu, token, session ID, dữ liệu thẻ
- [ ] 🔴 `M2-A09-03` Không còn `var_dump`, `print_r`, file log tự tạo trong `pub/`

**A10 Xử lý lỗi**
- [ ] 🔴 `M2-A10-01` Không có `catch` rỗng, không dùng `@`
- [ ] 🔴 `M2-A10-02` Không trả message exception gốc cho người dùng
- [ ] 🟠 `M2-A10-03` Ghi nhiều bảng thì dùng transaction
- [ ] 🔴 `M2-A10-04` Kiểm kết quả `load()` bằng `getId()`

**Rule chung không có bản M2, vẫn phải kiểm** (xem [bản chung](../general/owasp-rules.md)):
- [ ] 🟠 `G-A03-03` Package mới được nêu lý do trong PR
- [ ] 🟡 `G-A05-07` (nếu có tính năng LLM) Output của LLM xử lý như input không tin cậy
- [ ] 🟡 `G-A06-03` Luồng quan trọng có test trường hợp bị lạm dụng
- [ ] 🟠 `G-A06-06` Luồng nhiều bước kiểm trạng thái ở server trước mỗi bước

**B Khi code có AI tham gia** (áp cho mọi PR có code do AI viết hoặc sửa): dùng mục B trong checklist của [bản chung](../general/owasp-rules.md), cộng thêm:
- [ ] 🔴 `M2-AI-05` `app/etc/env.php` và file dump database nằm ngoài tầm đọc của công cụ AI

---

## A01 — Broken Access Control (phân quyền hỏng)

📎 OWASP: trừ tài nguyên public, mặc định từ chối; kiểm quyền sở hữu bản ghi; dùng cơ chế phân quyền có sẵn thay vì tự viết.

### M2-A01-01 — Controller admin phải có `ADMIN_RESOURCE` riêng
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-01

**Vì sao:** `Magento\Backend\App\AbstractAction` đặt mặc định `ADMIN_RESOURCE = 'Magento_Backend::admin'`. Controller không khai báo lại thì mọi tài khoản admin đăng nhập được đều gọi được, kể cả role bị giới hạn.

**❌ Sai**
```php
class Delete extends \Magento\Backend\App\Action
{
    public function execute()
    {
        $id = $this->getRequest()->getParam('id');
        $this->logFactory->create()->load($id)->delete();
    }
}
```

**✅ Đúng**
```php
class Delete extends \Magento\Backend\App\Action implements HttpPostActionInterface
{
    public const ADMIN_RESOURCE = 'Vendor_Module::log_delete';
}
```
và khai báo `Vendor_Module::log_delete` trong `etc/acl.xml`. Menu và button dẫn tới action cũng dùng cùng resource.

**Kiểm:** `grep -rL "ADMIN_RESOURCE\|_isAllowed" app/code/*/*/Controller/Adminhtml --include=*.php` — mỗi file hiện ra phải có class cha khai báo resource.

### M2-A01-02 — Controller trong `Controller/Adminhtml` phải kế thừa `Magento\Backend\App\Action`
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-01

**Vì sao:** kiểm đăng nhập admin và secret key trên URL được gắn vào `Magento\Backend\App\AbstractAction` (plugin `adminAuthentication` trong `module-backend/etc/adminhtml/di.xml`). Controller kế thừa `Magento\Framework\App\Action\Action` hoặc chỉ implement `ActionInterface` sẽ không đi qua các kiểm tra này.

**❌ Sai**
```php
namespace Vendor\Module\Controller\Adminhtml\Attachment;

class Preview extends \Magento\Framework\App\Action\Action
```

**✅ Đúng**
```php
class Preview extends \Magento\Backend\App\Action
{
    public const ADMIN_RESOURCE = 'Vendor_Module::attachment_view';
}
```

**Kiểm:** `grep -rn "extends" app/code/*/*/Controller/Adminhtml --include=*.php | grep -v "Backend\\\\App\\\\"` rồi lần theo class cha.

### M2-A01-03 — `webapi.xml` không dùng `anonymous` cho dữ liệu nội bộ
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-01

**Vì sao:** `<resource ref="anonymous"/>` nghĩa là ai trên internet cũng gọi được, không cần token. Route "tạm để test" rất dễ bị quên và lên production.

**❌ Sai** — một route test của module đồng bộ ERP, nhận `endpoint` từ body rồi gọi sang hệ thống ngoài
```xml
<!-- Start: Api Test -->
<route url="/V1/vendor-erp/get/" method="POST">
    <service class="Vendor\ErpSync\Helper\ApiSupport" method="get" />
    <resources>
        <resource ref="anonymous" />
    </resources>
</route>
```

**✅ Đúng**
```xml
<resources>
    <resource ref="Vendor_ErpSync::sync" />
</resources>
```
Route chỉ để test thì không commit. Route public thật sự (ví dụ lấy danh sách quốc gia) phải ghi lý do trong PR.

**Endpoint cho integration và đối tác:**
- Mỗi nhóm endpoint một ACL resource riêng trong `acl.xml`; integration chỉ được cấp đúng resource nó cần. 📎 Token chỉ dùng được cho đúng tài nguyên và hành động đã cấp, kiểm ở mỗi request (OAuth 2.0 CS, Authorization CS).
- `[CODE]` ACL cấp quyền theo **loại tài nguyên**, không theo từng bản ghi: hai đối tác cùng có `Vendor_ErpSync::sync` sẽ đọc được dữ liệu của nhau. Muốn mỗi đối tác chỉ thấy dữ liệu của mình thì service phải tự lọc: kiểm `UserContextInterface::getUserType() === UserContextInterface::USER_TYPE_INTEGRATION` (`module-authorization/Model/UserContextInterface.php:20`), lấy ID integration từ `getUserId()`, rồi map sang đối tác ở phía server. 📎 ID đối tác do client gửi chỉ là bộ chọn, phải khớp với danh tính đã xác thực (Multi-Tenant Security CS).
- `[CODE]` Dùng access token của integration làm bearer token độc lập là tuỳ chọn `oauth/consumer/enable_integration_as_bearer` (Stores > Configuration > Services > OAuth); core không đặt giá trị mặc định nên tuỳ chọn này **tắt** (`module-integration/Model/Config/AuthorizationConfig.php:42-47`, `etc/adminhtml/system.xml:57`). 🔧 Giữ tắt, trừ khi đối tác không ký được OAuth 1.0a; bật thì coi token như mật khẩu. 📎 Không đặt key hay token trên URL; không dựa riêng vào API key cho tài nguyên giá trị cao (REST Security CS).

**Kiểm:** `grep -rn 'ref="anonymous"' app/code --include=webapi.xml`

### M2-A01-04 — API của khách hàng dùng `self` và ép `%customer_id%`
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-02

**Vì sao:** nếu service nhận `customerId` từ client thì khách A truyền ID của khách B là đọc được dữ liệu của B. Magento cho phép ép tham số từ token.

**✅ Đúng** (cách core làm trong `module-customer/etc/webapi.xml`)
```xml
<route url="/V1/vendor/my-requests" method="GET">
    <service class="Vendor\Module\Api\RequestRepositoryInterface" method="getListForCustomer"/>
    <resources>
        <resource ref="self"/>
    </resources>
    <data>
        <parameter name="customerId" force="true">%customer_id%</parameter>
    </data>
</route>
```

**Kiểm:** mỗi route có `ref="self"` phải có `force="true"` cho tham số định danh khách hàng.

### M2-A01-05 — Load theo ID từ request phải kiểm chủ sở hữu
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-02

**Vì sao:** đây là lỗi IDOR: đổi `order_id=1001` thành `1002` trên URL là xem được đơn của người khác. Đăng nhập rồi chưa có nghĩa là được xem mọi bản ghi.

**❌ Sai**
```php
$order = $this->orderRepository->get((int)$this->getRequest()->getParam('order_id'));
return $this->renderOrder($order);
```

**✅ Đúng**
```php
try {
    $order = $this->orderRepository->get((int)$this->getRequest()->getParam('order_id'));
} catch (NoSuchEntityException | InputException $e) {   // InputException khi ID rỗng
    throw new NotFoundException(__('Page not found.'));
}
if ((int)$order->getCustomerId() !== (int)$this->customerSession->getCustomerId()) {
    throw new NotFoundException(__('Page not found.'));
}
```
Với đơn hàng trong **trang tài khoản khách**, ưu tiên dùng `Magento\Sales\Controller\AbstractController\OrderViewAuthorizationInterface::canView()`. Trả về 404, không trả 403, để không tiết lộ bản ghi có tồn tại.

`[CODE]` `canView()` chỉ trả `true` khi `customer_id` của đơn khớp khách đang đăng nhập **và** trạng thái đơn thuộc nhóm hiển thị ngoài frontend (`module-sales/Controller/AbstractController/OrderViewAuthorization.php:39-46`). Vì vậy nó luôn trả `false` cho khách vãng lai, và **với cấu hình mặc định** trả `false` cho đơn `pending_payment` (trạng thái này không được đánh dấu `visible_on_front`: `module-sales/Setup/Patch/Data/InstallOrderStatusesAndInitialSalesConfig.php:90-93`; admin đổi được). Trang "quay về" sau thanh toán lấy đơn từ `Magento\Checkout\Model\Session::getLastRealOrder()` (`module-checkout/Model/Session.php:535`), và yêu cầu tham số trên URL khớp với đơn đó:
```php
$order = $this->checkoutSession->getLastRealOrder();
if (!$order->getId() || $order->getIncrementId() !== (string)$this->request->getParam('order')) {
    throw new NotFoundException(__('Page not found.'));
}
```
🔧 So `increment_id` vì đó là mã gửi cho cổng; dùng `entity_id` thì so `getId()`.

📎 Adobe: "Authorization must be verified explicitly." Kiểm tra này phải có ở **mọi** đường vào cùng dữ liệu: controller, service của REST, resolver của GraphQL (lấy người dùng từ `Magento\GraphQl\Model\Query\ContextInterface`). Ngoài controller, dùng `Magento\Authorization\Model\UserContextInterface` (`getUserId()`, `getUserType()`).

Nếu cho khách vãng lai truy cập bằng link chứa mã bí mật (hash), mã đó phải sinh theo `M2-A04-02` và so sánh theo `M2-A04-01`.

**Kiểm:** tìm `getParam('…id')` trong `Controller/` frontend; mỗi chỗ load entity phải có bước so sánh với customer hiện tại.

### M2-A01-06 — Action ghi dữ liệu chỉ nhận POST và không tắt kiểm CSRF
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-03

**Vì sao:** Magento chỉ kiểm form key cho request POST. Action xoá hoặc sửa mà chạy được bằng GET thì chỉ cần dụ người dùng bấm một link. Implement `CsrfAwareActionInterface` rồi `validateForCsrf()` trả `true` là tắt hẳn lớp bảo vệ này.

**❌ Sai**
```php
class Save extends Action implements CsrfAwareActionInterface
{
    public function validateForCsrf(RequestInterface $request): ?bool
    {
        return true;
    }
}
```

**✅ Đúng**
```php
class Save extends Action implements HttpPostActionInterface
```
Form trong `.phtml` có `<?= $block->getBlockHtml('formkey') ?>`. Chỉ tự xử lý CSRF cho webhook từ hệ thống ngoài, và khi đó bắt buộc kiểm chữ ký theo `M2-A08-03`.

**Kiểm:** `grep -rn "validateForCsrf" app/code --include=*.php` — mỗi kết quả phải có kiểm chữ ký hoặc token riêng.

### M2-A01-07 — Không gọi HTTP tới URL do người dùng cung cấp
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-04

**Vì sao:** 📎 SSRF nằm trong A01 từ bản 2025. Nếu server gọi tới URL lấy từ request, kẻ tấn công dùng server làm bàn đạp để chạm vào dịch vụ nội bộ (database, metadata của cloud, admin panel).

**❌ Sai**
```php
$endpoint = $this->request->getBodyParams()['endpoint'];
$this->curl->get($baseUrl . $endpoint);
```

**✅ Đúng**
```php
private const ENDPOINTS = ['products' => 'Products', 'stock' => 'StockOnHand'];

$key = (string)$this->request->getParam('type');
if (!isset(self::ENDPOINTS[$key])) {
    throw new LocalizedException(__('Unsupported request.'));
}
$this->curl->get($this->config->getBaseUrl() . self::ENDPOINTS[$key]);
```
Host lấy từ config do admin đặt, không lấy từ request.

📎 Adobe và OWASP bổ sung:
- Không nhận protocol từ người dùng (`phar://`, `file://`, `tcp://`); cố định `https`.
- Tắt tự động follow redirect, vì redirect dẫn được tới host nội bộ: `$curl->setOption(CURLOPT_FOLLOWLOCATION, false)`.
- `[CODE]` `Magento\Framework\HTTP\Client\Curl` mặc định timeout **300 giây** (`framework/HTTP/Client/Curl.php:80`) và cho phép cả HTTP, FTP, FTPS (`:360`). Đặt `$curl->setTimeout(10)`, `$curl->setOption(CURLOPT_CONNECTTIMEOUT, 5)`, `$curl->setOption(CURLOPT_PROTOCOLS, CURLPROTO_HTTPS)`, `$curl->setOption(CURLOPT_MAXREDIRS, 0)`. Client này ném `\Exception` chung, nên chỉ bắt `\Exception` quanh đúng lời gọi HTTP (`M2-A10-01`).
- 🔧 Đoạn đường dẫn thay đổi (ví dụ ID giao dịch) kiểm bằng regex chặt rồi `rawurlencode()`. Host lấy từ config cũng được kiểm là tên miền thuần.
- Không đưa nội dung response của hệ thống ngoài vào thông báo lỗi trả cho người dùng.
- Đặt timeout cho mọi lời gọi ra ngoài.
- 📎 X01:2025: giới hạn kích thước response ("Limit response sizes"). `[RUN]` `CURLOPT_MAXFILESIZE` **không đủ**: với libcurl 7.88.1 (container của v557), response không báo trước `Content-Length` vẫn được tải hết (thử 3 MB với giới hạn 1 MB). Cách đã chạy thử chặn được: callback tiến trình tải, vượt giới hạn thì `Curl` ném `\Exception` ("Callback aborted"), response nhỏ vẫn qua bình thường:
  ```php
  $curl->setOption(CURLOPT_NOPROGRESS, false);
  $curl->setOption(CURLOPT_XFERINFOFUNCTION, static fn($ch, $total, $now) => $now > self::MAX_RESPONSE_BYTES ? 1 : 0);
  ```
  🔧 Giới hạn tuỳ API, ví dụ 1 MB cho JSON. Vẫn giữ timeout, vì giới hạn kích thước không chặn được server trả chậm.

**Kiểm:** lần ngược mọi tham số của `Curl::get/post`, `curl_setopt(CURLOPT_URL)`, `file_get_contents('http…')` xem có đến từ request không.

### M2-A01-08 — UI component trong admin phải có `aclResource`
**Mức:** 🔴 · **Cụ thể hoá:** G-A01-01

**Vì sao:** 📎 Adobe: dữ liệu của mọi UI component (grid, form) lấy được qua URL chung `mui/index/render`, không đi qua controller của module. `ADMIN_RESOURCE` trên controller hiển thị trang không bảo vệ đường này. Core kiểm `aclResource` của data provider tại `Magento\Ui\Controller\Adminhtml\Index\Render`; không khai báo thì không có kiểm tra nào.

**✅ Đúng** — `view/adminhtml/ui_component/vendor_module_request_listing.xml`
```xml
<dataSource name="vendor_module_request_listing_data_source" component="Magento_Ui/js/grid/provider">
    <settings>
        <updateUrl path="mui/index/render"/>
    </settings>
    <aclResource>Vendor_Module::request_view</aclResource>
    <dataProvider class="Vendor\Module\Ui\DataProvider\RequestListing" name="vendor_module_request_listing_data_source"/>
</dataSource>
```

**Kiểm:** `grep -rL "aclResource" app/code/*/*/view/adminhtml/ui_component --include=*.xml` — mỗi file có `<dataSource>` phải có `aclResource`.

### M2-A01-09 — Redirect dùng `setRefererOrBaseUrl()` / `_redirect`, không `setUrl()` với giá trị từ request
**Mức:** 🟠 · cụ thể hoá `G-A01-05`

**Vì sao:** 📎 open redirect (CWE-601, A01:2025). Tham số kiểu `?return_url=` do người dùng gửi.

**❌ Sai**
```php
return $this->resultRedirectFactory->create()
    ->setUrl($this->getRequest()->getParam('return_url'));
```

**✅ Đúng**
```php
return $this->resultRedirectFactory->create()->setRefererOrBaseUrl();
// hoặc
$url = $this->_redirect->success($defaultUrl);
```
`[CODE]` `Magento\Store\App\Response\Redirect` (`module-store/App/Response/Redirect.php:145`, `:215`): `getRefererUrl()` và `success()` đều đổi URL không thuộc base URL của store thành base URL. Phép kiểm `_isUrlInternal()` (`:250`, `:303`) so prefix với base URL của store. Cần redirect tới domain ngoài thì làm theo `G-A01-05` (allow-list theo scheme, host, port).

`Magento\Framework\Url\HostChecker::isOwnOrigin()` trả `true` cho URL **không có host** (`framework/Url/HostChecker.php:37-40`). Vì vậy không dùng nó làm phép kiểm duy nhất khi input có thể là đường dẫn tương đối do người dùng gửi.

**Kiểm:** `grep -rnE 'setUrl\(\s*\$this->(getRequest\(\)|_?request)' app/code`

`[CODE]` `getRefererUrl()` lấy đích từ header Referer, hoặc từ tham số `referer_url`, `uenc`, `r64` của request (`Redirect.php:132-143`; tên tham số ở `framework/App/Response/RedirectInterface.php:17` và `App/ActionInterface.php:22,24`). `success()` / `error()` đọc thêm `success_url` (`RedirectInterface.php:21`) / `error_url` (`:19`). Sau đó kiểm bằng so prefix với base URL của store (an toàn vì base URL kết thúc bằng `/`), và chấp nhận cả custom admin URL (`Redirect.php:253`; chỉ trong area adminhtml khi bật "Use Custom Admin URL", `:288-291`). Người dùng vẫn chọn được **trang nội bộ** đích; chấp nhận được, vì G-A01-05 chỉ cấm đích ngoài site. 🔧 Đích cố định thì ưu tiên `setPath('route/controller/action')`.

**Nguồn:** [Unvalidated Redirects and Forwards](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html)

### M2-A01-10 — Controller frontend dành cho khách đã đăng nhập implement `AccountInterface`
**Mức:** 🔴 · cụ thể hoá `G-A01-01`

**Vì sao:** controller frontend implement `HttpPostActionInterface` / `HttpGetActionInterface` thì ai cũng gọi được, kể cả khách chưa đăng nhập. Khi đó `getCustomerId()` trả `null`, và code thường chạy tiếp với dữ liệu sai.

**✅ Đúng**
```php
class Redeem implements HttpPostActionInterface, \Magento\Customer\Controller\AccountInterface
```
`[CODE]` Mọi controller implement `Magento\Customer\Controller\AccountInterface` được plugin `Magento\Customer\Controller\Plugin\Account` bọc lại (`module-customer/etc/frontend/di.xml:54-56`). Plugin gọi `$session->authenticate()`, và chuyển khách chưa đăng nhập sang trang login (`Controller/Plugin/Account.php:60-64`).

⚠️ **Bẫy:** plugin miễn đăng nhập cho một danh sách action, và chỉ so theo **tên action**, không theo module (`Controller/Plugin/Account.php:73-78`; danh sách ở `etc/frontend/di.xml`: `create`, `login`, `logoutsuccess`, `forgotpassword`, `forgotpasswordpost`, `resetpassword`, `resetpasswordpost`, `confirm`, `confirmation`, `createpassword`, `createpost`, `loginpost`). Controller custom có file tên `Create.php`, `Confirm.php`… sẽ **không** bị bắt đăng nhập. Đặt tên khác, hoặc kiểm thêm `$customerSession->isLoggedIn()` trong `execute()`.

**Kiểm:** bẫy tên action: `find app/code -path '*/Controller/*' -not -path '*Adminhtml*' -iregex '.*/\(create\|login\|logoutsuccess\|forgotpassword\|forgotpasswordpost\|resetpassword\|resetpasswordpost\|confirm\|confirmation\|createpassword\|createpost\|loginpost\)\.php' | xargs -r grep -l AccountInterface`, mỗi kết quả là controller **không** bị bắt đăng nhập. Controller thiếu bảo vệ: `grep -rLE 'AccountInterface|isLoggedIn\(' app/code/*/*/Controller --include=*.php | grep -v Adminhtml`. Mỗi file được liệt kê phải là endpoint public có chủ đích (webhook có chữ ký, trang công khai).

**Nguồn:** [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) · [A01:2025](https://top10.owasp.org/2025/A01_2025-Broken_Access_Control/)

---

## A02 — Security Misconfiguration (cấu hình hở)

📎 OWASP: không để tính năng thừa, tài khoản mặc định, thông báo lỗi chi tiết; gửi security header. Phần lớn nhóm này thuộc hạ tầng (xem phụ lục); dưới đây là phần dev kiểm soát được qua code và repo.

### M2-A02-01 — Không để file công cụ, backup, script test trong repo và web root
**Mức:** 🔴 · **Cụ thể hoá:** G-A02-01

**Vì sao:** file nằm trong `pub/` là truy cập được từ internet. Công cụ quản trị database, file dump `.sql`, script `test_*.php` là thứ scanner tự động tìm đầu tiên.

**❌ Sai** — các file gặp trong thực tế: `pub/adminer.php`, `pub/info.php`, `test_scenario_1.php`, `db_backup_20251104.sql.gz`, `log.zip` ở thư mục gốc.

**✅ Đúng:** script chạy một lần viết thành console command (`bin/magento vendor:task`) hoặc data patch. File dump để ngoài thư mục dự án. Thêm các pattern này vào `.gitignore`.

**Kiểm:** `git status --short` trước khi commit; `ls pub/*.php` chỉ được có `index.php`, `get.php`, `static.php`, `cron.php`, `health_check.php` của core.

### M2-A02-02 — Không commit secret; không đổi mode hay bật hiển thị lỗi bằng code
**Mức:** 🔴 · **Cụ thể hoá:** G-A02-02

**Vì sao:** `app/etc/env.php` chứa crypt key và mật khẩu database, `auth.json` chứa key tải package. Hiển thị lỗi chi tiết trên production làm lộ đường dẫn, câu SQL, version.

**❌ Sai:** `ini_set('display_errors', '1');` hoặc `error_reporting(E_ALL);` trong code module; commit `env.php`, `auth.json`.

**✅ Đúng:** secret nằm trong `env.php` hoặc biến môi trường trên server, không vào git. Cần debug thì dùng log (`M2-A09-01`).

**Kiểm:** `grep -rn "display_errors\|error_reporting(" app/code --include=*.php`; `git ls-files | grep -E "env\.php|auth\.json"` phải rỗng.

### M2-A02-03 — Script inline đi qua `SecureHtmlRenderer`; domain ngoài khai trong `csp_whitelist.xml`
**Mức:** 🟠 · **Cụ thể hoá:** G-A02-03

**Vì sao:** Content Security Policy (CSP) là header bảo trình duyệt chỉ chạy script từ nguồn được phép, hạn chế hậu quả khi lọt XSS. Script inline viết tay và domain không khai báo buộc dự án phải nới lỏng hoặc tắt CSP.

**❌ Sai**
```php
<script>window.cfg = <?= $block->getConfigJson() ?>;</script>
```

**✅ Đúng**
```php
<?= /* @noEscape */ $secureRenderer->renderTag('script', [], 'window.cfg = ' . $configJson . ';', false) ?>
```
`$secureRenderer` có sẵn trong mọi template. Domain ngoài (CDN, analytics) khai trong `etc/csp_whitelist.xml` của module cần nó, không khai gộp vào một module chung (📎 Adobe: "add resources only in modules that require it"). Không dùng `onclick="…"` trong HTML; dùng `renderEventListenerAsTag`.

`[CODE]` Thẻ `<script type="text/x-magento-init">` chứa JSON, trình duyệt không chạy nó như JS, nên **không bắt buộc** qua `renderTag()`: 130/150 template core viết thẳng thẻ này. Dữ liệu bên trong vẫn phải theo `M2-A05-03` (serializer, `JsonHexTag`).

Ghi chú version: lấy nonce trực tiếp bằng `Magento\Csp\Helper\CspNonceProvider` chỉ có từ 2.4.7; trên 2.4.6 dùng `SecureHtmlRenderer`. CSP không chặn `eval()`, nên rule `M2-A05-04` vẫn cần.

**Kiểm:** `grep -rn "<script" app/code --include=*.phtml | grep -v "x-magento-init\|text/x-magento"`

### M2-A02-04 — Cookie đặt qua `CookieManagerInterface`; cookie riêng tư dùng `setSensitiveCookie()`
**Mức:** 🟠 · cụ thể hoá `G-A02-04`

**❌ Sai**
```php
setcookie('vendor_token', $token, time() + 86400, '/');
```

**✅ Đúng**
```php
$metadata = $this->cookieMetadataFactory->createSensitiveCookieMetadata([
    CookieMetadata::KEY_DURATION => 86400,   // Magento\Framework\Stdlib\Cookie\CookieMetadata
])->setPath('/');
$this->cookieManager->setSensitiveCookie('vendor_token', $token, $metadata);
```
`[CODE]` `SensitiveCookieMetadata` mặc định `HttpOnly = true` và `SameSite = Lax` (`framework/Stdlib/Cookie/SensitiveCookieMetadata.php:31-37`); cờ `Secure` được đặt theo request có phải HTTPS không. `SensitiveCookieMetadata` **không có** `setDuration()` (method này chỉ có ở `PublicCookieMetadata.php:36`), nên thời hạn truyền qua mảng metadata (`PhpCookieManager.php:248-249`). `setPublicCookie()` chỉ dùng cho cookie mà JavaScript cần đọc và không chứa dữ liệu riêng. 📎 Không lưu token hay session ID trong `localStorage` (cả trong JS của theme).

**Kiểm:** `grep -rn "setcookie(" app/code app/design`; `grep -rn "localStorage.setItem" app/code app/design --include=*.js`

**Nguồn:** [Session Management → Cookies, HTML5 Web Storage API](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)

### M2-A02-05 — XML từ bên ngoài không parse với `LIBXML_NOENT` / `LIBXML_DTDLOAD`
**Mức:** 🟠 · cụ thể hoá `G-A02-05`

**Vì sao:** 📎 XXE (CWE-611, A02:2025). Module import sản phẩm, đơn, tồn kho từ file XML của ERP hoặc từ feed là chỗ nhận XML không tin cậy.

**✅ Đúng:** làm theo `G-A02-05` (PHP): không truyền `LIBXML_NOENT`, `LIBXML_DTDLOAD`, `LIBXML_DTDVALID` vào `loadXML()` / `simplexml_load_string()`; cần chặn hẳn thì đặt `libxml_set_external_entity_loader(function () { return null; })` trước khi parse.

📎 XXE Prevention CS (General Guidance): "Disable document type definitions (DTDs) whenever possible. Reject DOCTYPE declarations if the parser supports it." 🔧 File dữ liệu từ ERP hay feed không cần DTD, nên **từ chối mọi XML có DOCTYPE**. Kiểm sau khi parse, không tìm chuỗi (input UTF-16 vượt qua được phép tìm chuỗi): `DOMDocument` thì `$dom->doctype !== null`; `XMLReader` thì gặp node `XMLReader::DOC_TYPE` là dừng.

Ghi nhận khi giả lập (`[RUN]` PHP 8.2 trong container của dự án, 2026-11-17):
- Khi callback chặn entity loader đang bật, `DOMDocument::load($file)` **thất bại**, vì loader cũng xử lý chính file chính. Hãy đọc file thành chuỗi qua `Filesystem\Directory\ReadInterface` (hoặc `WriteInterface`) rồi `loadXML($string)`.
- Callback có hiệu lực cho cả tiến trình, nên đặt ngay trước khi parse và trả về mặc định bằng `libxml_set_external_entity_loader(null)` trong `finally`. Nếu không, các lần load XML/XSD sau trong cùng tiến trình cron sẽ hỏng.
- 🔧 Gọi `libxml_clear_errors()` trước khi parse, để lỗi của lần parse trước không làm hỏng lần sau.

`[CODE]` Có thể từ chối thêm XML chứa khai báo entity bằng `Magento\Framework\Xml\Security::scan()` (`framework/Xml/Security.php:48`). Lưu ý: khi chạy dưới PHP-FPM, method này chỉ tìm chuỗi `<!ENTITY` (`:22-24`, `:55-56`). Đây là lớp phụ, không thay cho việc không bật các cờ trên. `[RUN]` (giả lập) File XXE mã hoá UTF-16 không chứa byte `<!ENTITY` nên lọt qua phép tìm chuỗi này.

**Kiểm:** `grep -rnE "LIBXML_NOENT|LIBXML_DTDLOAD|LIBXML_DTDVALID" app/code`

**Nguồn:** [XML External Entity Prevention → PHP](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)

---

## A03 — Software Supply Chain Failures (chuỗi cung ứng phần mềm)

📎 OWASP: biết mình đang dùng thành phần nào và version nào; chỉ lấy từ nguồn tin cậy; gỡ thành phần không dùng.

### M2-A03-01 — Thư viện bên thứ ba cài bằng composer, không copy vào module
**Mức:** 🔴 · **Cụ thể hoá:** G-A03-01

**Vì sao:** thư viện copy tay không xuất hiện trong `composer.lock`, nên `composer audit` và các công cụ quét không thấy, và không ai cập nhật khi có bản vá.

**❌ Sai** — thư mục `app/code/Vendor/Module/vendor/Google/…` chứa nguyên một SDK cũ.

**✅ Đúng:** khai báo trong `composer.json` của module hoặc dự án, ghim version bằng `composer.lock`. Trước khi thêm package mới: xem lần release gần nhất, số lượt tải, có còn được bảo trì không.

**Kiểm:** `find app/code -type d -name vendor`; diff của `composer.json` phải được nêu trong mô tả PR.

### M2-A03-02 — Không sửa `vendor/`; commit `composer.lock`; chạy `composer audit`
**Mức:** 🔴 · **Cụ thể hoá:** G-A03-02

**Vì sao:** sửa trực tiếp trong `vendor/` sẽ mất khi cài lại và che mất việc code đã khác bản gốc. Không có `composer.lock` thì mỗi lần deploy có thể kéo về version khác nhau.

**✅ Đúng:** sửa lỗi core hoặc module ngoài bằng plugin, preference, hoặc file patch trong `patches/` áp dụng qua composer. Chạy `composer audit` trước mỗi release và khi PR đổi `composer.lock`.

Chính Magento cũng là một dependency. Ví dụ dòng 2.4.6 có 15 bản security patch tính đến 2026-05-12 (p1 đến p15), và hỗ trợ thường xuyên của dòng này đã kết thúc ngày 2026-08-11. Dự án chưa nâng được bản patch thì phải áp hotfix rời của Adobe qua composer patches, đặt tên patch có mã lỗi (ví dụ `VULN-xxxxx`, `APSBxx-xx`) để ai đọc `composer.json` cũng biết lỗ hổng nào đã được vá. Dev cần biết dự án đang ở bản patch nào trước khi đánh giá một cảnh báo bảo mật.

**Kiểm:** `composer audit`; `git status vendor/` không có thay đổi được commit; `composer show magento/product-community-edition` để biết bản patch hiện tại.

---

## A04 — Cryptographic Failures (mã hoá sai hoặc thiếu)

📎 OWASP: không dùng thuật toán lỗi thời; không để key trong source; kiểm chứng chỉ; dùng thư viện đáng tin thay vì tự viết.

### M2-A04-01 — Không dùng `md5`/`sha1` cho mục đích bảo mật; so sánh token bằng `compareStrings`
**Mức:** 🔴 · **Cụ thể hoá:** G-A04-01

**Vì sao:** `md5` và `sha1` tính rất nhanh và đã có va chạm, nên không dùng được cho mật khẩu, token, chữ ký. So sánh bằng `===` dừng ở ký tự sai đầu tiên, về lý thuyết cho phép đoán dần token qua thời gian phản hồi.

**❌ Sai**
```php
$token = md5($customer->getEmail() . time());
if ($request->getParam('hash') !== $attachment->getHash()) { … }
```

**✅ Đúng**
```php
use Magento\Framework\Encryption\Helper\Security;

$token = $this->random->getUniqueHash();
$signature = hash_hmac('sha256', $payload, $secret);
if (!Security::compareStrings($attachment->getHash(), (string)$request->getParam('hash'))) { … }
```
Mật khẩu: `EncryptorInterface::getHash($password, true)` và `isValidHash()`. 🔧 Giá trị "ai cầm là dùng được" lưu trong bảng custom (mã thẻ quà tặng, mã giảm giá bí mật, token của đối tác): lưu SHA-256 của mã với unique index để tra cứu, cộng vài ký tự cuối để hiển thị. Chỉ dùng `EncryptorInterface::encrypt()` khi buộc phải lấy lại bản rõ (ví dụ để gửi email), và xoá bản rõ ngay khi dùng xong. `md5` chỉ chấp nhận cho việc không liên quan bảo mật như tạo cache key. Sniff `Magento2.Security.InsecureFunction` (Phụ lục A) vẫn sẽ báo; ghi lý do trong PR, hoặc dùng `hash('sha256', …)` cho khỏi bị báo.

**Kiểm:** `grep -rnE "\b(md5|sha1)\(" app/code --include=*.php` — mỗi kết quả phải giải thích được là không dùng cho bảo mật.

### M2-A04-02 — Giá trị ngẫu nhiên bảo mật lấy từ `Magento\Framework\Math\Random`
**Mức:** 🔴 · **Cụ thể hoá:** G-A04-02

**Vì sao:** `rand()`, `mt_rand()`, `uniqid()` đoán được. Dùng chúng cho token, mã reset, tên file bí mật thì kẻ tấn công tính ra được giá trị.

**❌ Sai**
```php
$token = sprintf('%04x%04x-%04x', mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff));
```

**✅ Đúng**
```php
$token = $this->mathRandom->getRandomString(32);
$number = random_int(100000, 999999);
```
📎 Adobe: secret và token dài tối thiểu 16 ký tự, nên 32.

**Kiểm:** `grep -rnE "\b(mt_rand|rand|uniqid)\(" app/code --include=*.php`

### M2-A04-03 — Secret trong system config phải được mã hoá
**Mức:** 🔴 · **Cụ thể hoá:** G-A04-03

**Vì sao:** API key lưu dạng thường trong `core_config_data` sẽ lộ qua mọi bản dump database và mọi người có quyền xem config.

**✅ Đúng** — `etc/adminhtml/system.xml`
```xml
<field id="api_key" type="obscure" translate="label" sortOrder="20" showInDefault="1">
    <label>API Key</label>
    <backend_model>Magento\Config\Model\Config\Backend\Encrypted</backend_model>
</field>
```
Đọc ra: `$this->encryptor->decrypt($this->scopeConfig->getValue('vendor/api/api_key'))`. Không đưa giá trị đã giải mã ra frontend, vào log, hay vào `config.xml` mặc định.

Khai báo path đó là **sensitive** trong `etc/di.xml`, như core làm cho PayPal (`module-paypal/etc/di.xml:194-200`):
```xml
<type name="Magento\Config\Model\Config\TypePool">
    <arguments>
        <argument name="sensitive" xsi:type="array">
            <item name="vendor/api/api_key" xsi:type="string">1</item>
        </argument>
    </arguments>
</type>
```
`[CODE]` Khi chạy `bin/magento app:config:dump`, path sensitive bị loại khỏi `app/etc/config.php` (file thường được commit) và được ghi vào `app/etc/env.php` (`module-config/etc/di.xml:229-262`: `appDumpConfigSystemSource` loại `sensitive`, `appDumpEnvSystemSource` ghi vào pool `APP_ENV`). Không khai báo thì secret (dạng đã mã hoá) nằm trong `config.php` và đi vào git cùng key giải mã ở môi trường nào có key đó. 📎 Secret không nằm trong source hay file cấu hình được commit (Webhook Security CS, Secrets Management CS). Giá trị theo từng môi trường đặt bằng `bin/magento config:sensitive:set`.

**Kiểm:** mọi field config có tên chứa `key`, `secret`, `token`, `password` phải có `backend_model` Encrypted **và** có path trong `sensitive` của `TypePool` ở `etc/di.xml`.

### M2-A04-04 — Không tắt kiểm chứng chỉ TLS
**Mức:** 🔴 · **Cụ thể hoá:** G-A04-04

**Vì sao:** tắt `CURLOPT_SSL_VERIFYPEER` thì kết nối HTTPS không còn xác minh đang nói chuyện với ai; kẻ đứng giữa đọc và sửa được API key, dữ liệu đơn hàng.

**❌ Sai**
```php
$curl->setOptions([
    CURLOPT_SSL_VERIFYPEER => false,
    CURLOPT_RETURNTRANSFER => true,
]);
```

**✅ Đúng:** để mặc định (có kiểm). Môi trường local lỗi chứng chỉ thì sửa CA của máy local, không sửa code.

**Kiểm:** `grep -rn "SSL_VERIFYPEER\|SSL_VERIFYHOST\|verify_peer\|'verify' *=> *false" app/code`

### M2-A04-05 — Dữ liệu riêng của khách không nằm trong trang được full page cache
**Mức:** 🔴 · cụ thể hoá `G-A04-05`

**Vì sao:** `[CODE]` Khi layout của trang không có block nào `cacheable="false"`, plugin page cache đặt header public cho response (`module-page-cache/Model/Layout/LayoutPlugin.php:70-73`). Full page cache lưu response GET/HEAD có `Cache-Control` dạng `public…s-maxage` (`framework/App/PageCache/Kernel.php:134-138`). Một block custom in tên, địa chỉ, giỏ hàng, giá riêng của khách vào trang bình thường (trang sản phẩm, danh mục, CMS) sẽ bị cache, và khách sau nhìn thấy dữ liệu của khách trước. 📎 A04:2025 yêu cầu tắt cache cho response chứa dữ liệu nhạy cảm, kể cả ở CDN và web server (Varnish).

**✅ Đúng:**
- Dữ liệu riêng hiển thị trên trang công khai: lấy qua **private content**, tức section của customer-data (`Magento\Customer\CustomerData\SectionSourceInterface`), và render bằng JS phía trình duyệt. `[CODE]` Section phải được khai báo vào `sectionSourceMap` của `SectionPoolInterface` trong `etc/frontend/di.xml` (như core: `module-customer/etc/frontend/di.xml:29-31`), và mỗi action làm đổi dữ liệu phải khai báo trong `etc/frontend/sections.xml` để section được làm mới (ví dụ `module-wishlist/etc/frontend/sections.xml`). Widget và CMS block nằm trên trang được cache cũng theo cách này.
- Trang chỉ dành cho khách đã đăng nhập: block khai báo `cacheable="false"` trong layout, giống cách core làm ở `module-customer/view/frontend/layout/customer_account_index.xml`. `cacheable="false"` làm **cả trang** không vào full page cache (`framework/View/Layout.php:1125-1130`), nên không đặt nó trên trang công khai.
- Controller custom trả JSON hoặc file chứa dữ liệu riêng: không gọi `setPublicHeaders()`; gọi `$this->getResponse()->setNoCacheHeaders()`, method này đặt `no-store` (`framework/App/Response/Http.php:167-172`). Controller chỉ implement `HttpGetActionInterface` (không kế thừa `Action`) thì không có `getResponse()`; đặt header trên result: `$result->setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0', true)` (`framework/Controller/AbstractResult.php:62`).
- `[CODE]` Full page cache chỉ lưu request GET/HEAD (`Kernel.php:138`), nên header public trên response POST không bị FPC lưu. Dù vậy, vẫn không đặt header public cho response chứa dữ liệu riêng, vì CDN hay proxy khác có thể xử lý khác.
- 📎 Không đưa header của request vào HTML được cache (cache poisoning, `G-A04-05`).
- `[CODE]` Form trên trang được cache vẫn dùng `$block->getBlockHtml('formkey')` bình thường, không cần `no-store`: JS ghi đè `form_key` bằng giá trị trong cookie (`module-page-cache/view/frontend/web/js/form-key-provider.js:86-95`), và server đăng ký giá trị cookie đó làm form key của session (`module-page-cache/Plugin/RegisterFormKeyFromCookie.php:75-80`).
- `[CODE]` Redirect 302 kèm message (`addSuccessMessage()` rồi redirect) không cần thêm `no-store`: FPC chỉ lưu response 200 và 404 (`Kernel.php:136-137`), VCL Varnish của core cũng vậy (`module-page-cache/etc/varnish6.vcl:175-177`); message đi qua section `messages` của customer-data (`module-theme/etc/frontend/sections.xml:11`).

**Kiểm:** block mới có dùng `customerSession`, `checkoutSession`, `getCustomer()` mà nằm trong layout không có `cacheable="false"` không. Thử bằng hai trình duyệt, đăng nhập hai khách khác nhau, ở developer mode xem header `X-Magento-Cache-Debug`.

**Nguồn:** [Web Cache Security](https://cheatsheetseries.owasp.org/cheatsheets/Web_Cache_Security_Cheat_Sheet.html) · [A04:2025](https://top10.owasp.org/2025/A04_2025-Cryptographic_Failures/)

---

## A05 — Injection (chèn mã)

📎 OWASP: ưu tiên API an toàn có tham số hoá; validate đầu vào ở server theo danh sách cho phép; escape theo ngữ cảnh đầu ra; không nhận tên bảng, tên cột từ người dùng.

### M2-A05-01 — Không nối biến vào SQL
**Mức:** 🔴 · **Cụ thể hoá:** G-A05-01

**Vì sao:** nối chuỗi là nguồn gốc của SQL injection. Kể cả khi biến hôm nay là hằng số, người sau copy đoạn code đó sang chỗ có dữ liệu từ request.

**❌ Sai**
```php
$result = $connection->fetchAll("SELECT * FROM $table WHERE path = '{$config}'");
```

**✅ Đúng** — theo thứ tự ưu tiên: repository hoặc collection, rồi mới đến `select()` có bind
```php
$select = $connection->select()
    ->from($this->resource->getTableName('core_config_data'))
    ->where('path = ?', $path);
$result = $connection->fetchAll($select);

$connection->update($table, ['value' => $value], ['path = ?' => $path]);
```
Tên cột để sắp xếp hay lọc lấy từ request phải đối chiếu với danh sách cố định trong code.

**Kiểm:** `grep -rnE "(fetchAll|fetchOne|fetchRow|fetchCol|query)\(\s*[\"'].*(\\$|\{)" app/code --include=*.php`; biểu thức SQL ghép chuỗi: `grep -rnE "Zend_Db_Expr\(\s*['\"][^'\"]*['\"]\s*\." app/code --include=*.php`. Ghép một số đã ép `(int)` vào `Zend_Db_Expr` không bị injection, nhưng nên dùng `$connection->quoteInto()` cho dễ review.

### M2-A05-02 — Mọi output trong `.phtml` phải escape đúng ngữ cảnh
**Mức:** 🔴 · **Cụ thể hoá:** G-A05-02

**Vì sao:** dữ liệu do người dùng hoặc admin nhập (tên, địa chỉ, ghi chú, tên sản phẩm) nếu in thẳng ra HTML sẽ chạy được script trong trình duyệt của người khác. Đây là XSS, thuộc nhóm Injection.

| Vị trí in ra | Dùng |
|---|---|
| Nội dung HTML | `$escaper->escapeHtml($value)` |
| Trong thuộc tính HTML | `$escaper->escapeHtmlAttr($value)` |
| Thuộc tính `href`, `src` | `$escaper->escapeUrl($url)` |
| Trong chuỗi JavaScript | `$escaper->escapeJs($value)` |
| Trong CSS | `$escaper->escapeCss($value)` |

**❌ Sai**
```php
<span class="<?= $block->getCssClass() ?>"><?= $block->getCustomerNote() ?></span>
```

**✅ Đúng**
```php
<span class="<?= $escaper->escapeHtmlAttr($block->getCssClass()) ?>">
    <?= $escaper->escapeHtml($block->getCustomerNote()) ?>
</span>
```
Chỉ bỏ escape khi giá trị là HTML do chính code sinh ra (`getChildHtml()`, `toHtml()`) hoặc số đã ép kiểu, và phải đánh dấu `/* @noEscape */` để reviewer thấy đó là chủ ý.

📎 Adobe: không escape lần hai với method đã trả về HTML an toàn (tên kết thúc bằng `Html`, ví dụ `getTitleHtml()`), giá trị ép kiểu `(int)`, hoặc `count()`. Escape hai lần làm hỏng hiển thị và khiến người sau gỡ escape ở chỗ sai.

**Kiểm:** `vendor/bin/phpcs --standard=Magento2 --sniffs=Magento2.Security.XssTemplate app/code/Vendor/Module`

### M2-A05-03 — Dữ liệu PHP đưa sang JS đi qua JSON serializer; template dùng `$block` và `$escaper`
**Mức:** 🔴 · **Cụ thể hoá:** G-A05-02

**Vì sao:** in mảng PHP vào giữa đoạn script bằng cách ghép chuỗi rất dễ vỡ cú pháp và chèn được mã. `$this` trong template là template engine, dùng nó là đi vòng qua API công khai của block.

**❌ Sai**
```php
<script type="text/x-magento-init">
{ "#uploader": { "attachment": { "config": <?= $this->getAttachmentConfig() ?> } } }
</script>
```

**✅ Đúng**
```php
<script type="text/x-magento-init">
{ "#uploader": { "attachment": { "config": <?= /* @noEscape */ $jsonSerializer->serialize($block->getAttachmentConfig()) ?> } } }
</script>
```
`getAttachmentConfig()` trả về mảng, serializer là `Magento\Framework\Serialize\Serializer\Json` (lấy qua view model). Mảng có chứa dữ liệu do người dùng nhập thì dùng `Magento\Framework\Serialize\Serializer\JsonHexTag`, bản này dùng `JSON_HEX_TAG` để mã hoá `<`, `>` (`JsonHexTag.php:29`). `Serializer\Json` gọi `json_encode` mặc định (`Json.php:24`) đã escape `/` nên `</script>` thành `<\/script>`; 🔧 `JsonHexTag` là lớp bảo vệ thêm cho các chuỗi như `<!--` hay `<script`. 📎 XSS Prevention CS: dữ liệu chèn vào script inline cần encoder phù hợp với cả chuỗi JavaScript lẫn thẻ `<script>` bao ngoài. `[CODE]` `AbstractBlock::getJsLayout()` dùng `json_encode` thường (`framework/View/Element/AbstractBlock.php:233`), không có tuỳ chọn này. Trong JS không dùng `.html()` hay `innerHTML` với dữ liệu từ server; dùng `.text()`, hoặc `createElement` kèm `innerText`.

📎 Adobe, cho UI component và Knockout:
- Dữ liệu do người dùng nhập trả về từ data provider phải kèm `'__disableTmpl' => true`. UI component coi chuỗi dạng `${ ... }` là template và sẽ thực thi nó nếu không tắt.
  `[CODE]` Trong 2.4.6, việc tắt này **chỉ tự động một phần**: không xử lý template cho `data` của form provider và grid provider, `value` của form element, `content` của component `html` (`module-ui/view/base/web/js/form/provider.js:25-27`, `grid/provider.js:37-39`, `form/element/abstract.js:60-62`, `form/components/html.js:24-26`). Các property khác của config và meta (label, `options`, `actions`, `imports`) **vẫn** được xử lý `${ }` (`magento2-base/lib/web/mage/utils/template.js:38-60`). Vì vậy option, label hay config dựng từ dữ liệu nhập (tên nhóm, tên thuộc tính, ghi chú) phải tự thêm `__disableTmpl`, như core làm với tên customer group (`module-customer/Ui/Component/Listing/Column/Group/Options.php:50`).
- Trong template Knockout, binding `text` an toàn, binding `html` thì không. Property buộc phải render HTML thô đặt tên có hậu tố `UnsanitizedHtml` để người đọc biết.

**Kiểm:** `grep -rn '\$this->' app/code --include=*.phtml`; `grep -rn 'data-bind="[^"]*html:' app/code --include=*.html`

### M2-A05-04 — Không gọi shell, `eval`, `include` với biến
**Mức:** 🔴 · **Cụ thể hoá:** G-A05-03

**Vì sao:** một tham số lọt vào dòng lệnh hoặc đường dẫn `include` là chạy được mã tuỳ ý trên server.

**❌ Sai**
```php
exec('convert ' . $inputPath . ' ' . $outputPath);
```

**✅ Đúng** — ưu tiên thư viện PHP thay cho lệnh ngoài; bắt buộc phải gọi lệnh thì
```php
$this->shell->execute('convert %s %s', [$inputPath, $outputPath]);
```
`Magento\Framework\Shell::execute` tự escape từng tham số.

**Kiểm:** `vendor/bin/phpcs --standard=Magento2 --sniffs=Magento2.Security.InsecureFunction,Magento2.Security.IncludeFile,Magento2.Security.LanguageConstruct app/code/Vendor/Module`

### M2-A05-05 — Upload: whitelist đuôi file, tên ngẫu nhiên, file riêng tư nằm ngoài `pub/`
**Mức:** 🔴 · **Cụ thể hoá:** G-A05-04

**Vì sao:** cho upload `.php`, `.phtml`, `.svg`, `.html` vào thư mục truy cập được từ web là cho chạy mã. Tên file chứa `../` cho phép đọc hoặc ghi ra ngoài thư mục dự định. File riêng tư (chứng từ, đính kèm đơn hàng) đặt trong `pub/media` thì ai có link cũng tải được, không qua kiểm quyền nào.

📎 Adobe: "Do not store these files in an HTTP accessible folder (like `/pub`)." Adobe cũng khuyên tránh lưu file nếu không cần, ví dụ đọc CSV rồi xử lý luôn thay vì lưu lại.

**❌ Sai**
```php
$target = $this->mediaDirectory->getAbsolutePath('orderattachment');
$uploader->setAllowedExtensions(explode(',', $this->scopeConfig->getValue('vendor/attachment/extensions')));
$uploader->save($target, $_FILES['attachment']['name']);
```
Ba lỗi: file riêng tư nằm trong media, danh sách đuôi file hoàn toàn do config quyết định, giữ tên file người dùng gửi.

**✅ Đúng**
```php
private const ALLOWED = ['pdf', 'jpg', 'jpeg', 'png'];

$uploader = $this->uploaderFactory->create(['fileId' => 'attachment']);
$uploader->setAllowedExtensions(self::ALLOWED);
$uploader->setAllowRenameFiles(false);
$extension = strtolower((string)$uploader->getFileExtension());
$storedName = $this->mathRandom->getRandomString(32) . '.' . $extension;
$uploader->save($this->varDirectory->getAbsolutePath('vendor_module/attachments'), $storedName);
```
- `$this->varDirectory` là `Filesystem::getDirectoryWrite(DirectoryList::VAR_DIR)`. `[CODE]` Lấy đuôi file bằng `getFileExtension()` (`framework/File/Uploader.php:457`); **không** dùng `getUploadedFileName()`, vì method này chỉ có giá trị sau `save()` (`:302`, `:570`), trước đó trả `null` và file bị lưu thành `xxx.`. (Ghi chú 2026-11-17: bản v2 trước đó có ví dụ sai ở dòng này.)
- 🔧 File không đến từ upload mà từ thư mục trao đổi (SFTP, cron): tên file kiểm bằng regex cho phép, kiểm dung lượng trước khi đọc, bỏ qua file còn đang được ghi (thời gian sửa đổi quá gần), xử lý xong thì chuyển sang `processed/` hoặc `failed/`, đọc qua `ReadInterface`/`WriteInterface` của thư mục `var/`.
- Tên gốc lưu trong database chỉ để hiển thị. Tải về đi qua controller có kiểm quyền theo `M2-A01-05`, tìm file bằng ID bản ghi.
- Config admin chỉ được thu hẹp danh sách `ALLOWED`, không được mở rộng.
- Ảnh và file cần public (media catalog, CMS) mới lưu trong `pub/media`, vẫn với whitelist đuôi file.
- 📎 OWASP: không tin header `Content-Type` do trình duyệt gửi; đặt giới hạn dung lượng; upload cần đăng nhập và form key.
- Đọc, ghi, xoá file qua `Magento\Framework\Filesystem\Directory\WriteInterface`; API này từ chối đường dẫn thoát ra ngoài thư mục gốc. Riêng bước lưu file upload thì `Uploader::save()` tự ghi; truyền thư mục đích lấy từ `WriteInterface` như ví dụ trên.
- ⚠️ `[CODE]` `setAllowedExtensions([])` với mảng **rỗng** nghĩa là **cho mọi đuôi file** (`framework/File/Uploader.php:653-654`). Danh sách lấy từ config mà để trống là mở toang. Luôn kiểm mảng không rỗng.
- `Uploader` không có API giới hạn dung lượng: kiểm `$_FILES[...]['size']` (qua `$this->getRequest()->getFiles()`) trước khi `save()`. 📎 File Upload CS: có giải nén hay xử lý thì giới hạn tính sau khi giải nén. File không qua kiểm tra thì xoá ngay.
- `var/` chỉ riêng tư khi web root là `pub/`, hoặc web server chặn `var/`. Kiểm cấu hình hosting (Phụ lục B); không chắc thì hỏi người phụ trách hosting trước khi dựa vào nó.
- Uploader: `Magento\MediaStorage\Model\File\UploaderFactory` (bản có thêm validator của MediaStorage) hoặc `Magento\Framework\File\UploaderFactory`. `[CODE]` Cả hai đều không giới hạn dung lượng.
- ⚠️ `[CODE]` `Magento\MediaStorage\Model\File\Validator\Image::isValid()` chỉ mở thử file khi MIME đã là ảnh; với MIME khác, nó trả `true` (`module-media-storage/Model/File/Validator/Image.php:68-83`). Không dùng nó làm phép kiểm duy nhất. 📎 Kiểm file signature và re-encode ảnh (File Upload CS). 🔧 Cách làm trong Magento: `getimagesize()` để kiểm loại ảnh và giới hạn kích thước pixel trước khi decode, rồi mở và lưu lại qua `Magento\Framework\Image\AdapterFactory`. Adapter ImageMagick gọi `stripImage()` khi lưu (`framework/Image/Adapter/ImageMagick.php:163`); `[CODE]` adapter mặc định là **GD2** (`module-store/etc/config.xml:34`), nên đừng mặc định là metadata đã bị bỏ.
- Controller trả file do người dùng upload: 📎 `X-Content-Type-Options: nosniff` (HTTP Headers CS) và `Content-Type` cố định theo loại đã kiểm, không lấy theo tên file.
- 🔧 File của người dùng chỉ public **sau khi được duyệt** (ảnh review, ảnh hồ sơ): lưu trong `var/`, phục vụ qua controller kiểm trạng thái duyệt; không đặt vào `pub/media` trước khi duyệt.

**Kiểm:** tìm `setAllowedExtensions`, `getDirectoryWrite(DirectoryList::MEDIA)`, `file_get_contents(`, `unlink(`, `fopen(` trong `app/code` và lần ngược nguồn của tham số.

### M2-A05-06 — Không đưa nội dung do người dùng nhập qua template filter
**Mức:** 🟠 · cụ thể hoá `G-A05-05`

**Vì sao:** 📎 SSTI: dữ liệu trở thành mã template. Template filter của Magento chạy các directive như `{{var}}`, `{{block}}`, `{{config path=""}}` trong nội dung được đưa vào (`Magento\Email\Model\Template\Filter::filter()`, `module-email/Model/Template/Filter.php:1124`; `Magento\Cms\Model\Template\FilterProvider`). Đưa text của khách (đánh giá, form liên hệ, ghi chú đơn) qua filter này là cho khách viết template.

**✅ Đúng:** chỉ chạy filter trên nội dung do admin soạn (CMS page, block, email template). Dữ liệu của khách truyền vào template email dưới dạng **biến** (`templateVars`) và in bằng `{{var …}}`, không ghép vào nội dung template trước khi filter. `[CODE]` `{{var x}}` **không có modifier** thì mặc định áp `escape`. **Ghi bất kỳ modifier nào là mất escape mặc định:** `{{var x|nl2br}}` không escape; `|raw` không phải modifier có đăng ký, tác dụng duy nhất của nó là bỏ escape (`module-email/Model/Template/Filter.php:678-681`, `:702-708`, `:721-739`; modifier đăng ký chỉ có `nl2br` `:81` và `escape` `:249`; email dùng `varDirective` này qua `LegacyDirective`, `module-email/etc/di.xml:78-86`). Dữ liệu của khách: modifier đầu tiên luôn là `escape`, ví dụ `{{var message|escape|nl2br}}`. Không cho request chọn template ID hay đường dẫn `.phtml`.

**Kiểm:** `grep -rnE "getBlockFilter\(\)|getPageFilter\(\)|->filter\(" app/code`, rồi lần ngược giá trị truyền vào; `grep -rnoE '\{\{var [^}]*\|[^}]*\}\}' app/code/*/*/view/*/email | grep -vE '\{\{var [^}|]*\|escape'` (mỗi kết quả là một `{{var}}` có modifier mà modifier đầu không phải `escape`).

**Nguồn:** [Server-Side Template Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Template_Injection_Prevention_Cheat_Sheet.html)

### M2-A05-07 — URL tuyệt đối lấy từ `UrlInterface` / store base URL, không từ `getHttpHost()`
**Mức:** 🔴 · cụ thể hoá `G-A05-06`

**❌ Sai**
```php
$link = 'https://' . $this->request->getHttpHost() . '/vendor/reset?token=' . $token;
```

**✅ Đúng**
```php
$link = $this->urlBuilder->getUrl('vendor/reset/index', ['_query' => ['token' => $token], '_secure' => true]);
// hoặc $this->storeManager->getStore()->getBaseUrl()
```
`[CODE]` `getHttpHost()` (`framework/HTTP/PhpEnvironment/Request.php:708`) đọc từ request, không từ cấu hình. ⚠️ Nếu base URL trong cấu hình là placeholder `{{base_url}}` thì Magento cũng lấy nó từ request (`module-store/Model/Store.php:658-659`). Production phải cấu hình base URL cố định (việc của người cài đặt, Phụ lục B). 📎 Header `Host`/`X-Forwarded-Host` do client chọn. Link gửi qua email lấy theo store của đơn hoặc của khách, không theo request hiện tại. Không đưa giá trị từ request vào `setHeader()` khi chưa kiểm.

**Kiểm:** `grep -rnE "getHttpHost\(|HTTP_HOST|X-Forwarded-Host" app/code`

**Nguồn:** [Input Validation → Host and Forwarded Headers](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html)

---

## A06 — Insecure Design (thiết kế không an toàn)

📎 OWASP: lỗi nằm ở thiết kế, code đúng theo thiết kế vẫn hở. Cần kiểm tra tính hợp lý ở mọi tầng và viết test cho cả trường hợp bị lạm dụng.

### M2-A06-01 — Giá, số lượng, giảm giá phải tính lại ở server
**Mức:** 🔴 · **Cụ thể hoá:** G-A06-01

**Vì sao:** mọi thứ gửi từ trình duyệt đều sửa được. Nếu controller nhận `price` hoặc `discount` từ request rồi gán vào quote, khách tự đặt giá cho mình.

**❌ Sai**
```php
$item->setCustomPrice($this->getRequest()->getParam('price'));
```

**✅ Đúng:** request chỉ mang định danh (SKU, option, số lượng). Giá lấy từ product, tier price, cart rule ở server. Số lượng và các giá trị số được ép kiểu và kiểm giới hạn (không âm, không vượt tồn kho, không vượt mức tối đa).

**Kiểm:** tìm `setCustomPrice`, `setOriginalCustomPrice`, `setDiscountAmount`, `setPrice` trong `app/code` và xem giá trị truyền vào đến từ đâu.

### M2-A06-02 — Form và API public phải có chống gửi tự động
**Mức:** 🟠 · **Cụ thể hoá:** G-A06-02

**Vì sao:** form không cần đăng nhập (liên hệ, yêu cầu mẫu, đăng ký B2B, kiểm tra mã giảm giá) không giới hạn thì bị dùng để spam email, dò mã, làm đầy database.

**✅ Đúng:** gắn reCAPTCHA của Magento (nhóm module `Magento_ReCaptcha*`) hoặc `Magento_Captcha` cho form custom. Với controller custom: 🔧 viết observer cho `controller_action_predispatch_<route>`, dùng `Magento\ReCaptchaUi\Model\IsCaptchaEnabledInterface` và `RequestHandlerInterface` (`module-re-captcha-ui/Model/`). `[CODE]` Observer có sẵn của core gọi `getRequest()`/`getResponse()` trên controller (`module-re-captcha-customer/Observer/CreateCustomerObserver.php:62-64`), nên không chạy với controller chỉ implement `HttpPostActionInterface`. Action gửi email hoặc ghi database từ form public phải có ít nhất một lớp: captcha, giới hạn theo IP hoặc session, hoặc yêu cầu đăng nhập.

📎 Adobe: bảo vệ **mọi** đường vào của cùng một chức năng. Nếu chức năng có cả controller, REST endpoint và GraphQL mutation thì cả ba phải có captcha; bảo vệ riêng controller thì kẻ tấn công chuyển sang gọi API.

Lưu ý: Magento 2.4.6-p4 không có sẵn cơ chế rate limit chung cho controller custom, nên phải chủ động thêm hoặc đặt ở tầng web server/WAF.

Con số giới hạn: OWASP **không** quy định; Authentication CS chỉ nêu các yếu tố phải chọn (ngưỡng, thời gian khoá, khoá tăng dần, đếm theo tài khoản). 🔧 Lấy mặc định của core làm mốc rồi chỉnh theo nghiệp vụ: `[CODE]` khách sai mật khẩu 10 lần thì khoá 10 phút (`module-customer/etc/config.xml:45-46`), admin 6 lần thì 30 phút (`module-user/etc/config.xml:20-21`), reset mật khẩu 5 lần/giờ và cách nhau ít nhất 10 phút (`module-security/etc/config.xml:14-15`), SendFriend 5 lần/giờ (`module-send-friend/etc/config.xml:16`).

📎 Tính năng gửi email tới địa chỉ do người dùng nhập (gửi cho bạn bè, chia sẻ wishlist, gửi quà) là đường spam nếu không rate limit (Business Logic Security CS). 🔧 Team giới hạn theo **customer ID**, kể cả khi đã đăng nhập. `[CODE]` Tham khảo core: module SendFriend mặc định tối đa 5 người nhận và 5 lần mỗi giờ (`module-send-friend/etc/config.xml:15-16`), nhưng mặc định đếm theo **cookie** (`config.xml:17`, `check_by=0`), là lựa chọn mà chính core ghi nhãn "Cookie (unsafe)" (`Model/Source/Checktype.php:25`). Không làm theo cách đếm đó. Địa chỉ email kiểm bằng `Magento\Framework\Validator\EmailAddress`.

**Kiểm:** liệt kê controller frontend, route `anonymous` trong `webapi.xml` và mutation GraphQL không yêu cầu đăng nhập mà có gửi email hoặc `save()`; mỗi cái phải chỉ ra được lớp bảo vệ.

### M2-A06-03 — Endpoint danh sách và bulk phải có giới hạn kích thước
**Mức:** 🟠 · **Cụ thể hoá:** G-A06-04

**Vì sao:** 📎 Adobe (mục DoS): truy vấn danh sách, ghi nhiều entity và gọi dịch vụ ngoài là các thao tác nặng. Một request xin `pageSize=1000000` hoặc gửi mảng 100.000 phần tử đủ làm cạn bộ nhớ và khoá database.

**❌ Sai**
```php
$collection->setPageSize((int)$this->getRequest()->getParam('limit'));
foreach ($this->getRequest()->getParam('ids') as $id) { … }
```

**✅ Đúng**
```php
private const MAX_PAGE_SIZE = 100;
private const MAX_BATCH = 200;

$limit = min(max((int)$request->getParam('limit', 20), 1), self::MAX_PAGE_SIZE);
$ids = array_slice(array_map('intval', (array)$request->getParam('ids', [])), 0, self::MAX_BATCH);
```
Với Web API của core, giới hạn chung nằm ở cấu hình Stores > Configuration > Services > Web API > Input Limits (`webapi/validation/maximum_page_size`); endpoint custom tự đặt giới hạn như trên. Việc nặng (export, đồng bộ hàng loạt) đưa vào message queue hoặc cron thay vì chạy trong request.

📎 OWASP không định nghĩa "việc nặng"; DoS CS chỉ yêu cầu không để request chờ việc lớn, xác định trước trang tốn tài nguyên, kiểm rẻ trước kiểm đắt sau. 🔧 Team coi là việc nặng, đưa vào message queue hoặc cron: gọi dịch vụ ngoài trong vòng lặp, gửi nhiều hơn một email, xử lý hoặc tạo file (ảnh, CSV, PDF), duyệt collection không có giới hạn trên, hoặc việc có thể vượt timeout của bên gọi.

**Kiểm:** tìm `setPageSize(`, `setCurPage(`, vòng lặp trên mảng lấy từ request; mỗi chỗ phải có giới hạn trên.

### M2-A06-04 — Coupon, tồn kho, điểm, số dư custom: update có điều kiện hoặc `forUpdate()` trong transaction
**Mức:** 🔴 · cụ thể hoá `G-A06-05`

**❌ Sai**
```php
$row = $connection->fetchRow($connection->select()->from($table)->where('code = ?', $code));
if ((int)$row['used'] === 0) {
    $connection->update($table, ['used' => 1], ['code = ?' => $code]);
    $this->applyReward($customerId);
}
```

**✅ Đúng:** update có điều kiện rồi kiểm số dòng bị ảnh hưởng.
```php
$affected = $connection->update($table, ['used' => 1], ['code = ?' => $code, 'used = ?' => 0]);
if ($affected !== 1) {
    throw new LocalizedException(__('This code has already been used.'));
}
$this->applyReward($customerId);
```
`[CODE]` `AdapterInterface::update()` trả số dòng bị ảnh hưởng (`framework/DB/Adapter/AdapterInterface.php:511-513`). Cần đọc rồi tính: `$select->forUpdate(true)` trong `beginTransaction()` … `commit()` (`framework/DB/Select.php:28`, `:469-470`). Khoá xuyên nhiều bảng hoặc nhiều tiến trình: `Magento\Framework\Lock\LockManagerInterface::lock()` / `unlock()`. Bản ghi "mỗi khách một lần": unique index trong `db_schema.xml`. `[CODE]` Lưu qua resource model thì lỗi trùng ra ngoài thành `Magento\Framework\Exception\AlreadyExistsException` ("Unique constraint violation found"), không phải `DuplicateException` (`framework/Model/ResourceModel/Db/AbstractDb.php:406-409`); bắt `AlreadyExistsException` và trả thông báo của mình. Insert trực tiếp thì dùng `insertArray(..., AdapterInterface::INSERT_IGNORE)` và kiểm số dòng.

🔧 Trừ số dư (`balance = balance - x`): mảng bind của `update()` không mang tham số vào được `Zend_Db_Expr`. Cách 1: `forUpdate(true)` đọc số dư, tính ở PHP, rồi `update()` với giá trị mới và **giá trị cũ trong WHERE**, yêu cầu đúng 1 dòng bị ảnh hưởng. Cách 2: `new \Zend_Db_Expr($connection->quoteInto('balance - ?', $amount))` kèm điều kiện `balance >= ?` trong WHERE.

**Giới hạn số lần cũng là "kiểm rồi ghi".** 📎 Business Logic Security CS liệt kê đúng mẫu "kiểm người dùng có ít hơn N mục, rồi thêm một". Đếm số bản ghi trong ngày rồi mới `save()` thì hai request song song cùng qua bước đếm. 🔧 Cách làm trong Magento: khoá theo người dùng quanh bước đếm và ghi, `LockManagerInterface::lock('vendor_claim_' . $customerId, 5)` … `unlock()` trong `finally`; không lấy được khoá thì từ chối (`429`). Hoặc giữ một dòng đếm theo (người dùng, ngày) và tăng bằng update có điều kiện `count < N` như ví dụ trên.

**Kiểm:** đọc mọi chỗ "đọc, `if`, rồi ghi" trên bảng custom chứa số lượng, số dư, trạng thái dùng, **và mọi giới hạn số lần theo người dùng hoặc theo thời gian**.

**Nguồn:** [Business Logic Security → Prevent Race Conditions](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html)

### M2-A06-05 — Module thanh toán: xác minh với cổng ở server, khớp `getGrandTotal()` và tiền tệ, xử lý một lần
**Mức:** 🔴 · cụ thể hoá `G-A06-07`

**✅ Đúng:** 📎 theo Third Party Payment Gateway Integration CS, áp vào controller "quay về" và controller nhận IPN/callback:
- Controller "quay về" không tạo invoice hay đổi trạng thái đơn dựa trên tham số URL. Nó chỉ hiển thị, hoặc gọi API của cổng để xác minh.
- Callback: kiểm chữ ký (`M2-A08-03`), rồi gọi API của cổng lấy trạng thái giao dịch.
- So số tiền và tiền tệ với đúng loại tiền mà module gửi sang cổng: tiền của đơn là `$order->getGrandTotal()` và `getOrderCurrencyCode()` (`module-sales/Model/Order.php:3002`, `:3072`); tiền gốc là `getBaseGrandTotal()` và `getBaseCurrencyCode()`. Hai loại khác nhau khi store hiển thị khác tiền gốc (`Order.php:1859`). So cả mã đơn.
- **Gắn giao dịch với đơn:** 🔧 lưu mã giao dịch hoặc session của cổng vào payment của đơn ngay lúc chuyển khách sang cổng. Callback và kết quả API phải khớp mã đã lưu. Không khớp thì không invoice: chuyển đơn sang `payment_review` và cảnh báo.
- 🔧 So tiền bằng số nguyên theo đơn vị nhỏ nhất của tiền tệ (cent), không so `float`.
- Xử lý một lần: trước khi tạo invoice, kiểm `$order->canInvoice()` (`Order.php:668`) và mã giao dịch đã lưu chưa. `[CODE]` Method `getByTransactionId($transactionId, $paymentId, $orderId)` có ở class `Magento\Sales\Model\Order\Payment\Transaction\Repository` (`Repository.php:167`), **không** có trên `TransactionRepositoryInterface`; inject class cụ thể hoặc kiểm `$payment->getLastTransId()`. Method này chỉ tìm trong một payment; muốn chặn một mã giao dịch bị dùng lại cho đơn khác thì 🔧 lưu mã giao dịch vào bảng của module với unique index.
- Hai callback đến cùng lúc: khoá theo mã đơn bằng `LockManagerInterface`. `[CODE]` Với lock backend mặc định là database, `lock()` mặc định `$timeout = -1`, tức chờ tới `MAX_LOCK_TIME` = 604800 giây = **1 tuần** (`framework/Lock/Backend/Database.php:28`, `:75`, `:84`). Luôn truyền timeout ngắn và kiểm giá trị `bool` trả về; `unlock()` trong `finally`. 📎 Webhook Security CS dùng `429` + `Retry-After` để trả lời lưu lượng vượt mức (mục Rate Limiting). 🔧 Team dùng cùng mã khi chưa lấy được khoá để cổng gửi lại; `503` cũng được nếu cổng retry với mã này.
```php
if (!$this->lockManager->lock('acmepay_order_' . $orderId, 15)) {
    return $result->setHttpResponseCode(429)->setHeader('Retry-After', '30');
}
try {
    // xác minh, invoice
} finally {
    $this->lockManager->unlock('acmepay_order_' . $orderId);
}
```
- Trang "quay về": khách vãng lai không qua được `canView()` (`M2-A01-05`); lấy đơn từ checkout session. 🔧 Không ghi gì vào DB ở request GET này; muốn khôi phục giỏ hàng khi khách huỷ thì làm ở một bước POST riêng.
- Log mọi callback, không log dữ liệu thẻ (`M2-A09-02`).

🔧 Nếu module thanh toán là của bên thứ ba thì rule này dùng để **review** module đó, không có nghĩa là phải sửa trong `vendor/`.

**Kiểm:** chỉ ra trong code: dòng gọi API xác minh, dòng so số tiền, dòng chặn xử lý lặp.

**Nguồn:** [Secure Integration of Third-Party Payment Gateways](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Payment_Gateway_Integration_Cheat_Sheet.html) · [Webhook Security](https://cheatsheetseries.owasp.org/cheatsheets/Webhook_Security_Cheat_Sheet.html)

---

## A07 — Authentication Failures (xác thực yếu)

📎 OWASP: ưu tiên hệ thống xác thực có sẵn đã được kiểm chứng; không có tài khoản mặc định; thông báo giống nhau cho mọi kết quả đăng nhập; đổi session ID sau khi đăng nhập.

### M2-A07-01 — Không tự viết đăng nhập, session, reset password
**Mức:** 🔴 · **Cụ thể hoá:** G-A07-01

**Vì sao:** luồng có sẵn của Magento đã xử lý khoá tài khoản khi sai nhiều lần, đổi session ID, hết hạn token reset. Viết lại gần như chắc chắn thiếu một trong các phần đó.

**❌ Sai**
```php
$customer = $this->customerFactory->create()->loadByEmail($email);
$this->customerSession->setCustomerAsLoggedIn($customer);
```
(đăng nhập thẳng mà không kiểm mật khẩu, thường gặp ở tính năng "login as customer" hoặc SSO tự viết)

**✅ Đúng:** đăng nhập qua `Magento\Customer\Api\AccountManagementInterface::authenticate()`; reset mật khẩu qua `initiatePasswordReset()`. Tính năng đăng nhập thay hoặc SSO cần review bảo mật riêng trước khi code.

**Kiểm:** `grep -rn "setCustomerAsLoggedIn\|setCustomerDataAsLoggedIn\|loginById" app/code --include=*.php`

### M2-A07-02 — Không hardcode tài khoản, mật khẩu, API key
**Mức:** 🔴 · **Cụ thể hoá:** G-A07-02

**Vì sao:** secret trong code nằm mãi trong lịch sử git và đi theo mọi bản copy của repo. Data patch tạo admin với mật khẩu cố định là tài khoản mặc định trên mọi môi trường.

**❌ Sai**
```php
private const API_KEY = 'sk_live_9f8a7b6c5d4e3f2a1b0c';
```

**✅ Đúng:** lưu trong system config đã mã hoá (`M2-A04-03`) hoặc `env.php`. Không tạo tài khoản admin hay customer thật bằng patch.

**Kiểm:** `grep -rnEi "(api_?key|secret|password|token)\W{1,6}['\"][A-Za-z0-9_\-]{12,}['\"]" app/code --include=*.php --include=*.xml`

### M2-A07-03 — Thông báo lỗi không tiết lộ tài khoản có tồn tại hay không
**Mức:** 🟠 · **Cụ thể hoá:** G-A07-03

**Vì sao:** "Email này chưa đăng ký" và "Sai mật khẩu" cho phép dò ra danh sách email khách hàng.

**✅ Đúng:** một thông báo chung cho mọi trường hợp thất bại, ví dụ "Thông tin đăng nhập không đúng" hoặc "Nếu email tồn tại, chúng tôi đã gửi hướng dẫn". Áp dụng cho cả endpoint AJAX kiểm tra email, form đăng ký B2B, form quên mật khẩu custom.

**Kiểm:** đọc mọi chỗ trả kết quả sau khi tra cứu customer theo email.

### M2-A07-04 — Đăng nhập custom đi qua `setCustomerDataAsLoggedIn()`; đổi mật khẩu dùng `changePassword()`
**Mức:** 🟠 · cụ thể hoá `G-A07-04`

**❌ Sai:** đăng nhập bằng mạng xã hội hoặc "magic link" mà gán thẳng `$customerSession->setCustomerId($id)`.

**✅ Đúng:** `$customerSession->setCustomerDataAsLoggedIn($customer)`. `[CODE]` Method này gọi `regenerateId()` để sinh session ID mới (`module-customer/Model/Session.php:452`). Đổi mật khẩu dùng `AccountManagementInterface::changePassword($email, $currentPassword, $newPassword)` (`module-customer/Api/AccountManagementInterface.php:120`), method này bắt buộc có mật khẩu hiện tại. 📎 Đăng nhập bằng OIDC: định danh bằng cặp `iss` + `sub`, không tự liên kết tài khoản chỉ vì email trùng (Authentication CS).

**Kiểm:** `grep -rn "setCustomerId(" app/code` trong code đăng nhập.

**Nguồn:** [Session Management → Renew the Session ID](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) · [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

### M2-A07-05 — (nếu tự kiểm JWT) `JwtManagerInterface::read()` với một thuật toán; tự kiểm `exp`, `iss`, `aud`
**Mức:** 🔴 khi code tự kiểm JWT (đưa token không ký vào danh sách là lỗi bỏ qua xác thực) · cụ thể hoá `G-A07-05`

`[CODE]` `Magento\Framework\Jwt\JwtManagerInterface::read(string $token, array $acceptableEncryption)` (`framework/Jwt/JwtManagerInterface.php:36`): truyền **chỉ** thuật toán mà mình phát hành, **không bao giờ** đưa `Magento\Framework\Jwt\Unsecured\NoEncryption` vào danh sách này (adapter có nhánh riêng cho JWT không ký; `read()` bắt đầu ở `module-jwt-framework-adapter/Model/JwtManager.php:130`, và ở `:183-189`, `NoEncryption` cùng các setting khác JWS/JWE có thuật toán `none` được đọc như JWT không ký, nên cũng không dùng `Jwk::ALGORITHM_NONE`). Key HS256 tạo bằng `JwkFactory::createHs256($secret)` (`framework/Jwt/JwkFactory.php:73`); secret lưu ở field config mã hoá (`M2-A04-03`). `[RUN]` grep trong `module-jwt-framework-adapter` không thấy chỗ kiểm claim; module token của core tự đọc `exp` (`module-jwt-user-token/Model/Reader.php:89-92`). Vì vậy code custom phải tự kiểm `exp`, `iss`, `aud` theo `G-A07-05`. Chưa chạy thử để xác nhận hành vi `read()` với token hết hạn.

**Nguồn:** [JSON Web Token](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html)

---

## A08 — Software or Data Integrity Failures (không kiểm tra tính toàn vẹn)

📎 OWASP: không tin dữ liệu serialize từ nguồn không tin cậy; kiểm chữ ký; chỉ dùng nguồn code tin cậy.

### M2-A08-01 — Không dùng `unserialize()` của PHP
**Mức:** 🔴 · **Cụ thể hoá:** G-A08-01

**Vì sao:** `unserialize()` dựng lại object PHP và tự gọi các magic method. Dữ liệu do người dùng tác động được (cookie, tham số, cột database ghi từ request) có thể dẫn tới chạy mã tuỳ ý.

**❌ Sai**
```php
$value = unserialize($buyRequest['value']);
```

**✅ Đúng**
```php
$value = $this->jsonSerializer->unserialize($buyRequest['value']);
```
`Magento\Framework\Serialize\Serializer\Json`. Dữ liệu cũ đang lưu dạng serialize thì chuyển sang JSON bằng data patch.

**Kiểm:** `grep -rnE "[^>:a-zA-Z_]unserialize\(" app/code --include=*.php`

### M2-A08-02 — Không đổ nguyên request vào model
**Mức:** 🔴 · **Cụ thể hoá:** G-A08-02

**Vì sao:** `setData($request->getParams())` cho phép client gán cả những field không có trên form, ví dụ `customer_id`, `status`, `is_approved`, `entity_id`. Lỗi này gọi là mass assignment.

**❌ Sai**
```php
$model->setData($this->getRequest()->getPostValue())->save();
```

**✅ Đúng**
```php
$model->setTitle((string)$request->getParam('title'));
$model->setNote((string)$request->getParam('note'));
$model->setCustomerId((int)$this->customerSession->getCustomerId());
$this->repository->save($model);
```

📎 Adobe khuyên dùng DTO riêng cho từng thao tác với danh sách property chặt, và coi cách lưu trực tiếp qua `AbstractModel` kiểu cũ là dễ dính lỗi này.

**Kiểm:** `grep -rnE "(setData|addData)\(\s*\\$(this->getRequest\(\)|request)->(getParams|getPostValue|getPost)\(\)" app/code`

### M2-A08-03 — Webhook kiểm chữ ký, chống gửi lại, xử lý một lần
**Mức:** 🔴 · **Cụ thể hoá:** G-A08-03

**Vì sao:** endpoint nhận callback từ cổng thanh toán hay ERP là public; không kiểm chữ ký thì ai cũng gửi được "đơn đã thanh toán".

**✅ Đúng**
```php
$expected = hash_hmac('sha256', $request->getContent(), $this->config->getWebhookSecret());
if (!Security::compareStrings($expected, (string)$request->getHeader('X-Signature'))) {
    return $this->rawResultFactory->create()->setHttpResponseCode(401)->setContents('');
}
```
📎 Chữ ký đúng chưa đủ (Webhook Security CS):
- Lưu event ID hoặc mã giao dịch đã xử lý vào bảng có unique index; gặp lại thì trả `200` mà không chạy lại.
- Bên gửi có timestamp trong phần được ký thì từ chối nếu lệch quá một khoảng nhỏ (thư viện Stripe mặc định 5 phút).
- 📎 Mã trả về theo Webhook Security CS: `200` chỉ sau khi đã lưu hoặc xử lý xong, kể cả khi là lần lặp; `400` payload sai định dạng; `401` chữ ký sai, body chung chung không nêu lý do (🔧 ví dụ trên để rỗng); `400` hoặc `413` khi payload quá lớn; 📎 `429` + `Retry-After` khi lưu lượng vượt mức; 🔧 dùng cùng mã khi chưa xử lý được (ví dụ chưa lấy được khoá). 🔧 Ghi event ID trong cùng transaction với invoice; sự kiện hợp lệ nhưng bỏ qua (loại không xử lý, đơn không tồn tại) trả `200` và log.
- Mỗi tích hợp một secret riêng. 📎 Secret để trong nơi lưu secret, không hardcode trong source hay file cấu hình. 🔧 Với Magento, tối thiểu là field config `obscure` được mã hoá (`M2-A04-03`); có secrets manager thì dùng nó.
- Nhận nhanh rồi xử lý qua message queue nếu việc nặng. 📎 Webhook CS: trả lời nhanh, xử lý qua queue (GitHub đòi `2xx` trong 10 giây). 🔧 "Việc nặng" xem `M2-A06-03`.
- 📎 Callback chữ ký sai là lỗi xác thực, luôn log (Logging CS). Log thời gian, IP, method, status, event ID, loại sự kiện, độ trễ; **không** log toàn bộ body, secret hay header chữ ký (Webhook CS "Logging and Monitoring").

**Kiểm:** mọi controller implement `CsrfAwareActionInterface` phải có đoạn kiểm chữ ký và đoạn chặn xử lý lặp.

**Nguồn:** [Webhook Security](https://cheatsheetseries.owasp.org/cheatsheets/Webhook_Security_Cheat_Sheet.html)

### M2-A08-04 — Script bên thứ ba tự host hoặc có SRI
**Mức:** 🟠 · **Cụ thể hoá:** G-A08-04

**Vì sao:** script tải từ CDN mà CDN bị chiếm thì mã độc chạy trên trang checkout.

**✅ Đúng:** ưu tiên đưa script vào module và phục vụ qua static content; buộc phải dùng CDN thì thêm thuộc tính `integrity` và `crossorigin`. [Adobe] hash tính bằng `base64_encode(hash('sha256', $content, true))`.

Ghi chú version [Adobe release notes, chưa kiểm trên source các bản đó]: SRI tự động cho JS của trang thanh toán được thêm từ bản 2.4.6-p6 và 2.4.7 (yêu cầu của PCI DSS 4.0); 2.4.6-p4 không có class `Magento\Csp\Block\Sri\Hashes`.

**Kiểm:** `grep -rn "src=[\"']https\?://" app/code --include=*.phtml --include=*.xml`

**Nguồn:** [Third Party JavaScript Management](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Javascript_Management_Cheat_Sheet.html)

---

## A09 — Security Logging and Alerting Failures (thiếu log và cảnh báo)

📎 OWASP: log đăng nhập thất bại, lỗi phân quyền, lỗi validate kèm ngữ cảnh người dùng; không log dữ liệu nhạy cảm; chống chèn dữ liệu vào log.

### M2-A09-01 — Log sự kiện bảo mật qua `Psr\Log\LoggerInterface`
**Mức:** 🟠 · **Cụ thể hoá:** G-A09-01

**Vì sao:** không có log thì không biết mình bị tấn công, và sau sự cố không dựng lại được chuyện gì đã xảy ra.

**✅ Đúng**
```php
$this->logger->warning('Attachment access denied', [
    'attachment_id' => (int)$attachmentId,
    'customer_id' => (int)$this->customerSession->getCustomerId(),
    'ip' => $this->remoteAddress->getRemoteAddress(),
]);
```
Cần log (📎 Logging CS, mục "Which events to log"): bị từ chối quyền, lỗi validate đầu vào ở phía server, lỗi session hoặc JWT, thao tác quản trị user và đổi quyền, import/export dữ liệu, upload file, hành vi nghiệp vụ đáng ngờ (sai thứ tự bước, vượt giới hạn). 🔧 Team thêm: chữ ký webhook sai, thay đổi cấu hình nhạy cảm, xoá hàng loạt của admin.

`[CODE]` IP lấy qua `Magento\Framework\HTTP\PhpEnvironment\RemoteAddress::getRemoteAddress()`. Nếu `RemoteAddress` được cấu hình `alternativeHeaders` (ví dụ `HTTP_X_FORWARDED_FOR`) thì nó đọc header đó trước (`RemoteAddress.php:62-74`). ⚠️ Nếu không cấu hình thêm `trustedProxies`, nó lấy IP **bên trái nhất** của danh sách, tức giá trị client tự đặt được (`RemoteAddress.php:98-107`). Cấu hình cả `alternativeHeaders` lẫn `trustedProxies` trong `di.xml`. 📎 Chỉ dùng header forwarded khi proxy của mình đặt header đó và xoá bản do client gửi (Input Validation CS). Mỗi dòng trả lời được: khi nào, ai, làm gì, trên đối tượng nào. Dữ liệu biến đổi đưa vào mảng context, không ghép vào chuỗi message, để tránh chèn dòng log giả.

**Kiểm:** mỗi nhánh từ chối trong các rule A01 có một dòng log.

### M2-A09-02 — Log không chứa mật khẩu, token, session ID, dữ liệu thẻ
**Mức:** 🔴 · **Cụ thể hoá:** G-A09-02

**Vì sao:** file log thường được chia sẻ rộng hơn database (gửi cho vendor, đính kèm ticket) và ít được bảo vệ hơn.

**❌ Sai**
```php
$this->logger->debug('API request', ['headers' => $headers, 'body' => $request->getContent()]);
```

**✅ Đúng:** log định danh và kết quả, không log nguyên payload. Phải log payload để debug tích hợp thì lọc các field `password`, `token`, `authorization`, `api_key`, `session_id`, `cc_number`, `cvv` trước khi ghi, và có config để tắt.

**Kiểm:** đọc mọi lời gọi logger có truyền `getContent()`, `getParams()`, `getPostValue()`, header, hoặc object request/response.

### M2-A09-03 — Không còn `var_dump`, `print_r`, file log tự tạo trong `pub/`
**Mức:** 🔴 · **Cụ thể hoá:** G-A09-03

**Vì sao:** output debug lộ cấu trúc dữ liệu ra trình duyệt. File log tự ghi vào `pub/` hoặc `pub/media/` tải về được từ internet.

**❌ Sai**
```php
file_put_contents(BP . '/pub/media/debug.log', print_r($data, true), FILE_APPEND);
```

**✅ Đúng:** dùng logger; file log nằm trong `var/log/`.

**Kiểm:** `grep -rnE "\b(var_dump|print_r|var_export|die|exit)\(|file_put_contents\(" app/code --include=*.php --include=*.phtml`

---

## A10 — Mishandling of Exceptional Conditions (xử lý tình huống bất thường kém)

📎 OWASP (nhóm mới của bản 2025): bắt lỗi tại nơi xảy ra; khi lỗi thì rollback và từ chối (fail closed); không để lộ chi tiết lỗi; có handler chung làm lớp chặn cuối.

### M2-A10-01 — Không có `catch` rỗng, không dùng `@`
**Mức:** 🔴 · **Cụ thể hoá:** G-A10-01

**Vì sao:** nuốt lỗi làm code chạy tiếp với trạng thái sai. Nếu đoạn bị nuốt là bước kiểm tra, hệ thống mặc nhiên cho qua.

**❌ Sai**
```php
try {
    $this->validator->validate($address);
} catch (\Exception $e) {
}

$value = @unserialize($raw);
```
Một biến thể khó thấy: `catch (Exception $e)` trong file có `namespace` mà thiếu dấu `\` và không `use Exception`. PHP hiểu là `Vendor\Module\…\Exception`, class này không tồn tại nên khối catch không bao giờ chạy.

**✅ Đúng**
```php
try {
    $this->validator->validate($address);
} catch (LocalizedException $e) {
    $this->logger->warning('Address validation failed', ['exception' => $e]);
    throw $e;
}
```
Chỉ bắt loại exception mình xử lý được. Bắt rồi thì hoặc xử lý, hoặc log và ném lại. 🔧 Cron hay consumer xử lý nhiều phần tử: được bắt `\Exception` **cho từng phần tử**, log, đánh dấu phần tử đó lỗi rồi chạy tiếp, để một phần tử hỏng không chặn cả lô.

**Kiểm:** `grep -rnE "catch \(Exception |@[a-z_]+\(" app/code --include=*.php` (thiếu dấu `\` đầu); `catch` rỗng: `grep -rlPz 'catch\s*\([^)]*\)\s*\{\s*\}' app/code --include=*.php`; đọc mọi khối `catch` chỉ có 0–1 dòng.

### M2-A10-02 — Không trả message exception gốc cho người dùng
**Mức:** 🔴 · **Cụ thể hoá:** G-A10-02

**Vì sao:** message của `\Exception` chung có thể chứa câu SQL, đường dẫn file, tên host nội bộ. Chỉ `LocalizedException` là message được viết cho người dùng đọc.

**❌ Sai**
```php
} catch (\Exception $e) {
    return $resultJson->setData(['success' => false, 'error' => $e->getMessage()]);
}
```

**✅ Đúng**
```php
} catch (LocalizedException $e) {
    return $resultJson->setData(['success' => false, 'error' => $e->getMessage()]);
} catch (\Exception $e) {
    $this->logger->critical($e);
    return $resultJson->setData(['success' => false, 'error' => __('Something went wrong. Please try again.')]);
}
```

**Kiểm:** `grep -rnE "(addErrorMessage|addError|setData|__)\(.*\\\$e->getMessage\(\)" app/code --include=*.php` rồi xem loại exception đang bắt.

### M2-A10-03 — Ghi nhiều bảng thì dùng transaction
**Mức:** 🟠 · **Cụ thể hoá:** G-A10-03

**Vì sao:** lỗi giữa chừng để lại dữ liệu nửa vời: đã trừ điểm thưởng nhưng chưa tạo đơn, đã đổi trạng thái nhưng chưa ghi lịch sử. 📎 OWASP gọi yêu cầu này là fail closed.

**✅ Đúng**
```php
$connection->beginTransaction();
try {
    $this->balanceResource->save($balance);
    $this->historyResource->save($history);
    $connection->commit();
} catch (\Exception $e) {
    $connection->rollBack();
    throw $e;
}
```
Lưu qua resource model của Magento đã có transaction cho từng model; rule này dành cho thao tác trải trên nhiều model hoặc SQL trực tiếp. Gọi API ngoài không rollback được, nên đặt sau khi commit hoặc thiết kế cho phép chạy lại. 🔧 Không được mất việc (email báo tiền đã chuyển, đồng bộ ERP): ghi một dòng vào bảng outbox của module trong cùng transaction, cron đọc bảng, "nhận" dòng bằng update có điều kiện, gửi, đánh dấu xong hoặc tăng số lần thử (xem `G-A10-03`).

**Kiểm:** tìm method có từ hai lệnh `save()`, `delete()`, `insert`, `update` trở lên lên các bảng khác nhau.

### M2-A10-04 — Kiểm kết quả `load()` bằng `getId()`
**Mức:** 🔴 · **Cụ thể hoá:** G-A10-04

**Vì sao:** `$factory->create()->load($id)` luôn trả về object, kể cả khi không tìm thấy bản ghi. Kiểm `if (!$model)` không bao giờ đúng, nên code chạy tiếp với một model rỗng.

**❌ Sai**
```php
if (!($log = $this->logFactory->create()->load($id))) {
    return $this->redirectWithError();
}
$log->delete();
```

**✅ Đúng**
```php
$log = $this->logFactory->create()->load($id);
if (!$log->getId()) {
    return $this->redirectWithError();
}
```
Tốt hơn: dùng repository `getById()`, method này ném `NoSuchEntityException` khi không có bản ghi.

**Kiểm:** `grep -rnE "if \(!\(?\\$\w+ = .*->load\(" app/code --include=*.php`

---

## Phần B — Khi dùng AI để viết code

Áp dụng toàn bộ Phần B của [bản chung](../general/owasp-rules.md) (`G-AI-01…08`). Riêng cho Magento:

### M2-AI-05 — `app/etc/env.php` và dump database nằm ngoài tầm đọc của công cụ AI
**Mức:** 🔴 · cụ thể hoá `G-AI-05`

`app/etc/env.php` chứa thông tin kết nối database và **key mã hoá** của Magento (mục `crypt` → `key`), dùng để giải mã mọi giá trị config đã mã hoá (`M2-A04-03`). 📎 Secure Coding with AI §9: công cụ AI gửi context tới nhà cung cấp model, và `.gitignore` không ngăn AI đọc file.
- Thêm vào danh sách loại trừ của công cụ: `app/etc/env.php`, `auth.json` (chứa credential của `repo.magento.com`), file dump database (`*.sql`, `*.sql.gz`).
- Không mở `env.php` trong IDE khi AI assistant đang bật.
- Không dán output `bin/magento config:show` có giá trị nhạy cảm vào chat.

**Nguồn:** [Secure Coding with AI §9](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html)

---

## Phụ lục A — Kiểm tự động

Dự án Magento có sẵn `magento/magento-coding-standard`. Chạy riêng nhóm Security:

```bash
vendor/bin/phpcs --standard=Magento2 \
  --sniffs=Magento2.Security.XssTemplate,Magento2.Security.InsecureFunction,Magento2.Security.Superglobal,Magento2.Security.IncludeFile,Magento2.Security.LanguageConstruct \
  app/code/Vendor/Module
```

Sniff `InsecureFunction` của bản đi kèm 2.4.6-p4 cấm: `assert`, `create_function`, `exec`, `md5`, `passthru`, `pcntl_exec`, `popen`, `proc_open`, `serialize`, `shell_exec`, `system`, `unserialize`, `srand`, `mt_srand`, `mt_rand`, `eval`.

Công cụ này bắt được phần lớn A05 và một phần A04, A08. Nó **không** bắt được A01, A06, A07, A10; các nhóm đó phải review bằng người.

## Phụ lục B — Ngoài phạm vi coding rule

Các điểm OWASP nêu nhưng thuộc hạ tầng hoặc quy trình, không kiểm được qua review code. Dev cần biết để nêu câu hỏi đúng người:

| OWASP | Việc | Thường thuộc về |
|---|---|---|
| A02 | Production mode, tắt directory listing, security header ở web server, đổi URL admin, bật 2FA admin | DevOps / hosting |
| A02 | Phân quyền storage, tách môi trường, credential khác nhau giữa các môi trường | DevOps |
| A03 | Danh mục thành phần (SBOM), theo dõi CVE, lịch nâng security patch Magento | Tech lead |
| A03, A08 | Bảo vệ CI/CD, phân quyền repo, MFA cho tài khoản dev, review bắt buộc trước khi merge | Tech lead / DevOps |
| A04 | TLS 1.2 trở lên, HSTS, quản lý và xoay vòng key | DevOps / hosting |
| A07 | Chính sách mật khẩu, khoá tài khoản, MFA cho admin (cấu hình Magento) | Admin dự án |
| A09 | Gom log tập trung, cảnh báo, quy trình ứng phó sự cố | DevOps / vận hành |
| A10 | Giới hạn tài nguyên, rate limit ở tầng web server/WAF, stress test | DevOps |

## Phụ lục C — Bảng đối chiếu OWASP Top 10 2025 và 2021

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

## Phụ lục D — Nguồn của từng rule

📎 Nội dung rule lấy từ OWASP Top 10:2025 và OWASP Cheat Sheet Series, đọc ngày 2026-11-17 (repo nguồn `OWASP/Top10` commit 3a31f35, `OWASP/CheatSheetSeries` commit 7af0ef1). Cột cuối chỉ là nơi lấy **tên API Magento**: "source" là `vendor/magento` của dự án 2.4.6-p4; "Adobe" là trang Security cho PHP extension tại https://developer.adobe.com/commerce/php/development/security/ (đọc 2026-11-16). Cột nhóm theo danh sách CWE của Top 10:2025; chữ **đậm** là nhóm khác với mã rule.

| Rule | Nhóm 2025 | 📎 OWASP | Tên API Magento lấy từ |
|---|---|---|---|
| M2-A01-01, 02, 03, 04, 08 | A01 | [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) | Adobe: Authorization |
| M2-A01-05 | A01 | [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) · [IDOR Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html) | Adobe: Authorization |
| M2-A01-06 | A01 | [CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html) | Adobe: Cross-site request forgery |
| M2-A01-07 | A01 | [SSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html) | Adobe: Server-side request forgery |
| M2-A01-09 | A01 | [Unvalidated Redirects and Forwards](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html) | source `module-store/App/Response/Redirect.php` |
| M2-A01-10 | A01 | [Authorization](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) | source `module-customer/Controller/Plugin/Account.php`, `etc/frontend/di.xml` |
| M2-A02-01, 02 | A02 | Top 10 A02 | — |
| M2-A02-03 | A02 | [Content Security Policy](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html) | Adobe: Content security policies |
| M2-A02-04 | A02 | [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) | source `framework/Stdlib/Cookie/` |
| M2-A02-05 | A02 | [XXE Prevention](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html) | source `framework/Xml/Security.php` |
| M2-A03-01, 02 | A03 | [Vulnerable Dependency Management](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html) | Adobe release notes 2.4.6 |
| M2-A04-01 | A04 | [Password Storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) | Adobe: Non-secure functions, Sensitive information |
| M2-A04-02 | A04 | [Cryptographic Storage](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html) | Adobe: Brute force attacks |
| M2-A04-03 | A04 · A06 (CWE-311) | [Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html) | Adobe: Sensitive information |
| M2-A04-04 | **A07** (CWE-295) | [Transport Layer Security](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html) | — |
| M2-A04-05 | A04 | [Web Cache Security](https://cheatsheetseries.owasp.org/cheatsheets/Web_Cache_Security_Cheat_Sheet.html) | source `module-page-cache/`, `framework/App/PageCache/Kernel.php` |
| M2-A05-01 | A05 | [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) | source `Magento\Framework\DB` |
| M2-A05-02, 03 | A05 | [XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html) | Adobe: Cross-site scripting |
| M2-A05-04 | A05 | [OS Command Injection Defense](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html) | Adobe: Non-secure functions · sniff `Magento2.Security.InsecureFunction` |
| M2-A05-05 | **A06** (CWE-434) · **A01** (CWE-22) | [File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html) · [Path Traversal Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Path_Traversal_Prevention_Cheat_Sheet.html) | Adobe: File uploads |
| M2-A05-06 | A05 | [SSTI Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Template_Injection_Prevention_Cheat_Sheet.html) | source `module-email/Model/Template/Filter.php` |
| M2-A05-07 | A05 | [Input Validation](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html) | source `framework/HTTP/PhpEnvironment/Request.php` |
| M2-A06-01 | A06 | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) | — |
| M2-A06-02 | A06 | [Credential Stuffing Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Credential_Stuffing_Prevention_Cheat_Sheet.html) · [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) | Adobe: Brute force attacks |
| M2-A06-03 | X01 · A10 | [Denial of Service](https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html) · [GraphQL](https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html) | Adobe: Denial of service (DoS) attacks |
| M2-A06-04 | A06 (CWE-362) | [Business Logic Security](https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html) | source `framework/DB/`, `framework/Lock/` |
| M2-A06-05 | A06 | [Secure Integration of Third-Party Payment Gateways](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Payment_Gateway_Integration_Cheat_Sheet.html) | source `module-sales/Model/Order.php` |
| M2-A07-01, 02, 03 | A07 | [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) · [Forgot Password](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html) | — |
| M2-A07-04 | A07 (CWE-384, CWE-620) | [Session Management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) · [Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) | source `module-customer/Model/Session.php`, `Api/AccountManagementInterface.php` |
| M2-A07-05 | A07 | [JSON Web Token](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html) | source `framework/Jwt/`, `module-jwt-user-token/` |
| M2-A08-01 | A08 | [Deserialization](https://cheatsheetseries.owasp.org/cheatsheets/Deserialization_Cheat_Sheet.html) | Adobe: Non-secure functions |
| M2-A08-02 | A08 | [Mass Assignment](https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html) | Adobe: Mass assignment |
| M2-A08-03 | A08 · A04 (CWE-347) | [Webhook Security](https://cheatsheetseries.owasp.org/cheatsheets/Webhook_Security_Cheat_Sheet.html) | source `module-sales/`, `framework/Lock/` |
| M2-A08-04 | A08 (CWE-830) | [Third Party JavaScript Management](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Javascript_Management_Cheat_Sheet.html) | Adobe: Subresource integrity |
| M2-A09-01, 02, 03 | A09 (03: **A02**, **A10**) | [Logging](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) · [Input Validation](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html) (01: header forwarded) | source `framework/HTTP/PhpEnvironment/RemoteAddress.php` |
| M2-A10-01, 02, 03, 04 | A10 | [Error Handling](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html) | — |
| M2-AI-05 | X03 | [Secure Coding with AI §9](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Coding_with_AI_Cheat_Sheet.html) | `app/etc/env.php` của dự án |

## Lịch sử cập nhật
- 2026-11-16: bản nháp đầu tiên.
- 2026-11-16: bản đề xuất cuối sau khi đối chiếu với tài liệu Adobe Commerce và OWASP Cheat Sheet. Thêm `M2-A01-08`, `M2-A06-03`; viết lại `M2-A05-05` (bản nháp lưu file riêng tư vào media, trái với hướng dẫn của Adobe); bổ sung `M2-A01-05`, `M2-A01-07`, `M2-A02-03`, `M2-A03-02`, `M2-A04-02`, `M2-A05-02`, `M2-A05-03`, `M2-A06-02`, `M2-A08-02`, `M2-A08-03`, `M2-A09-01`, `M2-A09-02`; thêm Phụ lục D.
- 2026-11-17: **v2** sau research đợt 2 (chỉ Top 10:2025 và Cheat Sheet Series). Thêm `M2-A01-09`, `M2-A02-04`, `M2-A02-05`, `M2-A04-05`, `M2-A05-06`, `M2-A05-07`, `M2-A06-04`, `M2-A06-05`, `M2-A07-04`, `M2-A07-05`, Phần B (`M2-AI-05`). Bổ sung `M2-A08-03` (chống gửi lại, xử lý một lần). Viết lại Phụ lục D: tách nguồn nội dung (OWASP) khỏi nguồn tên API (source, Adobe).
- 2026-11-17: **v2.1** sau vòng giả lập 1 (kiểm chứng nguồn, AI agent Magento, AI agent Python, dev mới). Thêm `M2-A01-10` (controller frontend cần đăng nhập, bẫy tên action). Tách `M2-A08-04` (SRI) khỏi `M2-A08-03`. Sửa ví dụ cookie gây lỗi fatal (`M2-A02-04`), ví dụ webhook trả message; thêm cảnh báo `canView()` với trang quay về, `lock()` mặc định chờ 1 tuần, `Curl` mặc định 300 giây và cho FTP, `setAllowedExtensions([])` cho mọi đuôi, `{{base_url}}` lấy từ request, `NoEncryption`, `JsonHexTag`, entity loader dùng chung cả tiến trình. Sửa 3 lệnh grep bỏ sót lỗi. Checklist có mức, có mục rule chung không có bản M2; thêm mục lục và ký hiệu. Nhật ký: `../../discussion/03-simulation-log.md`.
- 2026-11-17: **v2.3** sau vòng giả lập 2 và 3. **Đính chính** ví dụ upload ở `M2-A05-05` (bản trước gọi `getUploadedFileName()` trước `save()`, sai). Sửa tên tham số redirect (`referer_url`, `success_url`, `error_url`). Thêm: lệnh tìm bẫy tên action (`M2-A01-10`), `trustedProxies` của `RemoteAddress`, đăng ký và làm mới section của customer-data, `|raw` trong email, `AlreadyExistsException`, `Validator\Image` trả `true` với file không phải ảnh, reCAPTCHA cho controller custom, outbox + cron, giới hạn email theo customer ID (core SendFriend mặc định đếm theo cookie), trừ số dư, file từ thư mục SFTP, mã kiểu bearer lưu dạng hash. `M2-A07-05` nâng lên 🔴. Tự kiểm của file AI có 17 lệnh (16 grep/find + phpcs); các lệnh grep/find đã chạy thử trên hai PR mẫu.
- 2026-11-18: **v2.4** sau vòng kiểm chứng riêng cho phần sửa của v2.3 và research nốt các mục ❓. **Đính chính** `M2-A05-06`: `{{var}}` chỉ escape mặc định khi không có modifier; `{{var x|nl2br}}` cũng không escape (bản trước chỉ cảnh báo `|raw`); đổi lệnh kiểm tương ứng. Sửa số dòng `success_url`/`error_url`; 401 webhook là "body chung chung" (📎), để rỗng là 🔧; thêm số dòng cho `Validator\Image`, ghi chú adapter ảnh mặc định là GD2, nhãn `[CODE]` cho observer reCAPTCHA; file AI đánh dấu controller public bằng marker trong code (khớp `G-A01-01`). Thêm từ research: endpoint cho integration và tách đối tác (`M2-A01-03`), `__disableTmpl` chỉ tự động một phần (`M2-A05-03`), `x-magento-init` không bắt buộc qua `renderTag()` (`M2-A02-03`), số giới hạn mặc định của core làm mốc (`M2-A06-02`), tiêu chí "việc nặng" (`M2-A06-03`, 🔧), `form_key` trên trang cache và redirect kèm message (`M2-A04-05`), log callback chữ ký sai (`M2-A08-03`). Bổ sung sau thí nghiệm D-12 (user duyệt thêm, 2026-11-18): secret config khai báo sensitive trong `TypePool` để `app:config:dump` không ghi vào `config.php` (`M2-A04-03`, `[CODE]`); giới hạn kích thước response gọi ra ngoài bằng callback tiến trình tải, vì `CURLOPT_MAXFILESIZE` không chặn response không có `Content-Length` (`M2-A01-07`, `[RUN]` trên libcurl 7.88.1); giới hạn số lần theo người dùng cũng phải chống request song song (`M2-A06-04`). Tự kiểm của file AI có 18 lệnh (17 grep/find + phpcs).
