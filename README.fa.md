# NetFallback

**مجموعهٔ پشتیبان اتصال برای روزهای اختلال اینترنت** — دریافت نسخه‌های رسمی، آرشیو سورس و نگهداری محلی فایل‌ها و فراداده.

<p align="center">
  <a href="https://github.com/power0matin/NetFallback/releases/latest/download/NetFallback-All.zip"><img src="https://img.shields.io/github/downloads/power0matin/NetFallback/NetFallback-All.zip?style=flat-square&amp;label=ZIP%20Downloads&amp;labelColor=18181B&amp;color=0EA5E9&amp;logo=github&amp;logoColor=white" alt="تعداد دانلود بستهٔ کامل"/></a>
  <a href="https://github.com/power0matin/NetFallback/releases/latest"><img src="https://img.shields.io/github/v/release/power0matin/NetFallback?style=flat-square&amp;label=Latest%20Release&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="آخرین انتشار"/></a>
  <a href="https://github.com/power0matin/NetFallback/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/power0matin/NetFallback/ci.yml?branch=main&amp;style=flat-square&amp;label=CI&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="وضعیت تست‌های CI"/></a>
  <a href="https://hits.sh/github.com/power0matin/NetFallback/"><img src="https://hits.sh/github.com/power0matin/NetFallback.svg?style=flat-square&amp;label=Views&amp;labelColor=18181B&amp;color=0EA5E9&amp;logo=github" alt="بازدیدهای مخزن"/></a>
  <a href="https://github.com/power0matin/NetFallback/stargazers"><img src="https://img.shields.io/github/stars/power0matin/NetFallback?style=flat-square&amp;label=Stars&amp;labelColor=18181B&amp;color=F59E0B&amp;logo=github&amp;logoColor=white" alt="ستاره‌های GitHub"/></a>
  <a href="https://github.com/power0matin/NetFallback/forks"><img src="https://img.shields.io/github/forks/power0matin/NetFallback?style=flat-square&amp;label=Forks&amp;labelColor=18181B&amp;color=6366F1&amp;logo=github&amp;logoColor=white" alt="Forkهای GitHub"/></a>
  <a href="https://github.com/power0matin/NetFallback/issues"><img src="https://img.shields.io/github/issues/power0matin/NetFallback?style=flat-square&amp;label=Issues&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="Issues مخزن"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/power0matin/NetFallback?style=flat-square&amp;label=License&amp;labelColor=18181B&amp;color=EF4444&amp;logo=github&amp;logoColor=white" alt="مجوز GitHub"/></a>
</p>

## دانلود اصلی

