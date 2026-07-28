# Orquestador fase 4b: espera a que termine el pipeline A y corre KAT x Zero y qwen3.5-4b x Zero.
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark

$CPU = "D:\ProgramacionLocal\llama_cpp\cpu\llama-server.exe"
$KAT = "D:\ProgramacionLocal\llama_cpp\KAT-Coder-V2.5-Dev-IQ4_XS.gguf"
$Q4B = "C:\Users\abel.coronado\.ollama\models\blobs\sha256-81fb60c7daa80fc1123380b98970b320ae233409f0f71a72ed7b9b0d62f40490"

function Start-Server($model, $noThink) {
    Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
    Start-Sleep -Seconds 3
    if ($noThink) { $env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}' }
    else { Remove-Item Env:\LLAMA_ARG_CHAT_TEMPLATE_KWARGS -ErrorAction SilentlyContinue }
    $p = Start-Process -FilePath $CPU -ArgumentList @('-m', $model, '-t', '10', '-c', '32768',
         '--cache-reuse', '256', '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
         -PassThru -WindowStyle Hidden `
         -RedirectStandardOutput "D:\ProgramacionLocal\llama_cpp\phase4b_server.log" `
         -RedirectStandardError "D:\ProgramacionLocal\llama_cpp\phase4b_server.err"
    $p.PriorityClass = 'BelowNormal'
    foreach ($i in 1..36) {
        Start-Sleep -Seconds 5
        try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
              if ($r.status -eq 'ok') { Write-Host "SERVIDOR listo (PID $($p.Id)) tras $($i*5)s"; return $true } } catch {}
    }
    Write-Host "ERROR: servidor no responde tras 180s"
    return $false
}

Write-Output "ETAPA F: esperando a que termine el pipeline A"
$deadline = (Get-Date).AddHours(3)
while ((Get-Date) -lt $deadline) {
    $log = Get-Content "D:\ProgramacionLocal\llm_benchmark\phase4.log" -Raw -ErrorAction SilentlyContinue
    if ($log -match "FASE4 PIPELINE TERMINADO") { break }
    Start-Sleep -Seconds 60
}
if ((Get-Date) -ge $deadline) { Write-Output "ABORTADO: pipeline A no termino en 3h"; exit 1 }

Write-Output "ETAPA G: servidor KAT-Coder (sin pensamiento)"
$ok = Start-Server $KAT $true
if (-not $ok) { Write-Output "ABORTADO en etapa G"; exit 1 }

Write-Output "ETAPA H: KAT-Coder x Zero (6 tareas)"
python bench_zero.py kat-coder-35b-iq4xs

Write-Output "ETAPA I: servidor qwen3.5-4b (sin pensamiento)"
$ok = Start-Server $Q4B $true
if (-not $ok) { Write-Output "ABORTADO en etapa I"; exit 1 }

Write-Output "ETAPA J: qwen3.5-4b x Zero (6 tareas)"
python bench_zero.py qwen3.5-4b

Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
Write-Output "FASE4B PIPELINE TERMINADO"
