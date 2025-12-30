# setup-btec-quick.ps1 - إعداد سريع لمشروع BTEC

Write-Host "BTEC Assessment Engine - Quick Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# تحديد المسار
$projectPath = if ($args[0]) { $args[0] } else { Get-Location }
Write-Host "Project Path: $projectPath" -ForegroundColor Green

# 1. إنشاء المجلدات الأساسية فقط
Write-Host "`n📁 Creating basic folders..." -ForegroundColor Yellow

$essentialFolders = @(
    "src/app",
    "src/components",
    "src/styles",
    "public",
    "public/locales"
)

foreach ($folder in $essentialFolders) {
    $fullPath = Join-Path -Path $projectPath -ChildPath $folder
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "  Created: $folder" -ForegroundColor Green
    }
}

# 2. إنشاء ملف package.json فقط (الملف الأساسي)
Write-Host "`n📄 Creating package.json..." -ForegroundColor Yellow

$packageJson = @"
{
  "name": "btec-assessment-engine",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
"@

$packagePath = Join-Path -Path $projectPath -ChildPath "package.json"
$packageJson | Out-File -FilePath $packagePath -Encoding UTF8
Write-Host "  Created: package.json" -ForegroundColor Green

# 3. إنشاء ملف README.md بسيط
Write-Host "`n📄 Creating README.md..." -ForegroundColor Yellow

$readmeContent = @"
# BTEC Assessment Engine

Educational assessment platform with AI integration.

## Quick Start
\`\`\`bash
npm install
npm run dev
\`\`\`

## Phases
1. Project Setup
2. UI/UX Enhancement
3. Simulation Interface
4. i18n Support
5. Dashboard & Charts
... (17 phases total)
"@

$readmePath = Join-Path -Path $projectPath -ChildPath "README.md"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8
Write-Host "  Created: README.md" -ForegroundColor Green

# 4. إنشاء ملف .gitignore
Write-Host "`n📄 Creating .gitignore..." -ForegroundColor Yellow

$gitignoreContent = @"
node_modules/
.next/
.env*
"@

$gitignorePath = Join-Path -Path $projectPath -ChildPath ".gitignore"
$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
Write-Host "  Created: .gitignore" -ForegroundColor Green

# 5. العرض النهائي
Write-Host "`n" + "="*50
Write-Host "✅ Setup Completed Successfully!" -ForegroundColor Green
Write-Host "="*50

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open terminal in: $projectPath" -ForegroundColor White
Write-Host "2. Run: npm install" -ForegroundColor White
Write-Host "3. Run: npm run dev" -ForegroundColor White
Write-Host "4. Open: http://localhost:3000" -ForegroundColor White

Write-Host "`n📁 Project Structure:" -ForegroundColor Cyan
Get-ChildItem -Path $projectPath -Recurse -Depth 2 | 
    Select-Object -First 15 FullName | 
    ForEach-Object { Write-Host "  " $_.FullName.Replace($projectPath, "") }

Write-Host "`n🚀 Ready to start development!" -ForegroundColor Magenta