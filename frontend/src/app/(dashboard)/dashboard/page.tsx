'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function SimulationDashboard() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  
  // متغيرات التقييم
  const [answer, setAnswer] = useState('');
  const [gradeResult, setGradeResult] = useState<any>(null);
  const [grading, setGrading] = useState(false);

  // 1. جلب البيانات
  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await fetch('http://localhost:8000/api/v1/btec-resources');
        const data = await res.json();
        setStats(data.curriculum_analysis);
        setLoading(false);
      } catch (err) {
        console.error("Error connecting to backend", err);
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // 2. دالة التقييم
  const handleGrade = async () => {
    setGrading(true);
    setGradeResult(null);
    try {
      const res = await fetch('http://localhost:8000/api/v1/ai-grade', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          student_id: "Demo-User",
          unit_name: "Unit 1: Business Environment",
          submission_text: answer
        })
      });
      const result = await res.json();
      setGradeResult(result);
    } catch (err) {
      alert("خطأ: تأكد أن السيرفر يعمل على المنفذ 8000");
    } finally {
      setGrading(false);
    }
  };

  return (
    <main className="min-h-screen bg-slate-950 text-white p-8 font-sans">
      <header className="flex justify-between items-center mb-10 border-b border-slate-800 pb-4">
        <div>
          <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent">
            MetaLearn Pro <span className="text-xs text-gray-500 bg-gray-900 px-2 py-1 rounded ml-2">v2.0 Beta</span>
          </h1>
          <p className="text-gray-400 text-sm mt-1">BTEC Business Level 3 Engine</p>
        </div>
        <div className="flex gap-4 text-xs font-mono">
           <button onClick={() => router.push('/')} className="text-gray-500 hover:text-white mr-4">Logout</button>
           <span className="flex items-center gap-2 px-3 py-1 bg-green-900/30 rounded border border-green-900 text-green-400">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span> AI: ONLINE
          </span>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* RAG Stats */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-slate-900/50 border border-slate-800 rounded-xl p-6 backdrop-blur-sm shadow-xl">
            <h2 className="text-xl font-bold mb-6 flex items-center gap-2 text-blue-400 border-b border-white/10 pb-2">
              📂 Knowledge Base
            </h2>
            {loading ? (
              <p className="text-gray-500 text-center py-4">Loading Curriculum...</p>
            ) : stats ? (
              <div className="space-y-4 animate-in fade-in duration-700">
                <div className="p-4 bg-gradient-to-br from-blue-900/40 to-slate-900 rounded-lg border border-blue-500/30">
                  <div className="text-3xl font-bold text-white">{stats.Levels["L3 Grade 12"] || 0}</div>
                  <div className="text-xs text-blue-300 uppercase tracking-wider">Grade 12 Files</div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-3 bg-slate-800/50 rounded border border-white/5">
                    <div className="text-xl font-bold text-white">{stats.Types["PDF Books"] || 0}</div>
                    <div className="text-[10px] text-gray-400">Textbooks</div>
                  </div>
                  <div className="p-3 bg-slate-800/50 rounded border border-white/5">
                    <div className="text-xl font-bold text-white">{stats.Types["Presentations"] || 0}</div>
                    <div className="text-[10px] text-gray-400">Slides</div>
                  </div>
                </div>
                <div className="text-[10px] text-gray-500 mt-4 pt-4 border-t border-slate-800 text-center">
                  System scanned {stats.Structure.length} resources.
                </div>
              </div>
            ) : (
              <p className="text-red-400 text-center">Connection Failed</p>
            )}
          </div>
        </div>

        {/* AI Assessment */}
        <div className="lg:col-span-2">
          <div className="bg-slate-900/50 border border-slate-800 rounded-xl p-6 backdrop-blur-sm h-full shadow-xl">
            <h2 className="text-xl font-bold mb-6 flex items-center gap-2 text-purple-400 border-b border-white/10 pb-2">
              📝 AI Assessment Simulation
            </h2>
            
            <textarea 
                className="w-full h-48 bg-slate-950 border border-slate-700 rounded-lg p-4 text-white focus:border-purple-500 focus:outline-none transition-all resize-none mb-4"
                placeholder="Type your answer here... Example: 'The business environment impacts strategy due to inflation. Therefore, we must evaluate risks.'"
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
            ></textarea>

            <button 
              onClick={handleGrade}
              disabled={grading || !answer}
              className="w-full py-3 bg-purple-600 hover:bg-purple-500 text-white rounded-lg font-bold transition-all disabled:opacity-50"
            >
              {grading ? 'Analyzing...' : '⚡ Analyze & Grade'}
            </button>

            {gradeResult && (
              <div className={`mt-6 p-6 rounded-lg border-l-4 animate-in fade-in slide-in-from-bottom-4 duration-500 ${
                gradeResult.grade.includes("Distinction") ? "bg-green-900/10 border-l-green-500" :
                gradeResult.grade.includes("Merit") ? "bg-blue-900/10 border-l-blue-500" :
                "bg-yellow-900/10 border-l-yellow-500"
              }`}>
                <h3 className="text-2xl font-bold text-white mb-2">{gradeResult.grade}</h3>
                <p className="text-gray-300">{gradeResult.ai_feedback}</p>
              </div>
            )}
          </div>
        </div>

      </div>
    </main>
  );
}