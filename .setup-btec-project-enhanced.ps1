# ============================================
# BTEC Assessment Engine - إعداد المشروع الكامل
# ============================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "BTEC Assessment Engine - إعداد المشروع" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. تحديد المسار
$projectPath = Read-Host "أدخل مسار المشروع (أتركه فارغاً للاستخدام الحالي)"
if ([string]::IsNullOrWhiteSpace($projectPath)) {
    $projectPath = Get-Location
}

Write-Host "المسار المحدد: $projectPath" -ForegroundColor Green

# 2. التحقق إذا كان المجلد فارغاً
$items = Get-ChildItem -Path $projectPath -Force
if ($items.Count -gt 0) {
    Write-Host "تحذير: المجلد غير فارغ!" -ForegroundColor Yellow
    $confirm = Read-Host "هل تريد المتابعة؟ (y/n)"
    if ($confirm -ne 'y') {
        Write-Host "تم إلغاء العملية." -ForegroundColor Red
        exit
    }
}

# 3. إنشاء المجلدات الأساسية
Write-Host "`n📁 إنشاء المجلدات الأساسية..." -ForegroundColor Yellow

function Create-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "  ✓ $($Path.Replace($projectPath, '').TrimStart('\'))" -ForegroundColor Green
        return $true
    }
    return $false
}

# إنشاء جميع المجلدات
$folders = @(
    # المجلدات الرئيسية
    "$projectPath/src",
    "$projectPath/public",
    "$projectPath/docs",
    "$projectPath/tests",
    "$projectPath/.github/workflows",
    
    # مجلدات src
    "$projectPath/src/app",
    "$projectPath/src/components/ui",
    "$projectPath/src/components/layout",
    "$projectPath/src/components/simulation",
    "$projectPath/src/components/charts",
    "$projectPath/src/components/dashboard",
    "$projectPath/src/hooks",
    "$projectPath/src/lib",
    "$projectPath/src/utils",
    "$projectPath/src/styles",
    "$projectPath/src/services",
    "$projectPath/src/types",
    "$projectPath/src/constants",
    "$projectPath/src/locales/ar",
    "$projectPath/src/locales/en",
    
    # مجلدات public
    "$projectPath/public/images",
    "$projectPath/public/fonts",
    "$projectPath/public/icons",
    "$projectPath/public/locales/ar",
    "$projectPath/public/locales/en",
    "$projectPath/public/audio"
)

$foldersCreated = 0
foreach ($folder in $folders) {
    if (Create-Folder -Path $folder) {
        $foldersCreated++
    }
}

Write-Host "تم إنشاء $foldersCreated مجلد جديد" -ForegroundColor Cyan

# 4. إنشاء ملفات التكوين الأساسية
Write-Host "`n📄 إنشاء ملفات التكوين..." -ForegroundColor Yellow

function Create-File {
    param([string]$Path, [string]$Content)
    if (-not (Test-Path $Path)) {
        $Content | Out-File -FilePath $Path -Encoding UTF8
        Write-Host "  ✓ $($Path.Replace($projectPath, '').TrimStart('\'))" -ForegroundColor Green
        return $true
    }
    return $false
}

