const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export async function greetStudent(name: string) {
  const res = await fetch(`${API_BASE}/api/v1/virtual-tutor/greet`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name }),
  });
  if (!res.ok) throw new Error("Failed to greet student");
  return res.json();
}

export async function getRecommendations(studentId?: number) {
  const url = new URL(`${API_BASE}/api/v1/virtual-tutor/recommendations`);
  if (studentId !== undefined) url.searchParams.set("student_id", String(studentId));
  const res = await fetch(url.toString(), { method: "POST" });
  if (!res.ok) throw new Error("Failed to fetch recommendations");
  return res.json();
}

export async function recordProgress(studentId: number, course: string, progress: number) {
  const res = await fetch(`${API_BASE}/api/v1/virtual-tutor/progress`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ student_id: studentId, course, progress }),
  });
  if (!res.ok) throw new Error("Failed to record progress");
  return res.json();
}

export default { greetStudent, getRecommendations, recordProgress };
