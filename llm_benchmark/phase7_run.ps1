# Fase 7: Qwopus3.6-35B-A3B-Coder APEX I-Compact (MoE ~35B totales / ~3B activos, 17.3 GB)
# en el perfil de referencia laptop-ref-ultra5-32gb-1dimm (CPU puro, build b10107).
# Revalidacion del candidato que dio 6/6 en 6.6 min en el desktop con RTX 3060.
# Regla ETHOS: la laptop decide. El desktop propone.
# Contrato identico a la fase 6b (gemma-4-26B-A4B): -t 10, ctx 32768, cache-reuse 256,
# puerto 8080, alias local, thinking off, prioridad BelowNormal, mmap por omision.
# NOTA: mantener en ASCII puro (PowerShell 5.1 lo lee como ANSI).
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark
$B = "D:\ProgramacionLocal\llama_cpp"
$GGUF = "$B\Qwopus3.6-35B-A3B-Coder-APEX-MTP-I-Compact.gguf"
$LABEL = "qwopus3.6-35b-a3b-apex-icompact"

if (-not (Test-Path $GGUF)) { Write-Output "ABORTADO: no existe $GGUF"; exit 1 }

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath "$B\b10107_cpu\llama-server.exe" `
     -ArgumentList @('-m', $GGUF, '-t', '10', '-c', '32768', '--cache-reuse', '256',
                     '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "$B\phase7_server.log" -RedirectStandardError "$B\phase7_server.err"
try { $p.PriorityClass = 'BelowNormal' } catch {}
$ok = $false
foreach ($i in 1..60) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) {
    Write-Output "ABORTADO: servidor Qwopus no responde (posible arquitectura MTP no soportada por b10107)"
    Get-Content "$B\phase7_server.err" -Tail 15
    exit 1
}
Write-Output "SERVIDOR Qwopus listo (PID $($p.Id))"

# Humo: confirmar que el pensamiento queda desactivado y que genera codigo
$body = '{"model":"local","messages":[{"role":"user","content":"Escribe una funcion en R que calcule la media ignorando NA. Solo el codigo."}],"temperature":0,"max_tokens":300,"cache_prompt":false}'
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/chat/completions" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 600
    Write-Output ("HUMO razonamiento presente: " + [bool]$r.choices[0].message.reasoning_content)
    Write-Output ("HUMO tokens generados: " + $r.usage.completion_tokens)
    Write-Output ("HUMO respuesta: " + $r.choices[0].message.content)
} catch { Write-Output "HUMO fallo: $_" }

Write-Output "ETAPA A: Qwopus un turno (velocidad + 6 tareas)"
python bench.py $LABEL --backend llama

Write-Output "ETAPA B: Qwopus x Zero (6 tareas agenticas)"
python bench_zero.py $LABEL

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE7 PIPELINE TERMINADO"
