@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ========================================================
echo   ROBOZINHO DE RELEASE - FAZENDINHA 2D (5 BARREIRAS)
echo ========================================================
echo.
echo [1] Auditar projeto agora (--check)
echo [2] Simular nova versao (--dry-run com Antes vs. Depois)
echo [3] Publicar nova versao completa no GitHub (--publish)
echo [0] Sair
echo.
set /p OP="Escolha uma opcao (1, 2, 3 ou 0): "

if "%OP%"=="0" goto :end

if "%OP%"=="1" (
    python tools\auto_release_bot.py --check
    goto :pause_exit
)

if "%OP%"=="2" (
    set /p BUMP="Tipo de versao (patch / minor / major) [patch]: "
    if "!BUMP!"=="" set BUMP=patch
    set /p TITLE="Titulo curto da correcao/melhoria: "
    set /p BEFORE="Como estava ANTES: "
    set /p AFTER="Como ficou DEPOIS: "
    python tools\auto_release_bot.py --dry-run --bump "!BUMP!" --title "!TITLE!" --before "!BEFORE!" --after "!AFTER!"
    goto :pause_exit
)

if "%OP%"=="3" (
    set /p BUMP="Tipo de versao (patch / minor / major) [patch]: "
    if "!BUMP!"=="" set BUMP=patch
    set /p TITLE="Titulo curto da correcao/melhoria: "
    set /p BEFORE="Como estava ANTES: "
    set /p AFTER="Como ficou DEPOIS: "
    set /p FIXES="Detalhe do bug/item resolvido: "
    python tools\auto_release_bot.py --publish --bump "!BUMP!" --title "!TITLE!" --before "!BEFORE!" --after "!AFTER!" --fixes "!FIXES!"
    goto :pause_exit
)

echo Opcao invalida.

:pause_exit
echo.
pause

:end
endlocal
