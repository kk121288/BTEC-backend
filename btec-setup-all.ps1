# btec-setup-all.ps1 - سكربت شامل لبدء المشروع فوراً

Write-Host "🚀 BTEC Assessment Engine - Quick Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. تحديد المسار
$projectPath = if ($args[0]) { $args[0] } else { Get-Location }
Set-Location $projectPath

Write-Host "📁 Project Location: $projectPath" -ForegroundColor Green

# 2. إنشاء مجلدات أساسية فقط
Write-Host "`n📂 Creating minimal structure..." -ForegroundColor Yellow

$folders = @("src", "public", "components", "pages")
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  ✓ $folder" -ForegroundColor Green
    }
}

# 3. إنشاء ملف package.json أساسي
Write-Host "`n📦 Creating package.json..." -ForegroundColor Yellow

$packageJson = @"
{
  "name": "btec-assessment-engine",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.0.4",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "tailwindcss": "^3.3.0"
  },
  "devDependencies": {
    "@types/node": "20.10.0",
    "@types/react": "18.2.0",
    "@types/react-dom": "18.2.0",
    "autoprefixer": "^10.4.0",
    "eslint": "8.55.0",
    "eslint-config-next": "14.0.4",
    "postcss": "^8.4.0",
    "typescript": "5.3.0"
  }
}
"@

$packageJson | Out-File "package.json" -Encoding UTF8
Write-Host "  ✓ package.json created" -ForegroundColor Green

# 4. إنشاء ملفات Next.js الأساسية
Write-Host "`n⚛️ Creating Next.js files..." -ForegroundColor Yellow

# next.config.js
@"
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
"@ | Out-File "next.config.js" -Encoding UTF8

# tailwind.config.js
@"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
"@ | Out-File "tailwind.config.js" -Encoding UTF8

# postcss.config.js
@"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@ | Out-File "postcss.config.js" -Encoding UTF8

# tsconfig.json
@"
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
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
"@ | Out-File "tsconfig.json" -Encoding UTF8

# globals.css
@"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ | Out-File "src/globals.css" -Encoding UTF8

# layout.tsx
@"
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'BTEC Assessment Engine',
  description: 'Educational assessment platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
"@ | Out-File "src/layout.tsx" -Encoding UTF8

# page.tsx
@"
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-6">
          🚀 BTEC Assessment Engine
        </h1>
        <p className="text-lg mb-8">
          Advanced educational assessment platform is ready!
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="p-6 bg-blue-50 rounded-lg">
            <h3 className="font-bold text-xl mb-2">Phase 1</h3>
            <p>Project Setup ✓</p>
          </div>
          
          <div className="p-6 bg-green-50 rounded-lg">
            <h3 className="font-bold text-xl mb-2">Next Phase</h3>
            <p>UI/UX Enhancement</p>
          </div>
          
          <div className="p-6 bg-purple-50 rounded-lg">
            <h3 className="font-bold text-xl mb-2">Status</h3>
            <p>Ready for development</p>
          </div>
        </div>
        
        <div className="mt-10">
          <p className="text-sm text-gray-500">
            Next.js 14 • TypeScript • Tailwind CSS
          </p>
        </div>
      </div>
    </main>
  )
}
"@ | Out-File "src/page.tsx" -Encoding UTF8

Write-Host "  ✓ Next.js files created" -ForegroundColor Green

# 5. إنشاء ملف README
@"
# BTEC Assessment Engine

## 📋 Overview
Educational assessment platform with 17 development phases.

## 🚀 Getting Started

### Installation
\`\`\`bash
npm install
npm run dev
\`\`\`

### Development Phases
1. ✅ Project Setup & Structure
2. UI/UX Enhancement
3. Simulation Interface
4. i18n Support
5. Dashboard & Charts
6. PWA Integration
7. Testing Infrastructure
8. Login Redesign
9. User Management
10. Course Management
11. Assignment Workflow
12. AI Integration
13. Audio Input
14. Notifications
15. Reporting
16. Deployment
17. Documentation

## 📁 Project Structure
\`\`\`
project/
├── src/
│   ├── page.tsx
│   ├── layout.tsx
│   └── globals.css
├── components/
├── public/
├── package.json
└── [config files]
\`\`\`

## 🛠️ Available Scripts
- \`npm run dev\` - Start dev server
- \`npm run build\` - Build for production
- \`npm start\` - Start production server
- \`npm run lint\` - Run ESLint

## 🔗 Open http://localhost:3000 to view your app
"@ | Out-File "README.md" -Encoding UTF8

Write-Host "  ✓ README.md created" -ForegroundColor Green

# ========== الخيارات ==========
Write-Host "`n" + "="*50
Write-Host "🎯 CHOOSE YOUR ACTION (1-3)" -ForegroundColor Magenta
Write-Host "="*50

