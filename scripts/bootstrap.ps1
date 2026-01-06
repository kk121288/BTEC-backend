# PowerShell bootstrap for Windows
Set-StrictMode -Version Latest

Write-Output "Bootstrapping backend environment..."
Push-Location backend
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Pop-Location
Write-Output "Backend environment ready. Activate with: .\\backend\\.venv\\Scripts\\Activate.ps1"
