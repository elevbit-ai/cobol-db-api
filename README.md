# COBOL Database API

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![COBOL](https://img.shields.io/badge/Language-COBOL-blue.svg)](https://www.open-cobol.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)]()

Sistema completo de gerenciamento de banco de dados com API web desenvolvido em COBOL puro, incluindo frontend moderno para upload e vinculo de dados.

---

## Desenvolvedor

**Joaquim Pedro de Morais Filho**
- Email: [j360074@hotmail.com](mailto:j360074@hotmail.com)
- Website: [USAcomment.com](http://USAcomment.com)

---

## Funcionalidades

### Backend (COBOL)
- **Motor de Banco de Dados** com arquivos INDEXED
- **CRUD completo** (Create, Read, Update, Delete)
- **Upload de arquivos** com vinculo a registros
- **Sistema de auditoria** com log de operacoes
- **API RESTful** para integracao com sistemas externos

### Frontend (HTML/CSS/JS)
- **Interface responsiva** com design moderno
- **Upload de arrastar e soltar**
- **Gerenciamento de registros** com busca e filtros
- **Vinculo de arquivos** a registros
- **Visualizacao de endpoints** da API
- **Teste de conexao** em tempo real

---

## Arquitetura

```
cobol-db-api/
├── cobol-db-engine.cbl     # Motor de banco de dados INDEXED
├── cobol-db-api.cbl        # Servidor API Web
├── index.html              # Frontend web completo
├── build.bat               # Script de build (Windows)
├── Makefile                # Script de build (Linux/macOS)
├── README.md               # Esta documentacao
└── .gitignore              # Arquivos ignorados pelo Git
```

---

## Requisitos

### Compilador COBOL
- **GnuCOBOL** (recomendado)
  - Download: https://sourceforge.net/projects/gnucobol/
  - Linux: `sudo apt-get install gnucobol`
  - macOS: `brew install gnucobol`

### Navegador Web
- Chrome, Firefox, Edge ou Safari (versao moderna)

---

## Instalacao e Build

### Windows

```batch
build.bat
```

### Linux / macOS

```bash
make all
```

### Manualmente

```bash
# Compilar motor de banco de dados
cobc -x -free -o bin/cobol-db-engine cobol-db-engine.cbl

# Compilar API Web
cobc -x -free -o bin/cobol-db-api cobol-db-api.cbl
```

---

## Uso

### 1. Executar o Motor de Banco de Dados

```bash
# Windows
bin\cobol-db-engine.exe

# Linux/macOS
./bin/cobol-db-engine
```

**Comandos disponiveis:**
- `CREATE` - Criar novo registro
- `READ` - Ler registro por ID
- `UPDATE` - Atualizar registro
- `DELETE` - Excluir registro (logico)
- `UPLOAD` - Registrar upload de arquivo
- `LIST` - Listar todos os registros
- `BIND` - Vincular upload a registro
- `QUIT` - Sair

### 2. Executar a API Web

```bash
# Windows
bin\cobol-db-api.exe

# Linux/macOS
./bin/cobol-db-api
```

A API ficara disponivel em `http://localhost:8080`

### 3. Interface Web

Abra o arquivo `index.html` no navegador para acessar a interface grafica.

---

## Endpoints da API

| Metodo | Endpoint        | Descricao                      |
|--------|-----------------|--------------------------------|
| POST   | `/api/save`     | Salvar novo registro           |
| POST   | `/api/upload`   | Upload de arquivo              |
| POST   | `/api/bind`     | Vincular upload a registro     |
| GET    | `/api/list`     | Listar todos os registros      |
| GET    | `/api/record/{id}` | Obter registro por ID       |

### Exemplo de Requisicao

```bash
# Salvar registro
curl -X POST http://localhost:8080/api/save \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Joaquim Pedro",
    "email": "j360074@hotmail.com",
    "telefone": "(85) 99999-0000",
    "cidade": "Fortaleza",
    "uf": "CE"
  }'
```

### Exemplo de Resposta

```json
{
  "status": "success",
  "message": "Dados salvos com sucesso",
  "data": {
    "id": 1,
    "nome": "Joaquim Pedro",
    "email": "j360074@hotmail.com",
    "data_cadastro": "2026-07-27 14:30:00"
  }
}
```

---

## Estrutura do Banco de Dados

### Tabela MASTER (Registros)

| Campo              | Tipo      | Tamanho | Descricao              |
|--------------------|-----------|---------|------------------------|
| REC-ID             | NUMERICO  | 10      | Identificador unico    |
| REC-NOME           | TEXTO     | 100     | Nome completo          |
| REC-EMAIL          | TEXTO     | 100     | Email                  |
| REC-TELEFONE       | TEXTO     | 20      | Telefone               |
| REC-CPF-CNPJ       | TEXTO     | 18      | CPF ou CNPJ            |
| REC-ENDERECO       | TEXTO     | 200     | Endereco completo      |
| REC-CIDADE         | TEXTO     | 50      | Cidade                 |
| REC-UF             | TEXTO     | 2       | Unidade Federativa     |
| REC-CEP            | TEXTO     | 9       | CEP                    |
| REC-DATA-NASC      | TEXTO     | 10      | Data de nascimento     |
| REC-SEXO           | TEXTO     | 1       | Sexo (M/F)             |
| REC-OBSERVACOES    | TEXTO     | 500     | Observacoes            |
| REC-STATUS         | TEXTO     | 1       | A=Ativo, I=Inativo     |
| REC-DATA-CADASTRO  | TEXTO     | 19      | Data/hora cadastro     |
| REC-DATA-ATUALIZACAO| TEXTO     | 19      | Data/hora atualizacao  |

### Tabela UPLOADS (Arquivos)

| Campo              | Tipo      | Tamanho | Descricao              |
|--------------------|-----------|---------|------------------------|
| UPL-ID             | NUMERICO  | 10      | Identificador unico    |
| UPL-ID-REGISTRO    | NUMERICO  | 10      | ID do registro vinculo |
| UPL-NOME-ARQUIVO   | TEXTO     | 200     | Nome do arquivo        |
| UPL-CAMINHO        | TEXTO     | 500     | Caminho completo       |
| UPL-TAMANHO        | NUMERICO  | 12      | Tamanho em bytes       |
| UPL-TIPO-MIME      | TEXTO     | 100     | Tipo MIME              |
| UPL-EXTENSAO       | TEXTO     | 10      | Extensao do arquivo    |
| UPL-DATA-UPLOAD    | TEXTO     | 19      | Data/hora do upload    |
| UPL-STATUS         | TEXTO     | 1       | O=OK, E=Erro, P=Pend  |

---

## Interface Web

A interface web inclui as seguintes abas:

### Cadastro
Formulario completo para criacao de novos registros com validacao.

### Upload de Arquivos
- Zona de arrastar e soltar
- Suporte multiplos arquivos
- Vinculo opcional a registro
- Barra de progresso

### Registros
- Tabela com todos os registros
- Busca por nome, email ou cidade
- Acoes: Ver, Editar, Excluir
- Status visual (Ativo/Inativo)

### Vinculo de Dados
- Vincular uploads existentes a registros
- Visualizar arquivos vinculados
- Gerenciamento de associacoes

### Endpoints API
- Lista completa de endpoints
- Exemplos de requisicao cURL
- Teste de conexao em tempo real

---

## Tecnologias Utilizadas

- **COBOL** - Linguagem principal do backend
- **GnuCOBOL** - Compilador COBOL open source
- **HTML5** - Estrutura da interface web
- **CSS3** - Estilizacao com variaveis CSS
- **JavaScript** - Logica da interface e comunicacao com API
- **LocalStorage** - Persistencia local de dados
- **Indexed Files** - Sistema de arquivos indexados do COBOL

---

## Contribuicao

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudancas (`git commit -m 'Adicionando nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## Licenca

Este projeto esta licenciado sob a Licenca MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## Contato

**Joaquim Pedro de Morais Filho**
- Email: [j360074@hotmail.com](mailto:j360074@hotmail.com)
- Website: [USAcomment.com](http://USAcomment.com)
- GitHub: [https://github.com/elevbit-ai](https://github.com/elevbit-ai)

---

## Agradecimentos

Desenvolvido com dedicacao e carinho por **Joaquim Pedro de Morais Filho**.

> *"COBOL nao e apenas uma linguagem legada - e uma ferramenta poderosa para sistemas empresariais."*

---

**Copyright 2026 - Joaquim Pedro de Morais Filho - Todos os direitos reservados**
