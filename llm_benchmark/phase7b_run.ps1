# Fase 7b: solo la suite agentica (Zero) de Qwopus en el perfil de referencia.
# Se separa de phase7_run.ps1 porque la etapa agentica dura ~2 h y debe correr
# desacoplada de cualquier proceso padre con timeout.
# La etapa de un turno ya quedo completa en phase7.log (4/6).
# NOTA: mantener en ASCII puro (PowerShell 5.1 lo lee como ANSI).
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark
$B = "D:\ProgramacionLocal\llama_cpp"
$GGUF = "$B\Qwopus3.6-35B-A3B-Coder-APEX-MTP-I-Compact.gguf"
$LABEL = "qwopus3.6-35b-a3b-apex-icompact"

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath "$B\b10107_cpu\llama-server.exe" `
     -ArgumentList @('-m', $GGUF, '-t', '10', '-c', '32768', '--cache-reuse', '256',
                     '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "$B\phase7b_server.log" -RedirectStandardError "$B\phase7b_server.err"
try { $p.PriorityClass = 'BelowNormal' } catch {}
$ok = $false
foreach ($i in 1..60) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) { Write-Output "ABORTADO: servidor Qwopus no responde"; Get-Content "$B\phase7b_server.err" -Tail 15; exit 1 }
Write-Output "SERVIDOR Qwopus listo (PID $($p.Id))"

Write-Output "ETAPA B: Qwopus x Zero (6 tareas agenticas)"
python bench_zero.py $LABEL

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE7B TERMINADO"
