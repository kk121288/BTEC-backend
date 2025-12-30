import { HeroSection } from '@/components/home/HeroSection'
import { FeaturesSection } from '@/components/home/FeaturesSection'
import { SimulationPreview } from '@/components/home/SimulationPreview'

export default function HomePage() {
  return (
    <div className="space-y-16">
      <HeroSection />
      <FeaturesSection />
      <SimulationPreview />
    </div>
  )
}
