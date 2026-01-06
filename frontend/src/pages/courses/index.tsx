import React, { useEffect, useState } from "react";
import { api } from "../../lib/api";
import Link from "next/link";

export default function Courses() {
  const [courses, setCourses] = useState<any[]>([]);
  useEffect(()=> {
    api.get("/courses").then((d:any)=> setCourses(d)).catch(()=> setCourses([]));
  }, []);
  return (
    <div className="p-6">
      <h2 className="text-2xl mb-4">Courses</h2>
      <ul>
        {courses.map(c => (
          <li key={c.id}><Link href={`/course/${c.id}`}>{c.title}</Link></li>
        ))}
      </ul>
    </div>
  );
}
