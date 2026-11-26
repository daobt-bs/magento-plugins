#!/usr/bin/env bash
# Quét ứng viên vi phạm rule OWASP cho code Magento 2 (rule: references/magento2-rules.md).
# Kết quả là ỨNG VIÊN, không phải kết luận: người review phải đọc ngữ cảnh từng dòng.
#
# Usage: scan.sh <path> [<path> ...]      path = thư mục module hoặc file .php/.phtml/.xml
# Env:   MAX=40 số dòng tối đa hiển thị cho mỗi check (mặc định 40)
#        NO_PHPCS=1 bỏ qua phpcs
set -u
[ $# -ge 1 ] || { echo "Usage: $0 <path> [<path> ...]" >&2; exit 2; }

MAX="${MAX:-40}"
EXCL=(--exclude-dir=Test --exclude-dir=Tests --exclude-dir=vendor --exclude-dir=node_modules)
TOTAL=0

# report <rule> <mô tả> <nội dung>: in nếu có nội dung
report() {
  local rule="$1" desc="$2" out="$3"
  [ -n "$out" ] || return 0
  local n; n=$(printf '%s\n' "$out" | wc -l)
  TOTAL=$((TOTAL + n))
  echo "## [$rule] $desc  ($n hit)"
  printf '%s\n' "$out" | head -n "$MAX" | sed 's/^/   /'
  [ "$n" -gt "$MAX" ] && echo "   ... còn $((n - MAX)) dòng (tăng MAX để xem)"
  echo
}

# g <rule> <mô tả> <ERE> <glob...>: grep -n theo glob (ví dụ --include=*.php)
g() {
  local rule="$1" desc="$2" pat="$3"; shift 3
  report "$rule" "$desc" "$(grep -rnE "${EXCL[@]}" "$@" -e "$pat" "${PATHS[@]}" 2>/dev/null)"
}

PATHS=("$@")
for p in "${PATHS[@]}"; do [ -e "$p" ] || { echo "Không tìm thấy: $p" >&2; exit 2; }; done

echo "# Quét OWASP/Magento 2 — ${PATHS[*]}"
echo "# Mỗi hit là ứng viên cần đọc ngữ cảnh, chưa phải lỗi."
echo

# --- phpcs (nếu có) -----------------------------------------------------------
if [ -z "${NO_PHPCS:-}" ]; then
  PHPCS=""
  if [ -x vendor/bin/phpcs ]; then PHPCS="vendor/bin/phpcs"; elif command -v phpcs >/dev/null 2>&1; then PHPCS="phpcs"; fi
  if [ -n "$PHPCS" ]; then
    out=$($PHPCS --standard=Magento2 --report=emacs \
      --sniffs=Magento2.Security.XssTemplate,Magento2.Security.InsecureFunction,Magento2.Security.Superglobal,Magento2.Security.IncludeFile,Magento2.Security.LanguageConstruct \
      "${PATHS[@]}" 2>&1)
    report "M2-A05-02/04, A04-01, A08-01" "phpcs Magento2.Security" "$out"
  else
    echo "## phpcs: KHÔNG CHẠY (không tìm thấy phpcs). Báo rõ điều này trong kết quả review."
    echo
  fi
fi

# --- A01 phân quyền -------------------------------------------------------------
# Controller/Adminhtml thiếu ADMIN_RESOURCE/_isAllowed (class cha có thể đã khai: kiểm tra tay)
out=""
while IFS= read -r d; do
  out+="$(grep -rL "ADMIN_RESOURCE\|_isAllowed" "$d" --include=*.php 2>/dev/null)"$'\n'
done < <(find "${PATHS[@]}" -type d -path '*Controller/Adminhtml' 2>/dev/null)
report "M2-A01-01" "Controller admin không thấy ADMIN_RESOURCE/_isAllowed (kiểm class cha)" "$(printf '%s' "$out" | sed '/^$/d')"

g "M2-A01-02" "Controller Adminhtml không kế thừa Backend\\App\\Action (lọc thô)" \
  'class [A-Za-z_]+ extends .*Framework\\App\\Action\\Action' --include=*.php
g "M2-A01-03" "webapi.xml dùng anonymous" 'ref="anonymous"' --include=webapi.xml

# ui_component thiếu aclResource
out=""
while IFS= read -r d; do
  out+="$(grep -rL "aclResource" "$d" --include=*.xml 2>/dev/null)"$'\n'
done < <(find "${PATHS[@]}" -type d -path '*view/adminhtml/ui_component' 2>/dev/null)
report "M2-A01-08" "ui_component admin thiếu aclResource (file không có dataSource thì bỏ qua)" "$(printf '%s' "$out" | sed '/^$/d')"

g "M2-A01-06 / A04-04" "Tắt CSRF hoặc tắt kiểm TLS" 'validateForCsrf|SSL_VERIFYPEER|SSL_VERIFYHOST|verify_peer'
g "M2-A01-09 / A05-07 / A02-04 / A02-05 / A04-05" \
  "Redirect từ request, HTTP_HOST, setcookie, LIBXML_NOENT/DTDLOAD, setPublicHeaders" \
  'setUrl\(\s*\$this->(getRequest\(\)|_?request)|getHttpHost\(|HTTP_HOST|setcookie\(|LIBXML_NOENT|LIBXML_DTDLOAD|setPublicHeaders\('

# Bẫy tên action: file tên Create/Login/Confirm... có AccountInterface => KHÔNG bị bắt đăng nhập
out=$(find "${PATHS[@]}" -path '*Controller/*' -not -path '*Adminhtml*' \
  -iregex '.*/\(create\|login\|logoutsuccess\|forgotpassword\|forgotpasswordpost\|resetpassword\|resetpasswordpost\|confirm\|confirmation\|createpassword\|createpost\|loginpost\)\.php' \
  2>/dev/null | xargs -r grep -l AccountInterface 2>/dev/null)
report "M2-A01-10" "Tên action nằm trong danh sách miễn đăng nhập của plugin Account" "$out"

# Controller frontend không có AccountInterface/isLoggedIn: phải là endpoint public có chủ đích
out=""
while IFS= read -r d; do
  out+="$(grep -rLE 'AccountInterface|isLoggedIn\(|AbstractAccount' "$d" --include=*.php 2>/dev/null | grep -v Adminhtml)"$'\n'
done < <(find "${PATHS[@]}" -type d -name Controller 2>/dev/null)
report "M2-A01-10" "Controller frontend không đòi đăng nhập (xác nhận là public có chủ đích — ồn)" "$(printf '%s' "$out" | sed '/^$/d')"

# --- A02/A09 ----------------------------------------------------------------------
g "M2-A02-02" "display_errors / error_reporting trong code" 'ini_set\(\s*.display_errors|error_reporting\(' --include=*.php
g "M2-A09-03" "Debug output / file_put_contents" '\b(var_dump|print_r|var_export|die|exit)\(|file_put_contents\(' --include=*.php --include=*.phtml
g "M2-A09-02" "Log nguyên request/header/body" 'logger->[a-z]+\(.*(getContent\(\)|getParams\(\)|getPostValue\(\)|getHeaders?\()' --include=*.php

# --- A04 crypto / secrets ---------------------------------------------------------
g "M2-A04-01 / A04-02 / A08-01" "md5/sha1/mt_rand/rand/uniqid/unserialize" \
  '\b(md5|sha1|mt_rand|rand|uniqid)\(|hash\(\s*.(md5|sha1)|[^>:a-zA-Z_]unserialize\(' --include=*.php

# Secret config mã hoá nhưng chưa khai sensitive
for p in "${PATHS[@]}"; do
  while IFS= read -r sx; do
    base=$(dirname "$(dirname "$sx")")
    if grep -q 'Backend\\Encrypted' "$sx" && ! grep -q 'TypePool' "$base/di.xml" 2>/dev/null; then
      report "M2-A04-03" "system.xml có Encrypted nhưng di.xml không khai TypePool sensitive" "$sx"
    fi
  done < <(find "$p" -path '*etc/adminhtml/system.xml' 2>/dev/null)
done

g "M2-A07-02" "Chuỗi giống credential hardcode" \
  "(api_?key|secret|password|token)\\W{1,6}['\"][A-Za-z0-9_-]{12,}['\"]" --include=*.php --include=*.xml
g "M2-A07-01 / A07-04" "Đăng nhập thủ công (kiểm có authenticate() trước đó không)" \
  'setCustomerAsLoggedIn|setCustomerDataAsLoggedIn|loginById|setCustomerId\(' --include=*.php
g "M2-A07-05" "JWT không ký" 'NoEncryption|ALGORITHM_NONE' --include=*.php

# --- A05 injection ------------------------------------------------------------------
g "M2-A05-01" "SQL có nối biến" "(fetchAll|fetchOne|fetchRow|fetchCol|query)\\(\\s*[\"'].*(\\$|\\{)" --include=*.php
g "M2-A05-01 / A06-04" "Zend_Db_Expr ghép chuỗi" "Zend_Db_Expr\\(\\s*['\"][^'\"]*['\"]\\s*\\." --include=*.php
g "M2-A05-03" '$this-> trong .phtml' '\$this->' --include=*.phtml
g "M2-A08-02" "Mass assignment: request vào setData/addData" \
  '(setData|addData)\(.*(getParams|getPostValue)\(\)' --include=*.php
g "M2-A05-04" "Shell/eval/include biến" '\b(exec|shell_exec|system|passthru|popen|proc_open|eval)\(' --include=*.php

# {{var x|modifier}} đầu tiên không phải escape
out=$(grep -rnoE '\{\{var [^}]*\|[^}]*\}\}' "${PATHS[@]}" --include=*.html 2>/dev/null | grep -vE '\{\{var [^}|]*\|escape')
report "M2-A05-06" "Email template: {{var}} có modifier đầu tiên khác escape" "$out"

# --- A10 ----------------------------------------------------------------------------
out=$(grep -rnE "${EXCL[@]}" -e 'catch \(Exception |@[a-z_]+\(' "${PATHS[@]}" --include=*.php 2>/dev/null | grep -vE '^\S+:[0-9]+:\s*(/\*|\*|//)')
report "M2-A10-01" "catch (Exception) thiếu dấu \\ hoặc dùng @" "$out"
report "M2-A10-01" "catch rỗng" "$(grep -rlPz 'catch\s*\([^)]*\)\s*\{\s*\}' "${EXCL[@]}" "${PATHS[@]}" --include=*.php 2>/dev/null)"
g "M2-A10-04" "load() rồi kiểm bằng if (!\$obj) — luôn false, phải kiểm getId()" \
  'if \(!\(?\$\w+ = .*->load\(' --include=*.php
g "M2-A10-02" "Trả getMessage() của exception cho người dùng" \
  '(addErrorMessage|addError|setData)\(.*\$e->getMessage\(\)' --include=*.php

echo "# Tổng: $TOTAL hit. Danh sách này không thay thế việc đọc code (A01 IDOR, A06 logic, A07 đều không grep được)."
