       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-DB-ENGINE.
       AUTHOR. JOAQUIM-PEDRO-DE-MORAIS-FILHO.
       EMAIL. J360074@HOTMAIL.COM.
       WEBSITE. USACOMMENT.COM.
       DATE-WRITTEN. 2026-07-27.
       REMARKS. Motor de Banco de Dados COBOL com arquivos
                INDEXED para persistencia de dados.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DB-MASTER ASSIGN TO "db/master.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS REC-ID
               ALTERNATE RECORD KEY IS REC-NOME
               FILE STATUS IS FS-STATUS.

           SELECT DB-UPLOADS ASSIGN TO "db/uploads.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS UPL-ID
               ALTERNATE RECORD KEY IS UPL-ORIGEM
               FILE STATUS IS FS-STATUS-UPL.

           SELECT DB-LOG ASSIGN TO "db/audit.log"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS FS-STATUS-LOG.

       DATA DIVISION.
       FILE SECTION.
       FD  DB-MASTER.
       01  DB-RECORD.
           05 REC-ID                 PIC 9(10).
           05 REC-NOME               PIC X(100).
           05 REC-EMAIL              PIC X(100).
           05 REC-TELEFONE           PIC X(20).
           05 REC-CPF-CNPJ           PIC X(18).
           05 REC-ENDERECO           PIC X(200).
           05 REC-CIDADE             PIC X(50).
           05 REC-UF                 PIC X(2).
           05 REC-CEP                PIC X(9).
           05 REC-DATA-NASC          PIC X(10).
           05 REC-SEXO               PIC X(1).
           05 REC-OBSERVACOES        PIC X(500).
           05 REC-STATUS             PIC X(1).
               88 ATIVO              VALUE 'A'.
               88 INATIVO            VALUE 'I'.
               88 BLOQUEADO          VALUE 'B'.
           05 REC-DATA-CADASTRO      PIC X(19).
           05 REC-DATA-ATUALIZACAO   PIC X(19).
           05 REC-USUARIO-ALT        PIC X(50).

       FD  DB-UPLOADS.
       01  UPL-RECORD.
           05 UPL-ID                 PIC 9(10).
           05 UPL-ID-REGISTRO        PIC 9(10).
           05 UPL-NOME-ARQUIVO       PIC X(200).
           05 UPL-CAMINHO            PIC X(500).
           05 UPL-TAMANHO            PIC 9(12).
           05 UPL-TIPO-MIME          PIC X(100).
           05 UPL-EXTENSAO           PIC X(10).
           05 UPL-HASH-MD5           PIC X(32).
           05 UPL-DATA-UPLOAD        PIC X(19).
           05 UPL-STATUS             PIC X(1).
               88 UPLOAD-OK          VALUE 'O'.
               88 UPLOAD-ERRO        VALUE 'E'.
               88 UPLOAD-PENDENTE    VALUE 'P'.

       FD  DB-LOG.
       01  LOG-RECORD.
           05 LOG-DATA-HORA          PIC X(19).
           05 LOG-OPERACAO           PIC X(20).
           05 LOG-TABELA             PIC X(30).
           05 LOG-ID-REGISTRO        PIC 9(10).
           05 LOG-DETALHES           PIC X(500).
           05 LOG-USUARIO            PIC X(50).

       WORKING-STORAGE SECTION.
       01  FS-STATUS                 PIC XX VALUE SPACES.
       01  FS-STATUS-UPL             PIC XX VALUE SPACES.
       01  FS-STATUS-LOG             PIC XX VALUE SPACES.

       01  WS-OPERATION              PIC X(20) VALUE SPACES.
       01  WS-RESULT-CODE            PIC 9(3) VALUE 200.
       01  WS-RESULT-MSG             PIC X(1000) VALUE SPACES.
       01  WS-COUNTER                PIC 9(10) VALUE 0.

       01  WS-CURRENT-TIMESTAMP.
           05 WS-DATE-TODAY.
               10 WS-YEAR            PIC X(4).
               10 WS-MONTH           PIC X(2).
               10 WS-DAY             PIC X(2).
           05 FILLER                 PIC X(1) VALUE SPACES.
           05 WS-TIME-NOW.
               10 WS-HOUR            PIC X(2).
               10 WS-MINUTE          PIC X(2).
               10 WS-SECOND          PIC X(2).

       01  WS-SEARCH-RECORD          PIC X(1000) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-ENGINE.
           DISPLAY "=========================================="
           DISPLAY " COBOL Database Engine v1.0"
           DISPLAY " Developer: Joaquim Pedro de Morais Filho"
           DISPLAY " Email: j360074@hotmail.com"
           DISPLAY "=========================================="
           PERFORM INIT-DATABASE
           PERFORM PROCESS-COMMANDS
           STOP RUN.

       INIT-DATABASE.
           DISPLAY "Inicializando banco de dados..."
           PERFORM OPEN-MASTER
           PERFORM OPEN-UPLOADS
           PERFORM OPEN-LOG
           DISPLAY "Banco de dados inicializado.".

       OPEN-MASTER.
           OPEN I-O DB-MASTER
           IF FS-STATUS = "05" OR FS-STATUS = "35"
               OPEN OUTPUT DB-MASTER
               CLOSE DB-MASTER
               OPEN I-O DB-MASTER
           END-IF
           IF FS-STATUS NOT = "00"
               DISPLAY "ERRO ao abrir master.dat: " FS-STATUS
               STOP RUN
           END-IF.

       OPEN-UPLOADS.
           OPEN I-O DB-UPLOADS
           IF FS-STATUS-UPL = "05" OR FS-STATUS-UPL = "35"
               OPEN OUTPUT DB-UPLOADS
               CLOSE DB-UPLOADS
               OPEN I-O DB-UPLOADS
           END-IF.

       OPEN-LOG.
           OPEN EXTEND DB-LOG
           IF FS-STATUS-LOG = "35"
               OPEN OUTPUT DB-LOG
               CLOSE DB-LOG
               OPEN EXTEND DB-LOG
           END-IF.

       CLOSE-DATABASE.
           CLOSE DB-MASTER
           CLOSE DB-UPLOADS
           CLOSE DB-LOG.

       PROCESS-COMMANDS.
           DISPLAY " "
           DISPLAY "Comandos disponiveis:"
           DISPLAY "  CREATE  - Criar registro"
           DISPLAY "  READ    - Ler registro"
           DISPLAY "  UPDATE  - Atualizar registro"
           DISPLAY "  DELETE  - Excluir registro"
           DISPLAY "  UPLOAD  - Registrar upload"
           DISPLAY "  LIST    - Listar todos"
           DISPLAY "  BIND    - Vincular upload a registro"
           DISPLAY "  QUIT    - Sair"
           DISPLAY " "
           PERFORM GET-COMMAND.

       GET-COMMAND.
           DISPLAY ">> " WITH NO ADVANCING
           ACCEPT WS-OPERATION
           EVALUATE WS-OPERATION
               WHEN "CREATE"
                   PERFORM CMD-CREATE
               WHEN "READ"
                   PERFORM CMD-READ
               WHEN "UPDATE"
                   PERFORM CMD-UPDATE
               WHEN "DELETE"
                   PERFORM CMD-DELETE
               WHEN "UPLOAD"
                   PERFORM CMD-UPLOAD
               WHEN "LIST"
                   PERFORM CMD-LIST
               WHEN "BIND"
                   PERFORM CMD-BIND
               WHEN "QUIT"
                   PERFORM CLOSE-DATABASE
                   DISPLAY "Banco de dados fechado."
               WHEN OTHER
                   DISPLAY "Comando invalido."
           END-EVALUATE
           IF WS-OPERATION NOT = "QUIT"
               PERFORM GET-COMMAND
           END-IF.

       CMD-CREATE.
           DISPLAY "=== CRIAR REGISTRO ==="
           PERFORM GET-NEW-ID
           DISPLAY "Nome: " WITH NO ADVANCING
           ACCEPT REC-NOME
           DISPLAY "Email: " WITH NO ADVANCING
           ACCEPT REC-EMAIL
           DISPLAY "Telefone: " WITH NO ADVANCING
           ACCEPT REC-TELEFONE
           DISPLAY "CPF/CNPJ: " WITH NO ADVANCING
           ACCEPT REC-CPF-CNPJ
           DISPLAY "Endereco: " WITH NO ADVANCING
           ACCEPT REC-ENDERECO
           DISPLAY "Cidade: " WITH NO ADVANCING
           ACCEPT REC-CIDADE
           DISPLAY "UF: " WITH NO ADVANCING
           ACCEPT REC-UF
           DISPLAY "CEP: " WITH NO ADVANCING
           ACCEPT REC-CEP
           DISPLAY "Data Nascimento: " WITH NO ADVANCING
           ACCEPT REC-DATA-NASC
           DISPLAY "Sexo (M/F): " WITH NO ADVANCING
           ACCEPT REC-SEXO
           DISPLAY "Observacoes: " WITH NO ADVANCING
           ACCEPT REC-OBSERVACOES
           MOVE "A" TO REC-STATUS
           PERFORM GET-TIMESTAMP
           MOVE WS-CURRENT-TIMESTAMP TO REC-DATA-CADASTRO
           MOVE WS-CURRENT-TIMESTAMP TO REC-DATA-ATUALIZACAO
           MOVE "SYSTEM" TO REC-USUARIO-ALT
           PERFORM WRITE-RECORD
           PERFORM LOG-OPERATION.

       CMD-READ.
           DISPLAY "=== LER REGISTRO ==="
           DISPLAY "ID: " WITH NO ADVANCING
           ACCEPT REC-ID
           READ DB-MASTER
               KEY IS REC-ID
               INVALID KEY
                   DISPLAY "Registro nao encontrado."
               NOT INVALID KEY
                   PERFORM DISPLAY-RECORD
           END-READ.

       CMD-UPDATE.
           DISPLAY "=== ATUALIZAR REGISTRO ==="
           DISPLAY "ID: " WITH NO ADVANCING
           ACCEPT REC-ID
           READ DB-MASTER
               KEY IS REC-ID
               INVALID KEY
                   DISPLAY "Registro nao encontrado."
               NOT INVALID KEY
                   PERFORM DISPLAY-RECORD
                   DISPLAY "Novo Nome (enter para manter): "
                       WITH NO ADVANCING
                   ACCEPT REC-NOME
                   DISPLAY "Novo Email: " WITH NO ADVANCING
                   ACCEPT REC-EMAIL
                   DISPLAY "Novo Telefone: " WITH NO ADVANCING
                   ACCEPT REC-TELEFONE
                   PERFORM GET-TIMESTAMP
                   MOVE WS-CURRENT-TIMESTAMP
                       TO REC-DATA-ATUALIZACAO
                   REWRITE DB-RECORD
                       INVALID KEY
                           DISPLAY "Erro ao atualizar."
                       NOT INVALID KEY
                           DISPLAY "Registro atualizado."
                   END-REWRITE
           END-READ.

       CMD-DELETE.
           DISPLAY "=== EXCLUIR REGISTRO ==="
           DISPLAY "ID: " WITH NO ADVANCING
           ACCEPT REC-ID
           READ DB-MASTER
               KEY IS REC-ID
               INVALID KEY
                   DISPLAY "Registro nao encontrado."
               NOT INVALID KEY
                   MOVE "I" TO REC-STATUS
                   REWRITE DB-RECORD
                   DISPLAY "Registro marcado como inativo."
           END-READ.

       CMD-UPLOAD.
           DISPLAY "=== REGISTRAR UPLOAD ==="
           PERFORM GET-NEW-UPL-ID
           DISPLAY "ID do Registro: " WITH NO ADVANCING
           ACCEPT UPL-ID-REGISTRO
           DISPLAY "Nome do Arquivo: " WITH NO ADVANCING
           ACCEPT UPL-NOME-ARQUIVO
           DISPLAY "Caminho: " WITH NO ADVANCING
           ACCEPT UPL-CAMINHO
           DISPLAY "Tamanho: " WITH NO ADVANCING
           ACCEPT UPL-TAMANHO
           DISPLAY "Tipo MIME: " WITH NO ADVANCING
           ACCEPT UPL-TIPO-MIME
           DISPLAY "Extensao: " WITH NO ADVANCING
           ACCEPT UPL-EXTENSAO
           MOVE SPACES TO UPL-HASH-MD5
           PERFORM GET-TIMESTAMP
           MOVE WS-CURRENT-TIMESTAMP TO UPL-DATA-UPLOAD
           MOVE "O" TO UPL-STATUS
           WRITE UPL-RECORD
               INVALID KEY
                   DISPLAY "Erro ao salvar upload."
               NOT INVALID KEY
                   DISPLAY "Upload registrado: " UPL-ID
           END-WRITE.

       CMD-BIND.
           DISPLAY "=== VINCULAR UPLOAD ==="
           DISPLAY "ID do Upload: " WITH NO ADVANCING
           ACCEPT UPL-ID
           READ DB-UPLOADS
               KEY IS UPL-ID
               INVALID KEY
                   DISPLAY "Upload nao encontrado."
               NOT INVALID KEY
                   DISPLAY "Vincular ao Registro ID: "
                       WITH NO ADVANCING
                   ACCEPT UPL-ID-REGISTRO
                   REWRITE UPL-RECORD
                       INVALID KEY
                           DISPLAY "Erro ao vincular."
                       NOT INVALID KEY
                           DISPLAY "Upload vinculado com sucesso."
                   END-REWRITE
           END-READ.

       CMD-LIST.
           DISPLAY "=== LISTAR REGISTROS ==="
           MOVE 0 TO WS-COUNTER
           MOVE LOW-VALUES TO REC-ID
           START DB-MASTER KEY IS >= REC-ID
               INVALID KEY
                   DISPLAY "Nenhum registro encontrado."
               NOT INVALID KEY
                   PERFORM LIST-NEXT
           END-START
           DISPLAY "Total: " WS-COUNTER " registros."

       LIST-NEXT.
           READ DB-MASTER NEXT
               AT END
                   CONTINUE
               NOT AT END
                   ADD 1 TO WS-COUNTER
                   DISPLAY "ID:" REC-ID " | " REC-NOME
                       " | " REC-EMAIL " | Status:" REC-STATUS
                   PERFORM LIST-NEXT
           END-READ.

       GET-NEW-ID.
           MOVE 9999999999 TO REC-ID
           START DB-MASTER KEY IS < REC-ID
               INVALID KEY
                   MOVE 1 TO REC-ID
               NOT INVALID KEY
                   READ DB-MASTER PREVIOUS
                       AT END
                           MOVE 1 TO REC-ID
                       NOT AT END
                           ADD 1 TO REC-ID
                   END-READ
           END-START.

       GET-NEW-UPL-ID.
           MOVE 9999999999 TO UPL-ID
           START DB-UPLOADS KEY IS < UPL-ID
               INVALID KEY
                   MOVE 1 TO UPL-ID
               NOT INVALID KEY
                   READ DB-UPLOADS PREVIOUS
                       AT END
                           MOVE 1 TO UPL-ID
                       NOT AT END
                           ADD 1 TO UPL-ID
                   END-READ
           END-START.

       WRITE-RECORD.
           WRITE DB-RECORD
               INVALID KEY
                   DISPLAY "ERRO ao salvar: " FS-STATUS
                   MOVE 500 TO WS-RESULT-CODE
               NOT INVALID KEY
                   DISPLAY "Registro criado com ID: " REC-ID
                   MOVE 200 TO WS-RESULT-CODE
           END-WRITE.

       DISPLAY-RECORD.
           DISPLAY "-----------------------------"
           DISPLAY "ID:            " REC-ID
           DISPLAY "Nome:          " REC-NOME
           DISPLAY "Email:         " REC-EMAIL
           DISPLAY "Telefone:      " REC-TELEFONE
           DISPLAY "CPF/CNPJ:      " REC-CPF-CNPJ
           DISPLAY "Endereco:      " REC-ENDERECO
           DISPLAY "Cidade:        " REC-CIDADE
           DISPLAY "UF:            " REC-UF
           DISPLAY "CEP:           " REC-CEP
           DISPLAY "Nascimento:    " REC-DATA-NASC
           DISPLAY "Sexo:          " REC-SEXO
           DISPLAY "Observacoes:   " REC-OBSERVACOES
           DISPLAY "Status:        " REC-STATUS
           DISPLAY "Cadastro:      " REC-DATA-CADASTRO
           DISPLAY "Atualizacao:   " REC-DATA-ATUALIZACAO
           DISPLAY "-----------------------------".

       GET-TIMESTAMP.
           ACCEPT WS-DATE-TODAY FROM DATE
           ACCEPT WS-TIME-NOW FROM TIME
           STRING WS-YEAR DELIMITED BY SIZE
                  "-" DELIMITED BY SIZE
                  WS-MONTH DELIMITED BY SIZE
                  "-" DELIMITED BY SIZE
                  WS-DAY DELIMITED BY SIZE
                  " " DELIMITED BY SIZE
                  WS-HOUR DELIMITED BY SIZE
                  ":" DELIMITED BY SIZE
                  WS-MINUTE DELIMITED BY SIZE
                  ":" DELIMITED BY SIZE
                  WS-SECOND DELIMITED BY SIZE
                  INTO WS-CURRENT-TIMESTAMP.

       LOG-OPERATION.
           MOVE WS-CURRENT-TIMESTAMP TO LOG-DATA-HORA
           MOVE WS-OPERATION TO LOG-OPERACAO
           MOVE "MASTER" TO LOG-TABELA
           MOVE REC-ID TO LOG-ID-REGISTRO
           STRING "Operacao: " WS-OPERATION
                  " ID: " REC-ID
                  " Nome: " REC-NOME
                  INTO LOG-DETALHES
           END-STRING
           MOVE "SYSTEM" TO LOG-USUARIO
           WRITE LOG-RECORD.
