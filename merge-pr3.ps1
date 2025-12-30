# ====================================================================
# سكربت دمج PR #3 - BTEC Smart Platform Frontend
# ====================================================================

# الإعدادات
$REPO_URL = "https://github.com/kk121288/BTEC-Smart-Platform-Frontend.git"
$REPO_NAME = "BTEC-Smart-Platform-Frontend"
$BASE_BRANCH = "template"
$PR_NUMBER = 3
$PR_BRANCH = "copilot/add-advanced-features-implementation"
$MERGE_MSG = "Merge PR #3: Implement comprehensive advanced features (3D simulation, charts, i18n, PWA, testing)"

Write-Host "🚀 بدء عملية دمج PR #3..." -ForegroundColor Cyan
Write-Host ""

# التحقق من وجود Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ خطأ: Git غير مثبت. يرجى تثبيت Git أولاً." -ForegroundColor Red
    exit 1
}

# إنشاء مجلد مؤقت للعمل
$WORK_DIR = "$env:TEMP\btec-merge-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null
Set-Location $WORK_DIR

Write-Host "📂 مجلد العمل: $WORK_DIR" -ForegroundColor Yellow
Write-Host ""

try {
    # 1. استنساخ المستودع
    Write-Host "📥 استنساخ المستودع..." -ForegroundColor Cyan
    git clone $REPO_URL
    if ($LASTEXITCODE -ne 0) { throw "فشل استنساخ المستودع" }
    
    Set-Location $REPO_NAME
    
    # 2. جلب كل التحديثات
    Write-Host "🔄 جلب التحديثات..." -ForegroundColor Cyan
    git fetch origin --prune
    if ($LASTEXITCODE -ne 0) { throw "فشل جلب التحديثات" }
    
    # 3. التبديل إلى base branch
    Write-Host "🌿 التبديل إلى $BASE_BRANCH..." -ForegroundColor Cyan
    git checkout $BASE_BRANCH
    if ($LASTEXITCODE -ne 0) { throw "فشل التبديل إلى $BASE_BRANCH" }
    
    git pull origin $BASE_BRANCH
    if ($LASTEXITCODE -ne 0) { throw "فشل تحديث $BASE_BRANCH" }
    
    # 4. جلب فرع الـ PR
    Write-Host "📦 جلب فرع PR #$PR_NUMBER..." -ForegroundColor Cyan
    git fetch origin "pull/$PR_NUMBER/head:pr-$PR_NUMBER"
    if ($LASTEXITCODE -ne 0) { throw "فشل جلب فرع الـ PR" }
    
    git checkout "pr-$PR_NUMBER"
    if ($LASTEXITCODE -ne 0) { throw "فشل التبديل إلى فرع الـ PR" }
    
    # 5. إعادة تطبيق على base (rebase) لحل التعارضات
    Write-Host "🔧 إعادة تطبيق التغييرات على $BASE_BRANCH..." -ForegroundColor Cyan
    git rebase $BASE_BRANCH
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ تم اكتشاف تعارضات!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "الملفات التي تحتوي على تعارضات:" -ForegroundColor Yellow
        git status --short | Where-Object { $_ -match "^UU" }
        Write-Host ""
        Write-Host "لحل التعارضات:" -ForegroundColor Cyan
        Write-Host "  1. افتح الملفات المذكورة أعلاه" -ForegroundColor White
        Write-Host "  2. ابحث عن علامات <<<<<<< و ======= و >>>>>>>" -ForegroundColor White
        Write-Host "  3. احذف العلامات واختر التغييرات الصحيحة" -ForegroundColor White
        Write-Host "  4. بعد الانتهاء، شغّل هذه الأوامر:" -ForegroundColor White
        Write-Host ""
        Write-Host "     git add ." -ForegroundColor Green
        Write-Host "     git rebase --continue" -ForegroundColor Green
        Write-Host "     git push --force-with-lease origin pr-$PR_NUMBER" -ForegroundColor Green
        Write-Host ""
        Write-Host "📂 المجلد الحالي: $(Get-Location)" -ForegroundColor Yellow
        
        # فتح المجلد في File Explorer
        explorer.exe .
        
        exit 1
    }
    
    # 6. دفع التحديثات إلى فرع الـ PR (سيحدث GitHub PR)
    Write-Host "⬆️ دفع التغييرات المحدثة..." -ForegroundColor Cyan
    git push --force-with-lease origin "pr-$PR_NUMBER:$PR_BRANCH"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ فشل الدفع. جرّب يدوياً:" -ForegroundColor Yellow
        Write-Host "   git push --force-with-lease origin pr-$PR_NUMBER:$PR_BRANCH" -ForegroundColor White
    }
    
    # 7. التبديل إلى base والدمج
    Write-Host "🔀 الدمج في $BASE_BRANCH..." -ForegroundColor Cyan
    git checkout $BASE_BRANCH
    if ($LASTEXITCODE -ne 0) { throw "فشل التبديل إلى $BASE_BRANCH" }
    
    git merge --no-ff "pr-$PR_NUMBER" -m "$MERGE_MSG"
    if ($LASTEXITCODE -ne 0) { throw "فشل الدمج" }
    
    # 8. دفع التحديثات النهائية
    Write-Host "⬆️ دفع $BASE_BRANCH المحدث..." -ForegroundColor Cyan
    git push origin $BASE_BRANCH
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ فشل الدفع إلى $BASE_BRANCH" -ForegroundColor Yellow
        Write-Host "السبب المحتمل: حماية الفرع (branch protection)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "الحلول:" -ForegroundColor Cyan
        Write-Host "  1. استخدم GitHub UI لدمج PR #3 يدوياً" -ForegroundColor White
        Write-Host "  2. أو استخدم GitHub CLI:" -ForegroundColor White
        Write-Host "     gh pr merge $PR_NUMBER --repo kk121288/BTEC-Smart-Platform-Frontend --merge" -ForegroundColor Green
        Write-Host ""
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ تم الدمج بنجاح!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 الخطوات التالية:" -ForegroundColor Cyan
    Write-Host "  1. تحقق من PR #3: https://github.com/kk121288/BTEC-Smart-Platform-Frontend/pull/$PR_NUMBER" -ForegroundColor White
    Write-Host "  2. حدّث PR #4 ليبني على template المحدث:" -ForegroundColor White
    Write-Host "     gh pr edit 4 --repo kk121288/BTEC-Smart-Platform-Frontend --base $BASE_BRANCH" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ خطأ: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "📂 مجلد العمل: $WORK_DIR" -ForegroundColor Yellow
    Write-Host "يمكنك إكمال العملية يدوياً من هذا المجلد" -ForegroundColor Yellow
    exit 1
}

# تنظيف (اختياري)
Write-Host "🧹 هل تريد حذف مجلد العمل المؤقت؟ (Y/N)" -ForegroundColor Yellow
$cleanup = Read-Host
if ($cleanup -eq "Y" -or $cleanup -eq "y") {
    Set-Location $env:TEMP
    Remove-Item -Path $WORK_DIR -Recurse -Force
    Write-Host "✅ تم التنظيف" -ForegroundColor Green
}
