# =============================================================================
# Makefile para COBOL Database API
# Developer: Joaquim Pedro de Morais Filho
# Email: j360074@hotmail.com
# Web: USAcomment.com
# =============================================================================

COBOL = cobc
COBOL_FLAGS = -x -free
BIN_DIR = bin
DB_DIR = db
UPLOAD_DIR = uploads

.PHONY: all clean build-engine build-api run-engine run-api help

all: build-engine build-api
	@echo ""
	@echo "Build concluido com sucesso!"
	@echo "Execute: make run-engine ou make run-api"

# Criar diretorios necessarios
dirs:
	@mkdir -p $(BIN_DIR) $(DB_DIR) $(UPLOAD_DIR)

# Compilar motor de banco de dados
build-engine: dirs
	@echo "Compilando cobol-db-engine.cbl..."
	$(COBOL) $(COBOL_FLAGS) -o $(BIN_DIR)/cobol-db-engine cobol-db-engine.cbl
	@echo "OK: $(BIN_DIR)/cobol-db-engine"

# Compilar API Web
build-api: dirs
	@echo "Compilando cobol-db-api.cbl..."
	$(COBOL) $(COBOL_FLAGS) -o $(BIN_DIR)/cobol-db-api cobol-db-api.cbl
	@echo "OK: $(BIN_DIR)/cobol-db-api"

# Executar motor de banco de dados
run-engine: build-engine
	@echo "Iniciando motor de banco de dados..."
	./$(BIN_DIR)/cobol-db-engine

# Executar API Web
run-api: build-api
	@echo "Iniciando API Web na porta 8080..."
	./$(BIN_DIR)/cobol-db-api

# Limpar arquivos compilados
clean:
	@echo "Limpando arquivos compilados..."
	rm -rf $(BIN_DIR)/*
	@echo "Limpeza concluida."

# Instalar dependencias (Ubuntu/Debian)
install-deps:
	@echo "Instalando GnuCOBOL..."
	sudo apt-get update
	sudo apt-get install -y gnucobol

# Testar compilacao
test: all
	@echo "Testando compilacao..."
	./$(BIN_DIR)/cobol-db-engine --help || true
	./$(BIN_DIR)/cobol-db-api --help || true

# Ajuda
help:
	@echo ""
	@echo "COBOL Database API - Comandos Disponiveis"
	@echo "=========================================="
	@echo ""
	@echo "  make all          - Compilar tudo"
	@echo "  make build-engine - Compilar motor de BD"
	@echo "  make build-api    - Compilar API Web"
	@echo "  make run-engine   - Executar motor de BD"
	@echo "  make run-api      - Executar API Web"
	@echo "  make clean        - Limpar compilados"
	@echo "  make install-deps - Instalar GnuCOBOL"
	@echo "  make test         - Testar compilacao"
	@echo "  make help         - Exibir esta ajuda"
	@echo ""
	@echo "Developer: Joaquim Pedro de Morais Filho"
	@echo "Email: j360074@hotmail.com"
	@echo ""
