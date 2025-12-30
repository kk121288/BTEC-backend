@echo off
echo Installing dependencies for BTEC Assessment Engine...
echo.

REM تثبيت تبعيات npm
npm install

echo.
echo Installing additional packages...
echo.

REM تثبيت حزم إضافية
npm install @types/three autoprefixer postcss

echo.
echo Done! Run 'npm run dev' to start development server.
pause
