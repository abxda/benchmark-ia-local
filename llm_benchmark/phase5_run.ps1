# Orquestador fase 5: Gemma 4 E4B — suite de un turno + suite agentica con Zero.
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark

$CPU = "D:\ProgramacionLocal\llama_cpp\cpu\llama-server.exe"
$GEMMA = "D:\ProgramacionLocal\llama_cpp\gemma-4-E4B-it-Q4_K_M.gguf"

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath $CPU -ArgumentList @('-m', $GEMMA, '-t', '10', '-c', '32768',
     '--cache-reuse', '256', '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "D:\ProgramacionLocal\llama_cpp\phase5_server.log" `
     -RedirectStandardError "D:\ProgramacionLocal\llama_cpp\phase5_server.err"
$p.PriorityClass = 'BelowNormal'
$ok = $false
foreach ($i in 1..36) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) { Write-Output "ABORTADO: servidor gemma no responde"; exit 1 }
Write-Output "SERVIDOR gemma listo (PID $($p.Id))"

Write-Output "ETAPA K: gemma-4-e4b un turno (velocidad + 6 tareas)"
python bench.py gemma-4-e4b --backend llama

Write-Output "ETAPA L: gemma-4-e4b x Zero (6 tareas)"
python bench_zero.py gemma-4-e4b

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE5 PIPELINE TERMINADO"
