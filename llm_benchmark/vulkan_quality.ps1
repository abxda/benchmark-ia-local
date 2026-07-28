# Fase 6a-bis: validar CALIDAD del texto generado por Vulkan (offload total, E4B).
# El documento compass advertia de corrupcion Vulkan en Arrow Lake; nunca lo validamos.
# Si el marcador iguala el 4/6 de CPU, Vulkan es apto para produccion.
# NOTA: mantener en ASCII puro.
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark
$B = "D:\ProgramacionLocal\llama_cpp"
$E4B = "$B\gemma-4-E4B-it-Q4_K_M.gguf"

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Start-Sleep -Seconds 3
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}'
$p = Start-Process -FilePath "$B\b10107_vulkan\llama-server.exe" `
     -ArgumentList @('-m', $E4B, '-ngl', '99', '-c', '16384', '--cache-reuse', '256',
                     '-b', '512', '-ub', '128',
                     '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
     -PassThru -WindowStyle Hidden `
     -RedirectStandardOutput "$B\vulkan_q.log" -RedirectStandardError "$B\vulkan_q.err"
try { $p.PriorityClass = 'BelowNormal' } catch {}
$ok = $false
foreach ($i in 1..36) {
    Start-Sleep -Seconds 5
    try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
          if ($r.status -eq 'ok') { $ok = $true; break } } catch {}
}
if (-not $ok) { Write-Output "ABORTADO: servidor Vulkan no responde"; Get-Content "$B\vulkan_q.err" -Tail 5; exit 1 }
Write-Output "SERVIDOR Vulkan listo (PID $($p.Id))"

# Prueba de humo: buscar corrupcion evidente en la salida
$body = '{"model":"local","messages":[{"role":"user","content":"Escribe exactamente esta frase y nada mas: El zorro marron salta sobre el perro perezoso 12345."}],"temperature":0,"max_tokens":80,"cache_prompt":false}'
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/chat/completions" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 300
    Write-Output ("HUMO: " + $r.choices[0].message.content)
} catch { Write-Output "HUMO fallo: $_" }

Write-Output "ETAPA: suite de un turno sobre Vulkan"
python bench.py gemma-4-e4b-vulkan --backend llama

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "VULKAN QUALITY TERMINADO"
