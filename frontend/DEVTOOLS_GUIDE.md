# Hướng dẫn sử dụng DevTools để Debug Flutter Web

## Cách 1: Chrome DevTools (Giống HTML DevTools)

Khi app đang chạy trên Chrome:

1. **Mở Chrome DevTools:**
   - Nhấn `F12` hoặc `Ctrl + Shift + I` (Windows)
   - Hoặc click chuột phải vào trang → "Inspect"

2. **Inspect Elements:**
   - Click vào icon **Select Element** (hoặc `Ctrl + Shift + C`)
   - Click vào bất kỳ phần tử nào trên app để xem HTML/CSS
   - Xem layout, styles, dimensions trong tab **Elements**

3. **Xem Console:**
   - Tab **Console** để xem logs và errors
   - Tab **Network** để xem network requests

4. **Responsive Design:**
   - Click icon **Toggle device toolbar** (`Ctrl + Shift + M`)
   - Chọn device hoặc set custom dimensions (390x844)

## Cách 2: Flutter DevTools (Chuyên dụng cho Flutter)

1. **Khi app đang chạy, mở terminal và chạy:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

2. **Hoặc mở từ URL trong terminal:**
   - Khi chạy `flutter run -d chrome`, terminal sẽ hiển thị:
   - `The Flutter DevTools debugger and profiler on Chrome is available at: http://127.0.0.1:9100?...`
   - Copy URL đó và mở trong browser

3. **Flutter DevTools có các tab:**
   - **Widget Inspector**: Xem widget tree giống HTML DOM
   - **Performance**: Profile performance
   - **Memory**: Xem memory usage
   - **Network**: Xem network requests
   - **Logging**: Xem logs

## Cách 3: Widget Inspector trong VS Code

1. **Mở Command Palette:** `Ctrl + Shift + P`
2. **Gõ:** "Flutter: Open DevTools"
3. **Chọn:** "Flutter: Open DevTools - Widget Inspector"

## Tips:

- **Hot Reload:** Nhấn `r` trong terminal khi app đang chạy
- **Hot Restart:** Nhấn `R` trong terminal
- **Quit:** Nhấn `q` trong terminal

## Debug Layout Issues:

1. **Chrome DevTools:**
   - Inspect element → xem computed styles
   - Xem box model (margin, padding, border)
   - Test responsive với device toolbar

2. **Flutter DevTools Widget Inspector:**
   - Xem widget tree
   - Xem properties của từng widget
   - Highlight widgets trên screen

