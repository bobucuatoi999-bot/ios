# Binhan Thiết Bị — iOS App

WebView app cho https://thietbi.codientubinhan.com/

---

## 📁 Cấu trúc project

```
BinhaniOS/
├── BinhanThietBi.xcodeproj/
│   ├── project.pbxproj              ← Xcode project config
│   └── xcshareddata/xcschemes/
│       └── BinhanThietBi.xcscheme  ← Build scheme
└── BinhanThietBi/
    ├── AppDelegate.swift            ← Entry point
    ├── SplashViewController.swift   ← Splash (1.5s, blue)
    ├── MainViewController.swift     ← WKWebView chính
    ├── OfflineView.swift            ← Màn hình offline
    ├── Info.plist                   ← App config, permissions
    ├── Base.lproj/
    │   └── LaunchScreen.storyboard  ← Launch screen
    └── Assets.xcassets/
        ├── AppIcon.appiconset/      ← 18 icon sizes (20→1024px)
        └── AccentColor.colorset/    ← Màu accent #1565C0
```

---

## ✅ Tính năng

| Tính năng | Chi tiết |
|---|---|
| WKWebView full-screen | iOS native, hiệu năng cao |
| Splash screen | Logo BH, tên app, fade 1.5s |
| Pull-to-refresh | Vuốt xuống để reload |
| Progress bar | 3pt bar màu xanh trên cùng |
| Back gesture | Vuốt từ trái để quay lại |
| Offline screen | Tiếng Việt + nút Thử lại |
| External links | Mở trong Safari |
| File picker | Hỗ trợ input type=file |
| HTTPS only | NSAppTransportSecurity cấu hình chặt |
| Cookies persistent | WKWebsiteDataStore.default() |
| iPhone + iPad | TARGETED_DEVICE_FAMILY = 1,2 |
| iOS 15.0+ | Deployment target |

---

## 🚀 Build & Upload App Store

### Yêu cầu
- **Mac** với macOS 13+ (Ventura trở lên)
- **Xcode 15** (tải từ Mac App Store, miễn phí)
- **Apple Developer Account** ($99 USD/năm) tại developer.apple.com

---

### Bước 1 — Mở project trong Xcode

```bash
open BinhaniOS/BinhanThietBi.xcodeproj
```

Hoặc: File → Open → chọn thư mục `BinhaniOS`

---

### Bước 2 — Điền Team ID (bắt buộc)

1. Trong Xcode: click vào `BinhanThietBi` (target) ở sidebar trái
2. Tab **Signing & Capabilities**
3. Chọn **Team** của bạn từ dropdown
4. Bundle ID `com.binhan.thietbi` — đổi nếu đã bị chiếm (ví dụ: `com.yourname.binhanthietbi`)
5. Xcode sẽ tự ký (Automatically manage signing)

---

### Bước 3 — Test trên thiết bị thật (optional nhưng khuyến nghị)

1. Cắm iPhone vào Mac qua USB
2. Chọn thiết bị từ dropdown trên toolbar Xcode
3. Nhấn ▶ Run (Cmd+R)
4. Lần đầu: iPhone sẽ yêu cầu Trust Developer → Settings → General → VPN & Device Management → Trust

---

### Bước 4 — Archive (tạo bản release)

```
Product → Archive
```

Xcode sẽ build bản Release và mở **Organizer** khi xong.

---

### Bước 5 — Upload lên App Store Connect

Trong Organizer:
1. Chọn archive vừa tạo
2. Click **Distribute App**
3. Chọn **App Store Connect**
4. Chọn **Upload**
5. Để mặc định tất cả options → **Next** → **Upload**

Quá trình upload mất 5-15 phút.

---

### Bước 6 — Cấu hình App Store Connect

Vào https://appstoreconnect.apple.com:

1. **My Apps** → **+** → **New App**
2. Điền:
   - Name: `Cô Điện Tử Bình Hân`
   - Primary language: Vietnamese
   - Bundle ID: `com.binhan.thietbi`
   - SKU: `binhanthietbi001`

3. **App Information** tab:
   - Category: Shopping hoặc Utilities
   - Privacy Policy URL (bắt buộc nếu có login)

4. **Pricing** tab: Free

5. **App Store** tab → **Prepare for Submission**:
   - Screenshots: tối thiểu 1 ảnh cho iPhone 6.5" (1242×2688) và 5.5" (1242×2208)
   - Description (tối đa 4000 ký tự)
   - Keywords (tối đa 100 ký tự)
   - Support URL

6. Chọn build đã upload → **Submit for Review**

---

### Bước 7 — Review

- Apple review thường mất **1-3 ngày**
- Nếu rejected: xem lý do trong Resolution Center và fix

---

## 🔢 Update version

Trong Xcode → Target → General:
- **Version**: 1.0.1 (user-facing)
- **Build**: 2 (phải tăng mỗi lần upload, không được trùng)

Hoặc sửa trong `project.pbxproj`:
```
MARKETING_VERSION = 1.0.1;
CURRENT_PROJECT_VERSION = 2;
```

---

## 🎨 Thay đổi màu sắc

Trong các file Swift, tìm:
```swift
private let primaryColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
```
Đổi giá trị RGB theo màu bạn muốn.

---

## ⚠️ Lưu ý quan trọng

- **Keystore iOS = Apple Developer Account** — không cần tạo keystore thủ công, Xcode tự xử lý
- **Bundle ID** phải unique trên toàn App Store — nếu `com.binhan.thietbi` đã tồn tại, đổi thành cái khác
- **Screenshots** phải thật (chụp từ Simulator) không được dùng ảnh web hoặc mockup sai kích thước
- **Privacy Policy** bắt buộc nếu app có đăng nhập/thu thập dữ liệu
- App Apple review có thể reject nếu: app quá đơn giản chỉ là webview mà không có giá trị thêm → thêm mô tả rõ ràng về store trong description
