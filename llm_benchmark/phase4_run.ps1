# Orquestador fase 4 (v2): cola restante de benchmarks agenticos.
# Fixes: kwargs via env var (sin quoting de JSON), Start-Server devuelve solo booleano.
$ErrorActionPreference = 'Continue'
Set-Location D:\ProgramacionLocal\llm_benchmark

$CPU = "D:\ProgramacionLocal\llama_cpp\cpu\llama-server.exe"
$CHAMP = "C:\Users\abel.coronado\.ollama\models\blobs\sha256-1194192cf2a187eb02722edcc3f77b11d21f537048ce04b67ccf8ba78863006a"
$KAT = "D:\ProgramacionLocal\llama_cpp\KAT-Coder-V2.5-Dev-IQ4_XS.gguf"

function Start-Server($model, $noThink) {
    Get-Process llama-server -ErrorAction SilentlyContinue | Stop-Process -Force -Confirm:$false
    Start-Sleep -Seconds 3
    if ($noThink) { $env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS = '{"enable_thinking":false}' }
    else { Remove-Item Env:\LLAMA_ARG_CHAT_TEMPLATE_KWARGS -ErrorAction SilentlyContinue }
    $p = Start-Process -FilePath $CPU -ArgumentList @('-m', $model, '-t', '10', '-c', '32768',
         '--cache-reuse', '256', '--port', '8080', '--host', '127.0.0.1', '-a', 'local') `
         -PassThru -WindowStyle Hidden `
         -RedirectStandardOutput "D:\ProgramacionLocal\llama_cpp\phase4_server.log" `
         -RedirectStandardError "D:\ProgramacionLocal\llama_cpp\phase4_server.err"
    $p.PriorityClass = 'BelowNormal'
    foreach ($i in 1..36) {
        Start-Sleep -Seconds 5
        try { $r = Invoke-RestMethod -Uri "http://127.0.0.1:8080/health" -TimeoutSec 3
              if ($r.status -eq 'ok') { Write-Host "SERVIDOR listo (PID $($p.Id)) tras $($i*5)s"; return $true } } catch {}
    }
    Write-Host "ERROR: servidor no responde tras 180s"
    return $false
}

Write-Output "ETAPA A: servidor KAT-Coder (sin pensamiento)"
$ok = Start-Server $KAT $true
if (-not $ok) { Write-Output "ABORTADO en etapa A"; exit 1 }

Write-Output "ETAPA B: KAT-Coder x Cline (6 tareas)"
python bench_cline.py kat-coder-35b-iq4xs

Write-Output "ETAPA C: regresar servidor al campeon"
$ok = Start-Server $CHAMP $false
if (-not $ok) { Write-Output "ABORTADO en etapa C"; exit 1 }

Write-Output "ETAPA D: humo de Zero"
zero exec --auto high --max-turns 5 -C "D:\ProgramacionLocal\llm_benchmark\work" --output-format text "Responde unicamente con la palabra: listo" 2>&1 | Select-Object -Last 3

Write-Output "ETAPA E: campeon x Zero (6 tareas)"
python bench_zero.py qwen3-coder-30b

Write-Output "FASE4 PIPELINE TERMINADO"