Write-Host "`n1️⃣ - Start development server (npm run dev)" -ForegroundColor Cyan
Write-Host "2️⃣ - Check package.json to see what's installed" -ForegroundColor Cyan
Write-Host "3️⃣ - Install dependencies AND start server" -ForegroundColor Cyan
Write-Host "0️⃣ - Exit" -ForegroundColor Gray

$choice = Read-Host "`nEnter your choice (0-3)"

switch ($choice) {
    "1" {
        # الخيار 1: تشغيل خادم التطوير فقط
        Write-Host "`n🚀 Starting development server..." -ForegroundColor Yellow
        Write-Host "📡 Server will run at: http://localhost:3000" -ForegroundColor White
        Write-Host "Press Ctrl+C to stop the server`n" -ForegroundColor Gray
        
        # التحقق من وجود node_modules
        if (-not (Test-Path "node_modules")) {
            Write-Host "⚠️ Dependencies not found! Running npm install first..." -ForegroundColor Yellow
            npm install
        }
        
        # بدء الخادم
        npm run dev
    }
    
    "2" {
        # الخيار 2: عرض محتويات package.json
        Write-Host "`n📦 PACKAGE.JSON CONTENTS:" -ForegroundColor Yellow
        Write-Host "="*40
        
        if (Test-Path "package.json") {
            $package = Get-Content "package.json" -Raw | ConvertFrom-Json
            
            Write-Host "Project: $($package.name)" -ForegroundColor White
            Write-Host "Version: $($package.version)" -ForegroundColor White
            
            Write-Host "`n📋 Scripts:" -ForegroundColor Cyan
            $package.scripts.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Gray
            }
            
            Write-Host "`n📦 Dependencies:" -ForegroundColor Cyan
            $package.dependencies.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Green
            }
            
            Write-Host "`n🔧 Dev Dependencies:" -ForegroundColor Cyan
            $package.devDependencies.PSObject.Properties | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Blue
            }
            
            Write-Host "`n📁 Node Modules:" -ForegroundColor Cyan
            if (Test-Path "node_modules") {
                $count = (Get-ChildItem "node_modules" -Directory).Count
                Write-Host "  Installed: $count packages" -ForegroundColor Green
            } else {
                Write-Host "  Not installed yet" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ package.json not found!" -ForegroundColor Red
        }
        
        Write-Host "`n" + "="*40
        Write-Host "To install dependencies, run: npm install" -ForegroundColor Yellow
        Write-Host "To start server, run: npm run dev" -ForegroundColor Yellow
    }
    
    "3" {
        # الخيار 3: تثبيت التبعيات ثم تشغيل الخادم
        Write-Host "`n📥 Installing dependencies..." -ForegroundColor Yellow
        
        # تثبيت التبعيات
        npm install
        
        Write-Host "`n✅ Dependencies installed successfully!" -ForegroundColor Green
        
        Write-Host "`n🚀 Starting development server..." -ForegroundColor Yellow
        Write-Host "📡 Open: http://localhost:3000" -ForegroundColor White
        Write-Host "Press Ctrl+C to stop the server`n" -ForegroundColor Gray
        
        # بدء الخادم
        npm run dev
    }
    
    "0" {
        Write-Host "👋 Goodbye!" -ForegroundColor Gray
        exit
    }
    
    default {
        Write-Host "❌ Invalid choice! Running default option 1..." -ForegroundColor Red
        
        # تشغيل الخيار الافتراضي (1)
        if (-not (Test-Path "node_modules")) {
            npm install
        }
        npm run dev
    }
}

# ========== معلومات إضافية ==========
Write-Host "`n" + "="*50
Write-Host "📋 PROJECT INFO" -ForegroundColor Cyan
Write-Host "="*50

Write-Host "`n📁 Project Structure:" -ForegroundColor White
Get-ChildItem -Path $projectPath -Depth 1 | Select-Object Name, @{Name="Type";Expression={if($_.PSIsContainer){"📁"}else{"📄"}}} | Format-Table -AutoSize

Write-Host "`n🔗 Quick Links:" -ForegroundColor Yellow
Write-Host "  Local: http://localhost:3000" -ForegroundColor White
Write-Host "  Package: $projectPath\package.json" -ForegroundColor White
Write-Host "  Source: $projectPath\src\" -ForegroundColor White

Write-Host "`n⚡ Quick Commands:" -ForegroundColor Magenta
Write-Host "  npm run dev    # Start development" -ForegroundColor Gray
Write-Host "  npm run build  # Build for production" -ForegroundColor Gray
Write-Host "  npm start      # Start production server" -ForegroundColor Gray

Write-Host "`n🎯 Next Steps (Phase 2 - UI/UX):" -ForegroundColor Green
Write-Host "  1. Add responsive design components" -ForegroundColor White
Write-Host "  2. Implement dark/light theme" -ForegroundColor White
Write-Host "  3. Create reusable UI library" -ForegroundColor White

Write-Host "`n" + "="*50
Write-Host "✅ BTEC Assessment Engine is READY!" -ForegroundColor Green
Write-Host "="*50