'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async () => {
    setLoading(true);
    
    // محاولة اتصال وهمية لإعطاء شعور بالمعالجة
    setTimeout(() => {
        // ✅ التوجيه إلى لوحة التحكم الصحيحة
        router.push('/dashboard');
    }, 1500); 
  };

  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-slate-950 text-white relative overflow-hidden">
      
      {/* خلفية جمالية متحركة */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-blue-600/20 rounded-full blur-[100px]"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-purple-600/20 rounded-full blur-[100px]"></div>
      </div>

      <div className="z-10 w-full max-w-md p-8 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 shadow-2xl">
        <div className="text-center mb-10">
          <h1 className="text-5xl font-bold bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent mb-2">
            MetaLearn
          </h1>
          <p className="text-gray-400 text-sm tracking-widest uppercase">بوابة الواقع الافتراضي</p>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-gray-400 text-sm mb-2 text-right">رقم المستخدم</label>
            <input 
              type="text" 
              className="w-full p-4 rounded-lg bg-black/30 border border-white/10 text-white focus:border-blue-500 focus:outline-none transition-all text-right"
              placeholder="User ID"
            />
          </div>
          
          <div>
            <label className="block text-gray-400 text-sm mb-2 text-right">مفتاح الوصول</label>
            <input 
              type="password" 
              className="w-full p-4 rounded-lg bg-black/30 border border-white/10 text-white focus:border-blue-500 focus:outline-none transition-all text-right"
              placeholder="••••••••"
            />
          </div>

          <button 
            onClick={handleLogin}
            disabled={loading}
            className="w-full py-4 mt-4 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 rounded-lg font-bold text-lg shadow-lg shadow-blue-500/30 transition-all transform hover:scale-[1.02] active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex justify-center items-center gap-2"
          >
            {loading ? (
              <>
                <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                جاري الاتصال بالنواة...
              </>
            ) : (
              'تفعيل الدخول للنظام'
            )}
          </button>
        </div>

        <div className="mt-8 pt-6 border-t border-white/10 text-center">
          <div className="flex justify-center gap-6 text-xs text-gray-500 font-mono">
            <span className="flex items-center gap-1"><span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span> AI ENGINE: ACTIVE</span>
            <span className="flex items-center gap-1"><span className="w-2 h-2 bg-blue-500 rounded-full"></span> VR SYNC: READY</span>
          </div>
        </div>
      </div>
    </main>
  );
}