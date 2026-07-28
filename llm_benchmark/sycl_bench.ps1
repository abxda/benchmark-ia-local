# Fase 6a: SYCL (oneAPI) vs CPU vs Vulkan, todos en llama.cpp b10107.
# Sin -fa (bug documentado de corrupcion en Arrow Lake Xe2, issue 19276).
# Prioridad baja para comparabilidad con las mediciones previas.
# NOTA: mantener este archivo en ASCII puro (PowerShell 5.1 lo lee como ANSI).
$ErrorActionPreference = 'Continue'
$B = "D:\ProgramacionLocal\llama_cpp"
$CHAMP = "C:\Users\abel.coronado\.ollama\models\blobs\sha256-1194192cf2a187eb02722edcc3f77b11d21f537048ce04b67ccf8ba78863006a"
$E4B = "$B\gemma-4-E4B-it-Q4_K_M.gguf"
$OUT = "D:\ProgramacionLocal\llm_benchmark\results\sycl"
New-Item -ItemType Directory -Force $OUT | Out-Null

function Run-Bench($tag, $exe, $model, $extra) {
    Write-Output "=== $tag ==="
    $cmdArgs = @('-m', $model, '-p', '512', '-n', '128', '-r', '2', '-o', 'csv') + $extra
    $p = Start-Process -FilePath $exe -ArgumentList $cmdArgs -PassThru -WindowStyle Hidden `
         -RedirectStandardOutput "$OUT\$tag.csv" -RedirectStandardError "$OUT\$tag.err"
    try { $p.PriorityClass = 'BelowNormal' } catch {}
    $p.WaitForExit()
    $csv = Get-Content "$OUT\$tag.csv" -ErrorAction SilentlyContinue
    if ($csv) {
        $rows = $csv | ConvertFrom-Csv
        foreach ($r in $rows) { Write-Output ("  n_prompt={0} n_gen={1} : {2} tok/s" -f $r.n_prompt, $r.n_gen, [math]::Round([double]$r.avg_ts,2)) }
    } else {
        Write-Output "  SIN RESULTADO, ver $tag.err"
        Get-Content "$OUT\$tag.err" -Tail 3 -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "  ! $_" }
    }
}

# Gemma 4 E4B (5 GB, cabe completo en la iGPU de 16.8 GB)
Run-Bench "e4b_cpu"         "$B\b10107_cpu\llama-bench.exe"    $E4B   @('-t','10')
Run-Bench "e4b_sycl_full"   "$B\b10107_sycl\llama-bench.exe"   $E4B   @('-ngl','99')
Run-Bench "e4b_vulkan_full" "$B\b10107_vulkan\llama-bench.exe" $E4B   @('-ngl','99')

# Campeon 30B (17.3 GiB, no cabe completo; offload parcial)
Run-Bench "q30_cpu"         "$B\b10107_cpu\llama-bench.exe"    $CHAMP @('-t','10')
Run-Bench "q30_sycl_24"     "$B\b10107_sycl\llama-bench.exe"   $CHAMP @('-ngl','24','-t','10')

Write-Output "SYCL BENCH TERMINADO"
