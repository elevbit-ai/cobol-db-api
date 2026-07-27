@echo off
REM ============================================================================
REM  Build Script para COBOL Database API
REM  Developer: Joaquim Pedro de Morais Filho
REM  Email: j360074@hotmail.com
REM  Web: USAcomment.com
REM ============================================================================

echo.
echo ========================================
echo  COBOL Database API - Build System
echo  Developer: Joaquim Pedro de Morais Filho
echo ========================================
echo.

REM --- Verificar se GnuCOBOL esta instalado ---
where cobc >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERRO] GnuCOBOL (cobc) nao encontrado!
    echo.
    echo Instale o GnuCOBOL:
    echo   Windows: https://sourceforge.net/projects/gnucobol/
    echo   Linux:   sudo apt-get install gnucobol
    echo   macOS:   brew install gnucobol
    echo.
    pause
    exit /b 1
)

echo [INFO] GnuCOBOL encontrado:
cobc --version | findstr /i "cobc"
echo.

REM --- Criar diretorios necessarios ---
if not exist "db" mkdir db
if not exist "uploads" mkdir uploads
if not exist "bin" mkdir bin

REM --- Compilar motor de banco de dados ---
echo [1/3] Compilando cobol-db-engine.cbl...
cobc -x -free -o bin/cobol-db-engine.exe cobol-db-engine.cbl
if %ERRORLEVEL% neq 0 (
    echo [ERRO] Falha ao compilar cobol-db-engine.cbl
    pause
    exit /b 1
)
echo       OK: bin/cobol-db-engine.exe
echo.

REM --- Compilar API Web ---
echo [2/3] Compilando cobol-db-api.cbl...
cobc -x -free -o bin/cobol-db-api.exe cobol-db-api.cbl
if %ERRORLEVEL% neq 0 (
    echo [ERRO] Falha ao compilar cobol-db-api.cbl
    pause
    exit /b 1
)
echo       OK: bin/cobol-db-api.exe
echo.

REM --- Verificar se ha erros de compilacao ---
echo [3/3] Verificando compilacao...
if exist "bin\cobol-db-engine.exe" (
    if exist "bin\cobol-db-api.exe" (
        echo       Todos os compilados gerados com sucesso!
    )
)
echo.

echo ========================================
echo  Build concluido com sucesso!
echo.
echo  Arquivos gerados:
echo    bin\cobol-db-engine.exe  - Motor de banco de dados
echo    bin\cobol-db-api.exe     - Servidor API Web
echo.
echo  Para executar o motor:
echo    bin\cobol-db-engine.exe
echo.
echo  Para executar a API:
echo    bin\cobol-db-api.exe
echo.
echo  Para acessar a interface web:
echo    Abra index.html no navegador
echo ========================================
echo.
pause
