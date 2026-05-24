# ============================================================
# run_windows.ps1 - Inicia o app Flutter web no Chrome Windows
# ============================================================
# Uso: clique com botão direito > "Executar com PowerShell"
# OU abra PowerShell nesta pasta e execute: .\run_windows.ps1
# ============================================================

$PORT = 8080
$WSL_HOST = "localhost"
$URL = "http://${WSL_HOST}:${PORT}"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Projeto Eleitoral - Iniciando..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se WSL esta disponivel
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] WSL nao encontrado. Instale o WSL primeiro." -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[1/3] Iniciando servidor Flutter via WSL na porta $PORT..." -ForegroundColor Yellow
Write-Host "      URL: $URL" -ForegroundColor Gray
Write-Host ""

# Iniciar Flutter em background via WSL
# --web-hostname=0.0.0.0 garante que o Windows consiga acessar
$flutterJob = Start-Job -ScriptBlock {
    param($port)
    wsl bash -c "cd /mnt/e/projetoeleitoral && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=$port 2>&1"
} -ArgumentList $PORT

Write-Host "[2/3] Aguardando servidor iniciar (15 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Encontrar Chrome ou Edge do Windows
Write-Host "[3/3] Abrindo no Chrome do Windows..." -ForegroundColor Yellow

$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)

$edgePaths = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"
)

$browserFound = $false

foreach ($chrome in $chromePaths) {
    if (Test-Path $chrome) {
        Write-Host "   Abrindo Chrome: $chrome" -ForegroundColor Green
        Start-Process $chrome $URL
        $browserFound = $true
        break
    }
}

if (-not $browserFound) {
    foreach ($edge in $edgePaths) {
        if (Test-Path $edge) {
            Write-Host "   Chrome nao encontrado. Abrindo Edge: $edge" -ForegroundColor Green
            Start-Process $edge $URL
            $browserFound = $true
            break
        }
    }
}

if (-not $browserFound) {
    Write-Host "   Abrindo navegador padrao..." -ForegroundColor Yellow
    Start-Process $URL
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  App rodando em: $URL" -ForegroundColor Green
Write-Host "  O seletor de arquivos usara o" -ForegroundColor Green
Write-Host "  Windows Explorer (nao Linux)." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione ENTER para parar o servidor..." -ForegroundColor Gray
Read-Host

Write-Host "Parando servidor Flutter..." -ForegroundColor Yellow
Stop-Job $flutterJob
Remove-Job $flutterJob
wsl bash -c "pkill -f 'flutter'" 2>$null
Write-Host "Servidor encerrado." -ForegroundColor Green
