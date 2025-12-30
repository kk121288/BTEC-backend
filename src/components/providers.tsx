'use client'

import { ReactNode } from 'react'
import { ThemeProvider } from './providers/ThemeProvider'
import { I18nProvider } from './providers/I18nProvider'
import { SimulationProvider } from './providers/SimulationProvider'

interface ProvidersProps {
  children: ReactNode
}

export function Providers({ children }: ProvidersProps) {
  return (
    <ThemeProvider>
      <I18nProvider>
        <SimulationProvider>
          {children}
        </SimulationProvider>
      </I18nProvider>
    </ThemeProvider>
  )
}
