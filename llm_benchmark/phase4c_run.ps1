# Orquestador fase 4c: qwen3.5-4b (GGUF mainline) x Zero.
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark

$CPU = "D:\ProgramacionLocal\llama_cpp\cpu\llama-server.exe"
$Q4B = "D:\ProgramacionLocal\llama_cpp\Qwen3.5-4B-Q4_K_M.gguf"

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath $CPU -ArgumentList @('-m', $Q4B, '-t', '10', '-c', '32768',
     '--cache-reuse', '256', '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "D:\ProgramacionLocal\llama_cpp\phase4c_server.log" `
     -RedirectStandardError "D:\ProgramacionLocal\llama_cpp\phase4c_server.err"
$p.PriorityClass = 'BelowNormal'
$ok = $false
foreach ($i in 1..36) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) { Write-Output "ABORTADO: servidor 4b no responde"; exit 1 }
Write-Output "SERVIDOR 4b listo (PID $($p.Id))"

Write-Output "ETAPA J: qwen3.5-4b x Zero (6 tareas)"
python bench_zero.py qwen3.5-4b

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE4C PIPELINE TERMINADO"
