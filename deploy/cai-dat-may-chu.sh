#!/usr/bin/env bash
# Cài đặt máy chủ hiển thị demo Giá Gốc và tự cập nhật từ GitHub.
# Chạy một lần trên máy chủ Ubuntu/Debian với quyền root:
#   curl -fsSL https://raw.githubusercontent.com/PhapDang2105/gia-goc-ke-toan/cap-nhat-theo-yeu-cau-khach-hang/deploy/cai-dat-may-chu.sh | sudo bash
# Chạy lại bao nhiêu lần cũng được (không làm hỏng cài đặt cũ).
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/PhapDang2105/gia-goc-ke-toan.git}"
BRANCH="${BRANCH:-cap-nhat-theo-yeu-cau-khach-hang}"
APP_DIR="${APP_DIR:-/opt/gia-goc-ke-toan}"
PORT="${PORT:-8080}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Cần chạy với quyền root (thêm sudo)." >&2
  exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
  echo "Script này dành cho Ubuntu/Debian (cần apt-get)." >&2
  exit 1
fi

echo "==> Cài git và nginx"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq git nginx >/dev/null

echo "==> Tải mã nguồn nhánh $BRANCH vào $APP_DIR"
if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" fetch -q origin "$BRANCH"
  git -C "$APP_DIR" checkout -q -B "$BRANCH" "origin/$BRANCH"
else
  git clone -q --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

echo "==> Tạo lệnh cập nhật /usr/local/bin/gia-goc-cap-nhat"
cat > /usr/local/bin/gia-goc-cap-nhat <<EOF
#!/usr/bin/env bash
set -euo pipefail
git -C "$APP_DIR" fetch -q origin "$BRANCH"
git -C "$APP_DIR" reset -q --hard "origin/$BRANCH"
EOF
chmod 755 /usr/local/bin/gia-goc-cap-nhat

echo "==> Tự cập nhật mỗi 2 phút"
cat > /etc/cron.d/gia-goc <<'EOF'
*/2 * * * * root /usr/local/bin/gia-goc-cap-nhat >/var/log/gia-goc-cap-nhat.log 2>&1
EOF
chmod 644 /etc/cron.d/gia-goc

echo "==> Cấu hình nginx cổng $PORT"
LISTEN6=""
if [ -s /proc/net/if_inet6 ]; then LISTEN6="listen [::]:$PORT;"; fi
cat > /etc/nginx/sites-available/gia-goc <<EOF
server {
    listen $PORT;
    $LISTEN6
    root $APP_DIR/demo;
    index gia-goc-demo.html;
    charset utf-8;
    location / {
        try_files \$uri \$uri/ =404;
        add_header Cache-Control "no-cache";
    }
    location ~ /\. { deny all; }
}
EOF
ln -sf /etc/nginx/sites-available/gia-goc /etc/nginx/sites-enabled/gia-goc
nginx -t
systemctl enable --now nginx >/dev/null 2>&1 || true
systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || nginx

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  echo "==> Mở cổng $PORT trên tường lửa ufw"
  ufw allow "$PORT/tcp" >/dev/null
fi

IP="$(curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')"
echo
echo "XONG. Mở trình duyệt: http://$IP:$PORT/"
echo "Máy chủ tự lấy bản mới từ GitHub mỗi 2 phút. Cập nhật ngay: sudo gia-goc-cap-nhat"
echo "Nếu không mở được: mở cổng $PORT trong tường lửa của nhà cung cấp máy chủ (Security group / Firewall)."