**[دانلود بستهٔ کامل NetFallback — همهٔ فایل‌های پشتیبان در یک ZIP](https://github.com/power0matin/NetFallback/releases/latest/download/NetFallback-All.zip)**

این لینک همیشه به فایل اصلی آخرین Release اشاره می‌کند. بستهٔ کامل شامل فایل‌های منتخب Windows و Android، آرشیو سورس پروژه‌ها، snapshot تنظیمات منتخب، گزارش دانلود، فهرست SHA-256 و راهنمای فارسی است. حجم بسته با نسخه‌ها و فایل‌های بالادستی تغییر می‌کند؛ برای نسخهٔ نخست حدود ۱٫۲ گیگابایت در نظر بگیر.

برای مشاهدهٔ checksum بسته و راهنمای مستقل، [صفحهٔ آخرین Release](https://github.com/power0matin/NetFallback/releases/latest) را ببین.

## شروع سریع

1. بستهٔ کامل را از لینک بالا دریافت کن و ZIP را در پوشه‌ای با فضای کافی استخراج کن.
2. فایل **GUIDE.fa.md** را باز کن؛ نسخهٔ آن داخل بستهٔ کامل نیز قرار دارد.
3. فایل‌ها را از پوشهٔ مربوط به سیستم‌عامل یا نوع داده پیدا کن. NetFallback چیزی را خودکار نصب یا اجرا نمی‌کند.
4. پیش از استفاده از فایل‌های حساس، هش‌ها و دستورالعمل رسمی پروژهٔ سازنده را بررسی کن.

## محتویات بسته

| مسیر | محتوا |
| --- | --- |
| **01-Android/** | بسته‌های منتخب Android و فایل‌های امضا در صورت انتشار |
| **02-Windows/** | بسته‌های منتخب Windows و فایل‌های امضا در صورت انتشار |
| **03-Source-Code/** | آرشیو سورس پروژه‌ها، نام‌گذاری‌شده با شناسهٔ commit |
| **04-Configs/** | snapshotهای منتخب و متغیر تنظیمات عمومی |
| **05-Metadata/** | متادیتای Release و مخزن، کلیدهای عمومی و رکوردهای دانلود |
| **DOWNLOAD-REPORT.txt** | نتیجهٔ دانلود و خطاهای احتمالی |
| **SHA256SUMS-local.txt** | هش محلی فایل‌های آرشیوشده |
| **NetFallback-download-manifest.json** | فهرست ماشینی خروجی و وضعیت دانلودها |
| **مستندات** | راهنمای فارسی، README و یادداشت‌های پروتکل |

نام و محتویات دقیق فایل‌ها با انتشار نسخه‌های جدید پروژه‌های بالادستی تغییر می‌کند؛ فهرست قواعد انتخاب در [sources.json](sources.json) نگهداری می‌شود.

## دریافت انتخابی فایل‌ها از سورس

اگر کل بسته را نمی‌خواهی، سورس پروژه را دریافت کن و PowerShell 7 یا بالاتر را اجرا کن. باید GitHub و منابع بالادستی در دسترس باشند؛ وجود curl.exe برای ادامهٔ دانلودهای قطع‌شده توصیه می‌شود.

~~~powershell
# شبیه‌سازی، بدون دریافت فایل
pwsh -NoProfile -File .\scripts\backup.ps1 -DryRun

# فقط بسته‌های Windows
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Windows

# فقط بسته‌های Android
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Android

# فقط آرشیو سورس
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Source

# فقط snapshot تنظیمات منتخب
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Configs

# معماری‌های جایگزین؛ حجم بیشتر
pwsh -NoProfile -File .\scripts\backup.ps1 -IncludeAlternateArchitectures
~~~

اگر دانلود قطع شد، همان فرمان را دوباره اجرا کن. اسکریپت تلاش می‌کند فایل‌های بزرگ ناقص را با curl.exe ادامه دهد و در پایان گزارش و هش محلی بسازد. برای دانلود با runner گیت‌هاب و بدون آپلود فایل از اینترنت خودت، در زبانهٔ [Actions](https://github.com/power0matin/NetFallback/actions) گزینهٔ **Build offline backup bundle** را اجرا کن.

## چه چیزی را تضمین نمی‌کند؟

NetFallback ابزار دریافت و آرشیو است، نه سرویس VPN و نه سامانهٔ سنجش لحظه‌ای اپراتورها. دانلودشدن یک برنامه یا کانفیگ نشان نمی‌دهد که آن روش اکنون روی اینترنت، اپراتور یا دستگاه تو کار می‌کند. اگر تمام مسیرهای لازم قطع باشند، نرم‌افزار سمت کاربر به‌تنهایی مسیر جدیدی ایجاد نمی‌کند.

## اصالت فایل‌ها و امنیت

- اگر GitHub Releases برای یک فایل مقدار digest از نوع SHA-256 منتشر کند، اسکریپت هش فایل دریافتی را با آن مقایسه می‌کند.
- SHA256SUMS-local.txt هش محلی است و به‌تنهایی تأیید مستقل ناشر یا اثبات بی‌خطر بودن فایل نیست.
- فایل امضا ممکن است موجود باشد، اما NetFallback امضاها را خودکار اعتبارسنجی نمی‌کند؛ روش تأیید رسمی هر پروژه را دنبال کن.
- کانفیگ‌ها و endpointهای عمومی را ورودی غیرقابل‌اعتماد فرض کن و پیش از استفاده بررسی‌شان کن.
- کلید خصوصی، اطلاعات ورود و کانفیگ محرمانه را در ریپوی عمومی یا Release منتشر نکن.
- فایل‌های دانلودشده خودکار اجرا یا نصب نمی‌شوند.

## مستندات و نگهداری

- [راهنمای کامل فارسی](GUIDE.fa.md)
- [یادداشت پروتکل‌ها — فارسی](docs/protocols.fa.md)
- [Protocol notes — English](docs/protocols.md)
- [فهرست و قواعد منابع](sources.json)
- [سیاست امنیت](SECURITY.md)
- [یادداشت‌های Release نخست](RELEASE-NOTES-v0.1.0.md)

تست‌های آفلاین:

~~~powershell
python -m unittest discover -s tests -v
python -m json.tool sources.json
~~~

مجوز اسکریپت‌ها و مستندات اصلی NetFallback، MIT است؛ برای جزئیات و شرایط نرم‌افزارهای شخص ثالث، [LICENSE](LICENSE) و [NOTICE.md](NOTICE.md) را ببین.

---

NetFallback پروژه‌ای مستقل است و وابستگی رسمی به سازندگان ابزارهای فهرست‌شده، GitHub، Cloudflare یا اپراتورها ندارد. قوانین قابل‌اعمال، مجوز پروژه‌ها و خطرات استفاده از نرم‌افزارهای شخص ثالث را در نظر بگیر.
