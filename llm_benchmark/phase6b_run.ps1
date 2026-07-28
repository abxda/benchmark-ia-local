# Fase 6b: gemma-4-26B-A4B (MoE 25.2B totales / 3.8B activos) en CPU con build b10107.
# Es uno de los dos modelos que Simon Couch valido al 90% en helperbench (R).
# Suite de un turno + suite agentica con Zero.
# NOTA: mantener en ASCII puro (PowerShell 5.1 lo lee como ANSI).
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark
$B = "D:\ProgramacionLocal\llama_cpp"
$G26 = "$B\gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf"

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath "$B\b10107_cpu\llama-server.exe" `
     -ArgumentList @('-m', $G26, '-t', '10', '-c', '32768', '--cache-reuse', '256',
                     '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "$B\phase6b_server.log" -RedirectStandardError "$B\phase6b_server.err"
try { $p.PriorityClass = 'BelowNormal' } catch {}
$ok = $false
foreach ($i in 1..48) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) { Write-Output "ABORTADO: servidor gemma-26B no responde"; Get-Content "$B\phase6b_server.err" -Tail 6; exit 1 }
Write-Output "SERVIDOR gemma-26B listo (PID $($p.Id))"

# Humo: confirmar que el pensamiento queda desactivado
$body = '{"model":"local","messages":[{"role":"user","content":"Escribe una funcion en R que calcule la media ignorando NA. Solo el codigo."}],"temperature":0,"max_tokens":300,"cache_prompt":false}'
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/chat/completions" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 300
    Write-Output ("HUMO razonamiento presente: " + [bool]$r.choices[0].message.reasoning_content)
    Write-Output ("HUMO tokens generados: " + $r.usage.completion_tokens)
} catch { Write-Output "HUMO fallo: $_" }

Write-Output "ETAPA M: gemma-4-26b un turno (velocidad + 6 tareas)"
python bench.py gemma-4-26b-a4b --backend llama

Write-Output "ETAPA N: gemma-4-26b x Zero (6 tareas)"
python bench_zero.py gemma-4-26b-a4b

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE6B PIPELINE TERMINADO"
