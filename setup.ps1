param(
    [ValidateSet("web", "cli", "streamlit")]
    [string]$LaunchMode = "web"
)

$ErrorActionPreference = "Stop"
$VENV_PATH = "C:\venvs\mainenv"
$VENV_PATH = $VENV_PATH -replace [char]127, ""
$PYTHON_EXE = Join-Path $VENV_PATH "Scripts\python.exe"
$PIP_EXE = Join-Path $VENV_PATH "Scripts\pip.exe"
$STREAMLIT_EXE = Join-Path $VENV_PATH "Scripts\streamlit.exe"
$UVICORN_EXE = Join-Path $VENV_PATH "Scripts\uvicorn.exe"
$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Vensim AI Local Auto Setup ==="
Set-Location $PROJECT_ROOT

function Require-Python {
    try { $null = Get-Command python -ErrorAction Stop }
    catch {
        Write-Host "[ERROR] Python 3.10+ not found in PATH. Python суулгана уу."
        pause
        exit 1
    }
}

Require-Python

if (!(Test-Path $PYTHON_EXE)) {
    Write-Host "[INFO] Global venv not found. Creating: $VENV_PATH"
    if (!(Test-Path "C:\venvs")) { New-Item -ItemType Directory -Path "C:\venvs" | Out-Null }
    python -m venv $VENV_PATH
}

Write-Host "[INFO] Upgrading pip..."
& $PYTHON_EXE -m pip install --upgrade pip

Write-Host "[INFO] Installing required packages..."
& $PIP_EXE install -r requirements.txt

if (!(Test-Path ".env")) {
    if (Test-Path ".env.example") { Copy-Item ".env.example" ".env" }
    Write-Host "[WARN] .env created. OPENAI_API_KEY утгаа оруулна уу, дараа нь дахин ажиллуулна уу."
    pause
    exit 0
}

if (!(Test-Path "models")) { New-Item -ItemType Directory -Path "models" | Out-Null }
if (!(Test-Path "models\Daguul hot.mdl")) { Write-Host "[WARN] models\Daguul hot.mdl файл олдсонгүй." }

if ($LaunchMode -eq "web") {
    Write-Host "[INFO] Starting local web app at http://127.0.0.1:8000"
    & $UVICORN_EXE main:app --host 127.0.0.1 --port 8000 --reload
}
elseif ($LaunchMode -eq "streamlit") {
    Write-Host "[INFO] Starting Streamlit UI..."
    & $STREAMLIT_EXE run streamlit_app.py
}
else {
    Write-Host "[INFO] Starting CLI app..."
    & $PYTHON_EXE run_cli.py
}
