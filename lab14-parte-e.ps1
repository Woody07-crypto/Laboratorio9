# Lab 14 - Parte E: probar Ingress, balanceo y scale
# Uso: .\lab14-parte-e.ps1
# Desde la raiz del repo, con Docker Desktop y el cluster kind-devsecops-lab activos.

$ErrorActionPreference = "Continue"
$env:Path = "$env:USERPROFILE\bin;" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "`n=== 1) Estado del cluster y pods ===" -ForegroundColor Cyan
kubectl cluster-info --context kind-devsecops-lab
kubectl get pods -n ingress-nginx
kubectl get pods -l app=status-api
kubectl get ingress

Write-Host "`n=== 2) Health check ===" -ForegroundColor Cyan
Write-Host "> curl http://localhost/health"
curl.exe -s http://localhost/health
Write-Host ""

Write-Host "`n=== 3) Balanceo de carga (varias peticiones a /) ===" -ForegroundColor Cyan
1..4 | ForEach-Object {
  Write-Host "> curl http://localhost/  (#$_)"
  curl.exe -s -H "Connection: close" http://localhost/
  Write-Host ""
}

Write-Host "`n=== 4) Escalar a 4 replicas ===" -ForegroundColor Cyan
Write-Host "> kubectl scale deployment status-api --replicas=4"
kubectl scale deployment status-api --replicas=4
kubectl wait --for=condition=ready pod -l app=status-api --timeout=120s | Out-Null
Write-Host "> kubectl get pods -l app=status-api"
kubectl get pods -l app=status-api

Write-Host "`n=== 5) Balanceo con 4 replicas ===" -ForegroundColor Cyan
1..8 | ForEach-Object {
  Write-Host "> curl http://localhost/  (#$_)"
  curl.exe -s -H "Connection: close" http://localhost/
  Write-Host ""
}

Write-Host "`n=== Listo ===" -ForegroundColor Green
Write-Host "Tambien puedes abrir en el navegador: http://localhost/"
Write-Host "NO ejecutar la limpieza todavia (kind delete / docker rmi) hasta terminar entregables."