# جميع ملفات التكوين
$configFiles = @{
    # ملف README
    "$projectPath/README.md" = @"
# BTEC Assessment Engine

منصة تقييم تعليمية متقدمة مع دعم الذكاء الاصطناعي والمحاكاة ثلاثية الأبعاد.

## المميزات
- ✅ نظام تقييم ذكي
- ✅ دعم متعدد اللغات (عربي/إنجليزي)
- ✅ محاكاة ثلاثية الأبعاد
- ✅ تطبيق PWA
- ✅ تكامل مع الذكاء الاصطناعي

## بدء التشغيل
\`\`\`bash
npm install
npm run dev
\`\`\`

## المراحل
تم إنشاء 17 مرحلة كاملة، راجع PROJECT_PLAN.md للتفاصيل
"@

    # package.json
    "$projectPath/package.json" = @"
{
  "name": "btec-assessment-engine",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest run",
    "test:watch": "vitest",
    "translate:extract": "i18next-scanner --config i18next-scanner.config.js"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "typescript": "^5.2.2",
    "tailwindcss": "^3.3.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.0.0",
    "lucide-react": "^0.309.0",
    "next-i18next": "^15.0.0",
    "react-i18next": "^13.0.0",
    "three": "^0.158.0",
    "@react-three/fiber": "^8.14.0",
    "@react-three/drei": "^9.94.0",
    "recharts": "^2.10.0",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0",
    "zustand": "^4.4.0",
    "next-pwa": "^5.6.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/node": "^20.9.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@types/three": "^0.158.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "eslint": "^8.53.0",
    "eslint-config-next": "^14.0.0",
    "vitest": "^1.0.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.1.0"
  }
}
"@

    # next.config.js
    "$projectPath/next.config.js" = @"
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  i18n: {
    locales: ['ar', 'en'],
    defaultLocale: 'ar',
    localeDetection: true,
  },
  images: {
    domains: ['localhost'],
  },
}

const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: true,
  skipWaiting: true,
})

module.exports = withPWA(nextConfig)
"@

    # tailwind.config.ts
    "$projectPath/tailwind.config.ts" = @"
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
      },
      fontFamily: {
        arabic: ['Cairo', 'sans-serif'],
        english: ['Inter', 'sans-serif'],
      },
      direction: {
        'ltr': 'ltr',
        'rtl': 'rtl',
      },
    },
  },
  plugins: [],
}
export default config
"@

    # tsconfig.json
    "$projectPath/tsconfig.json" = @"
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
"@

    # .env.local
    "$projectPath/.env.local" = @"
# البيئة المحلية
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_APP_NAME=BTEC Assessment Engine
NEXT_PUBLIC_APP_VERSION=1.0.0

# مفاتيح API (تحديث لاحقاً)
NEXT_PUBLIC_OPENAI_API_KEY=your_key_here
NEXT_PUBLIC_GOOGLE_API_KEY=your_key_here
"@

    # .gitignore
    "$projectPath/.gitignore" = @"
# التبعيات
node_modules/
.next/

# البيئة
.env*.local
.env

# النظام
.DS_Store
*.pem
*.log

# IDE
.vscode/
.idea/

# الاختبارات
coverage/
.nyc_output

# البناء
out/
dist/
"@

    # postcss.config.js
    "$projectPath/postcss.config.js" = @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@

    # globals.css
    "$projectPath/src/styles/globals.css" = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-rgb: 255, 255, 255;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground-rgb: 255, 255, 255;
    --background-rgb: 0, 0, 0;
  }
}

body {
  color: rgb(var(--foreground-rgb));
  background: rgb(var(--background-rgb));
}

/* تحسينات للغة العربية */
[dir="rtl"] {
  text-align: right;
}

[dir="ltr"] {
  text-align: left;
}
"@

    # ملفات الترجمة
    "$projectPath/public/locales/ar/common.json" = @"
{
  "app": {
    "name": "منصة تقييم BTEC",
    "description": "منصة تقييم تعليمية متقدمة"
  },
  "nav": {
    "home": "الرئيسية",
    "dashboard": "لوحة التحكم",
    "simulation": "المحاكاة",
    "assignments": "الواجبات",
    "profile": "الملف الشخصي",
    "login": "تسجيل الدخول",
    "logout": "تسجيل الخروج"
  },
  "buttons": {
    "submit": "إرسال",
    "cancel": "إلغاء",
    "save": "حفظ",
    "edit": "تعديل",
    "delete": "حذف",
    "view": "عرض"
  }
}
"@

    "$projectPath/public/locales/en/common.json" = @"
{
  "app": {
    "name": "BTEC Assessment Engine",
    "description": "Advanced educational assessment platform"
  },
  "nav": {
    "home": "Home",
    "dashboard": "Dashboard",
    "simulation": "Simulation",
    "assignments": "Assignments",
    "profile": "Profile",
    "login": "Login",
    "logout": "Logout"
  },
  "buttons": {
    "submit": "Submit",
    "cancel": "Cancel",
    "save": "Save",
    "edit": "Edit",
    "delete": "Delete",
    "view": "View"
  }
}
"@

    # ملفات المكونات الأساسية
    "$projectPath/src/app/layout.tsx" = @"
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import '../styles/globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'BTEC Assessment Engine',
  description: 'Advanced educational assessment platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ar" dir="rtl">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
"@

    "$projectPath/src/app/page.tsx" = @"
export default function HomePage() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">
          BTEC Assessment Engine
        </h1>
        <p className="text-gray-600">
          مشروع تقييم تعليمي متقدم - قيد التطوير
        </p>
        <div className="mt-8">
          <a 
            href="/dashboard" 
            className="bg-blue-500 text-white px-6 py-3 rounded-lg hover:bg-blue-600"
          >
            الانتقال للوحة التحكم
          </a>
        </div>
      </div>
    </div>
  )
}
"@

    # PROJECT_PLAN.md
    "$projectPath/PROJECT_PLAN.md" = @"
# خطة مشروع BTEC Assessment Engine

## المراحل (17 مرحلة)
1. ✅ Project Setup & Structure
2. UI/UX Enhancement
3. Simulation Interface
4. i18n (الترجمة الثنائية)
5. Dashboard & Charts
6. PWA Integration
7. Testing Infrastructure
8. Login Redesign
9. User Management
10. Course & Unit Management
11. Assignment Workflow
12. AI Plagiarism Integration
13. Audio Input Integration
14. Notifications System
15. Reporting & Export
16. Deployment Pipeline
17. Documentation & Research
"@

    # .cursorrules
    "$projectPath/.cursorrules" = @"
{
  "projectContext": {
    "name": "BTEC Assessment Engine",
    "description": "Advanced educational assessment platform",
    "technologies": ["Next.js", "TypeScript", "Three.js", "PWA", "i18n"]
  },
  "instructions": "Use TypeScript, support Arabic RTL, create modular components"
}
"@

    # manifest.json
    "$projectPath/public/manifest.json" = @"
{
  "name": "BTEC Assessment Engine",
  "short_name": "BTEC",
  "description": "Advanced educational assessment platform",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#3b82f6",
  "background_color": "#ffffff"
}
"@
}

$filesCreated = 0
foreach ($filePath in $configFiles.Keys) {
    if (Create-File -Path $filePath -Content $configFiles[$filePath]) {
        $filesCreated++
    }
}

Write-Host "تم إنشاء $filesCreated ملف جديد" -ForegroundColor Cyan

# 5. الخيارات بعد الإنشاء
Write-Host "`n" + "="*50
Write-Host "🎉 تم إعداد المشروع بنجاح!" -ForegroundColor Green
Write-Host "="*50

Write-Host "`n🔧 اختر الخطوة التالية:" -ForegroundColor Yellow
Write-Host "1️⃣ - تثبيت dependencies (npm install)" -ForegroundColor White
Write-Host "2️⃣ - التحقق من الملفات المنشأة" -ForegroundColor White
Write-Host "3️⃣ - تشغيل خادم التطوير" -ForegroundColor White
Write-Host "4️⃣ - فتح المشروع في VS Code" -ForegroundColor White
Write-Host "0️⃣ - إنهاء (لا شيء مما سبق)" -ForegroundColor Gray

$choice = Read-Host "`nأدخل رقم الخيار المطلوب (1-4) أو 0 للإنهاء"

switch ($choice) {
    "1" {
        Write-Host "`n📦 تثبيت dependencies..." -ForegroundColor Yellow
        Set-Location $projectPath
        
        # التحقق من وجود npm
        $npmCheck = Get-Command npm -ErrorAction SilentlyContinue
        if (-not $npmCheck) {
            Write-Host "❌ npm غير مثبت! يرجى تثبيت Node.js أولاً" -ForegroundColor Red
            break
        }
        
        try {
            # تثبيت التبعيات
            Write-Host "جارٍ تثبيت التبعيات (قد يستغرق بضع دقائق)..." -ForegroundColor Cyan
            npm install
            
            Write-Host "✅ تم تثبيت التبعيات بنجاح!" -ForegroundColor Green
            
            # سؤال المستخدم إذا كان يريد البدء في التطوير
            $startDev = Read-Host "هل تريد تشغيل خادم التطوير الآن؟ (y/n)"
            if ($startDev -eq 'y') {
                Write-Host "🚀 بدء خادم التطوير..." -ForegroundColor Yellow
                Start-Process "npm" -ArgumentList "run dev" -NoNewWindow
            }
        }
        catch {
            Write-Host "❌ حدث خطأ أثناء تثبيت التبعيات: $_" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host "`n📁 التحقق من الملفات المنشأة:" -ForegroundColor Yellow
        
        # عرض شجرة المجلدات
        function Show-Tree {
            param([string]$Path, [int]$Depth = 0)
            
            $items = Get-ChildItem -Path $Path -Force | Sort-Object Name
            
            foreach ($item in $items) {
                $indent = "  " * $Depth
                $icon = if ($item.PSIsContainer) { "📂" } else { "📄" }
                $name = $item.Name
                
                Write-Host "$indent$icon $name" -ForegroundColor $(if ($item.PSIsContainer) { "Cyan" } else { "Gray" })
                
                if ($item.PSIsContainer -and $Depth -lt 2) {
                    Show-Tree -Path $item.FullName -Depth ($Depth + 1)
                }
            }
        }
        
        Show-Tree -Path $projectPath
        
        # عرض معلومات المشروع
        Write-Host "`n📊 إحصائيات المشروع:" -ForegroundColor Yellow
        
        $dirCount = (Get-ChildItem -Path $projectPath -Recurse -Directory).Count
        $fileCount = (Get-ChildItem -Path $projectPath -Recurse -File).Count
        
        Write-Host "المجلدات: $dirCount" -ForegroundColor White
        Write-Host "الملفات: $fileCount" -ForegroundColor White
        Write-Host "الحجم الإجمالي: {0:N2} MB" -f ((Get-ChildItem -Path $projectPath -Recurse | Measure-Object Length -Sum).Sum / 1MB)
    }
    
    "3" {
        Write-Host "`n🚀 تشغيل خادم التطوير..." -ForegroundColor Yellow
        
        # التحقق من وجود dependencies
        if (-not (Test-Path "$projectPath/node_modules")) {
            Write-Host "⚠️  dependencies غير مثبتة!" -ForegroundColor Yellow
            $install = Read-Host "هل تريد تثبيتها الآن؟ (y/n)"
            
            if ($install -eq 'y') {
                Set-Location $projectPath
                npm install
            }
            else {
                Write-Host "❌ لا يمكن تشغيل الخادم بدون dependencies" -ForegroundColor Red
                break
            }
        }
        
        Set-Location $projectPath
        
        # بدء خادم التطوير
        try {
            Write-Host "جاري بدء خادم التطوير على http://localhost:3000" -ForegroundColor Cyan
            Write-Host "اضغط Ctrl+C لإيقاف الخادم" -ForegroundColor Gray
            
            # تشغيل npm run dev
            Start-Process "npm" -ArgumentList "run dev" -NoNewWindow
        }
        catch {
            Write-Host "❌ حدث خطأ: $_" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host "`n👨‍💻 فتح المشروع في VS Code..." -ForegroundColor Yellow
        
        # التحقق من وجود VS Code
        $vscode = Get-Command code -ErrorAction SilentlyContinue
        
        if ($vscode) {
            try {
                code $projectPath
                Write-Host "✅ تم فتح المشروع في VS Code" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ حدث خطأ أثناء فتح VS Code" -ForegroundColor Red
            }
        }
        else {
            Write-Host "❌ VS Code غير مثبت أو غير موجود في PATH" -ForegroundColor Red
            Write-Host "يمكنك فتح المشروع يدوياً من: $projectPath" -ForegroundColor Gray
        }
    }
    
    "0" {
        Write-Host "👋 تم إنهاء البرنامج" -ForegroundColor Gray
    }
    
    default {
        Write-Host "❌ خيار غير صالح" -ForegroundColor Red
    }
}

# 6. تعليمات الإنهاء
Write-Host "`n" + "="*50
Write-Host "📋 تعليمات المتابعة:" -ForegroundColor Cyan

if ($choice -eq "0" -or $choice -notin @("1", "2", "3", "4")) {
    Write-Host "لبدء المشروع يدوياً:" -ForegroundColor White
    Write-Host "1. افتح موجه الأوامر في: $projectPath" -ForegroundColor Gray
    Write-Host "2. قم بتثبيت dependencies: npm install" -ForegroundColor Gray
    Write-Host "3. ابدأ التطوير: npm run dev" -ForegroundColor Gray
    Write-Host "4. افتح المتصفح على: http://localhost:3000" -ForegroundColor Gray
}

Write-Host "`n📚 ملفات هامة للبدء:" -ForegroundColor Yellow
Write-Host "  📄 PROJECT_PLAN.md - خطة المشروع الكاملة (17 مرحلة)" -ForegroundColor White
Write-Host "  📄 .cursorrules - تعليمات للذكاء الاصطناعي" -ForegroundColor White
Write-Host "  📄 package.json - تبعيات المشروع وأوامر npm" -ForegroundColor White

Write-Host "`n🎯 المرحلة التالية: Phase 2 - UI/UX Enhancement" -ForegroundColor Magenta
Write-Host "="*50
Write-Host "تم الإنشاء بواسطة BTEC Assessment Engine Setup Script" -ForegroundColor Gray