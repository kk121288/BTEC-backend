# ====================================================================
# سكربت PowerShell لحل تعارضات PR #3
# ====================================================================

$REPO_URL = "https://github.com/kk121288/BTEC-Smart-Platform-Frontend.git"
$REPO_NAME = "BTEC-Smart-Platform-Frontend"
$BASE_BRANCH = "template"
$PR_BRANCH = "copilot/add-advanced-features-implementation"
$WORK_DIR = "$env:TEMP\btec-pr3-fix-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "🔧 حل تعارضات PR #3..." -ForegroundColor Cyan
Write-Host ""

try {
    # 1. Clone المستودع
    Write-Host "📥 استنساخ المستودع..." -ForegroundColor Cyan
    git clone $REPO_URL $WORK_DIR
    if ($LASTEXITCODE -ne 0) { throw "فشل استنساخ المستودع" }
    
    Set-Location $WORK_DIR
    
    # 2. جلب كل الفروع
    Write-Host "🔄 جلب جميع الفروع..." -ForegroundColor Cyan
    git fetch --all
    if ($LASTEXITCODE -ne 0) { throw "فشل جلب الفروع" }
    
    # 3. Checkout فرع PR #3
    Write-Host "🌿 التبديل إلى فرع PR #3..." -ForegroundColor Cyan
    git checkout $PR_BRANCH
    if ($LASTEXITCODE -ne 0) { throw "فشل التبديل إلى فرع PR" }
    
    # 4. Rebase على template لحل التعارضات
    Write-Host "🔧 إعادة التطبيق على $BASE_BRANCH..." -ForegroundColor Cyan
    git rebase "origin/$BASE_BRANCH"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ تم اكتشاف تعارضات!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 الملفات المتعارضة:" -ForegroundColor Yellow
        git diff --name-only --diff-filter=U
        Write-Host ""
        Write-Host "📝 خطوات حل التعارضات:" -ForegroundColor Cyan
        Write-Host "  1. افتح الملفات المذكورة أعلاه" -ForegroundColor White
        Write-Host "  2. ابحث عن علامات التعارض:" -ForegroundColor White
        Write-Host "     <<<<<<< HEAD" -ForegroundColor Red
        Write-Host "     التغييرات من $BASE_BRANCH" -ForegroundColor White
        Write-Host "     =======" -ForegroundColor Red
        Write-Host "     التغييرات من $PR_BRANCH" -ForegroundColor White
        Write-Host "     >>>>>>> commit-message" -ForegroundColor Red
        Write-Host "  3. احذف العلامات واختر التغييرات الصحيحة" -ForegroundColor White
        Write-Host "  4. بعد حل جميع التعارضات، شغّل:" -ForegroundColor White
        Write-Host ""
        Write-Host "     cd $WORK_DIR" -ForegroundColor Green
        Write-Host "     git add ." -ForegroundColor Green
        Write-Host "     git rebase --continue" -ForegroundColor Green
        Write-Host ""
        Write-Host "  5. إذا كنت متأكداً من الحل، ادفع التغييرات:" -ForegroundColor White
        Write-Host "     git push --force-with-lease origin $PR_BRANCH" -ForegroundColor Green
        Write-Host ""
        Write-Host "📂 المجلد الحالي: $WORK_DIR" -ForegroundColor Yellow
        
        # فتح المجلد في File Explorer
        explorer.exe .
        
        # فتح VS Code إذا كان متاحاً
        if (Get-Command code -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "🎯 فتح VS Code..." -ForegroundColor Cyan
            code .
        }
        
        Write-Host ""
        Write-Host "⏸️ السكربت متوقف. بعد حل التعارضات، شغّل الأوامر أعلاه يدوياً." -ForegroundColor Yellow
        exit 1
    }
    
    # 5. دفع التغييرات المحدثة
    Write-Host ""
    Write-Host "✅ لا توجد تعارضات!" -ForegroundColor Green
    Write-Host "⬆️ دفع التغييرات المحدثة..." -ForegroundColor Cyan
    git push --force-with-lease origin $PR_BRANCH
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ فشل الدفع. قد تحتاج إلى صلاحيات." -ForegroundColor Yellow
        Write-Host "جرّب يدوياً من:" -ForegroundColor Yellow
        Write-Host "  cd $WORK_DIR" -ForegroundColor White
        Write-Host "  git push --force-with-lease origin $PR_BRANCH" -ForegroundColor Green
        exit 1
    }
    
    Write-Host ""
    Write-Host "🎉 تم حل التعارضات ودفع التغييرات بنجاح!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 الخطوات التالية:" -ForegroundColor Cyan
    Write-Host "  1. تحقق من PR #3: https://github.com/kk121288/BTEC-Smart-Platform-Frontend/pull/3" -ForegroundColor White
    Write-Host "  2. راجع التغييرات وتأكد من صحتها" -ForegroundColor White
    Write-Host "  3. ادمج PR #3 عبر GitHub UI أو CLI:" -ForegroundColor White
    Write-Host "     gh pr merge 3 --repo kk121288/BTEC-Smart-Platform-Frontend --merge" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ خطأ: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "📂 مجلد العمل: $WORK_DIR" -ForegroundColor Yellow
    Write-Host "يمكنك إكمال العملية يدوياً من هذا المجلد" -ForegroundColor Yellow
    exit 1
}

# تنظيف
Write-Host ""
Write-Host "🧹 هل تريد حذف مجلد العمل المؤقت؟ (Y/N)" -ForegroundColor Yellow
$cleanup = Read-Host
if ($cleanup -eq "Y" -or $cleanup -eq "y") {
    Set-Location $env:TEMP
    Remove-Item -Path $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ تم التنظيف" -ForegroundColor Green
} else {
    Write-Host "📂 المجلد محفوظ في: $WORK_DIR" -ForegroundColor Yellow
}
