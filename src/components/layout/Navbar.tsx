'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Menu, X, Globe, Sun, Moon } from 'lucide-react'
import { useTheme } from 'next-themes'
import { useTranslation } from 'react-i18next'
import { LanguageSwitcher } from '@/components/ui/LanguageSwitcher'

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false)
  const { theme, setTheme } = useTheme()
  const { t } = useTranslation()

  const navItems = [
    { href: '/', label: t('nav.home') },
    { href: '/dashboard', label: t('nav.dashboard') },
    { href: '/simulation', label: t('nav.simulation') },
    { href: '/assignments', label: t('nav.assignments') },
    { href: '/profile', label: t('nav.profile') },
  ]

  return (
    <nav className="sticky top-0 z-50 bg-white dark:bg-gray-900 shadow-md">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          {/* الشعار */}
          <Link href="/" className="text-xl font-bold text-primary-600">
            BTEC Assessment
          </Link>

          {/* عناصر التنقل للأجهزة الكبيرة */}
          <div className="hidden md:flex space-x-4 rtl:space-x-reverse">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="px-3 py-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800"
              >
                {item.label}
              </Link>
            ))}
          </div>

          {/* الأزرار */}
          <div className="flex items-center space-x-4 rtl:space-x-reverse">
            <LanguageSwitcher />
            
            <button
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800"
            >
              {theme === 'dark' ? <Sun size={20} /> : <Moon size={20} />}
            </button>

            <button
              onClick={() => setIsOpen(!isOpen)}
              className="md:hidden p-2"
            >
              {isOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>

        {/* قائمة الهواتف */}
        {isOpen && (
          <div className="md:hidden pb-4">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="block px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-800"
                onClick={() => setIsOpen(false)}
              >
                {item.label}
              </Link>
            ))}
          </div>
        )}
      </div>
    </nav>
  )
}
