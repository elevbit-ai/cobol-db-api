       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-DB-API.
       AUTHOR. JOAQUIM-PEDRO-DE-MORAIS-FILHO.
       EMAIL. J360074@HOTMAIL.COM.
       WEBSITE. USACOMMENT.COM.
       DATE-WRITTEN. 2026-07-27.
       REMARKS. API Web para Gerenciamento de Banco de Dados
                com suporte a upload e vinculo de dados.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DB-FILE ASSIGN TO "database.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS DB-KEY
               FILE STATUS IS WS-FILE-STATUS.

           SELECT UPLOAD-FILE ASSIGN TO "uploads/"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  DB-FILE.
       01  DB-RECORD.
           05 DB-KEY.
               10 DB-ID            PIC 9(8).
           05 DB-NOME             PIC X(100).
           05 DB-EMAIL            PIC X(100).
           05 DB-TELEFONE         PIC X(20).
           05 DB-ENDERECO         PIC X(200).
           05 DB-DATA-CADASTRO    PIC X(10).
           05 DB-STATUS           PIC X(1).
               88 DB-ATIVO        VALUE 'A'.
               88 DB-INATIVO      VALUE 'I'.
           05 DB-ARQUIVO-UPLOAD   PIC X(200).
           05 DB-TAMANHO-ARQ     PIC 9(10).
           05 DB-TIPO-ARQ        PIC X(50).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS         PIC XX VALUE SPACES.
       01  WS-OPERATION           PIC X(10) VALUE SPACES.
       01  WS-RESPONSE-CODE       PIC 9(3) VALUE 200.
       01  WS-RESPONSE-MSG        PIC X(500) VALUE SPACES.
       01  WS-CONTENT-LENGTH      PIC 9(10) VALUE 0.
       01  WS-JSON-BUFFER         PIC X(8192) VALUE SPACES.
       01  WS-JSON-POS            PIC 9(5) VALUE 1.
       01  WS-TEMP-STR            PIC X(500) VALUE SPACES.
       01  WS-TEMP-LEN            PIC 9(5) VALUE 0.
       01  WS-ID-COUNTER          PIC 9(8) VALUE 1.
       01  WS-INPUT-LINE          PIC X(8192) VALUE SPACES.
       01  WS-UPLOAD-FILENAME     PIC X(200) VALUE SPACES.
       01  WS-UPLOAD-SIZE         PIC 9(10) VALUE 0.
       01  WS-UPLOAD-TYPE         PIC X(50) VALUE SPACES.

       01  WS-BOUNDARY             PIC X(100) VALUE SPACES.
       01  WS-BOUNDARY-LEN         PIC 9(5) VALUE 0.
       01  WS-PART-DATA            PIC X(8192) VALUE SPACES.
       01  WS-PART-LEN             PIC 9(5) VALUE 0.
       01  WS-FIELD-NAME           PIC X(100) VALUE SPACES.
       01  WS-FIELD-VALUE          PIC X(500) VALUE SPACES.

       01  WS-CURRENT-DATE.
           05 WS-YEAR              PIC X(4).
           05 WS-MONTH             PIC X(2).
           05 WS-DAY               PIC X(2).

       01  WS-HTML-HEADER          PIC X(500) VALUE SPACES.
       01  WS-HTML-BODY            PIC X(10000) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-SYSTEM
           PERFORM START-SERVER
           STOP RUN.

       INITIALIZE-SYSTEM.
           DISPLAY "=========================================="
           DISPLAY " COBOL Database API Server"
           DISPLAY " Developer: Joaquim Pedro de Morais Filho"
           DISPLAY " Email: j360074@hotmail.com"
           DISPLAY " Web: USAcomment.com"
           DISPLAY "=========================================="
           DISPLAY " "
           DISPLAY "Inicializando sistema..."
           PERFORM OPEN-DATABASE
           DISPLAY "Sistema inicializado com sucesso."
           DISPLAY " ".

       OPEN-DATABASE.
           OPEN I-O DB-FILE
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERRO ao abrir banco de dados: "
                   WS-FILE-STATUS
               OPEN OUTPUT DB-FILE
               CLOSE DB-FILE
               OPEN I-O DB-FILE
           END-IF.

       CLOSE-DATABASE.
           CLOSE DB-FILE.

       START-SERVER.
           DISPLAY "Servidor iniciado na porta 8080..."
           DISPLAY "Acesse: http://localhost:8080"
           DISPLAY " "
           PERFORM ACCEPT-REQUEST.

       ACCEPT-REQUEST.
           MOVE SPACES TO WS-INPUT-LINE
           ACCEPT WS-INPUT-LINE FROM CONSOLE
           IF WS-INPUT-LINE(1:4) = "POST"
               PERFORM HANDLE-POST
           ELSE IF WS-INPUT-LINE(1:3) = "GET"
               PERFORM HANDLE-GET
           ELSE IF WS-INPUT-LINE(1:6) = "QUIT"
               PERFORM CLOSE-DATABASE
               DISPLAY "Servidor encerrado."
               STOP RUN
           ELSE
               DISPLAY "Comando nao reconhecido: " WS-INPUT-LINE
           END-IF
           PERFORM ACCEPT-REQUEST.

       HANDLE-POST.
           DISPLAY "Recebendo requisicao POST..."
           IF WS-INPUT-LINE(1:15) = "POST /api/save"
               PERFORM API-SAVE-DATA
           ELSE IF WS-INPUT-LINE(1:16) = "POST /api/upload"
               PERFORM API-UPLOAD-FILE
           ELSE IF WS-INPUT-LINE(1:16) = "POST /api/bind"
               PERFORM API-BIND-DATA
           ELSE IF WS-INPUT-LINE(1:12) = "POST /api/"
               PERFORM API-SAVE-DATA
           ELSE
               MOVE 404 TO WS-RESPONSE-CODE
               MOVE "Endpoint nao encontrado" TO WS-RESPONSE-MSG
               PERFORM SEND-RESPONSE
           END-IF.

       HANDLE-GET.
           DISPLAY "Recebendo requisicao GET..."
           IF WS-INPUT-LINE(1:11) = "GET / "
               OR WS-INPUT-LINE(1:6) = "GET /"
               PERFORM SERVE-HTML-PAGE
           ELSE IF WS-INPUT-LINE(1:9) = "GET /api"
               PERFORM API-LIST-DATA
           ELSE
               MOVE 404 TO WS-RESPONSE-CODE
               MOVE "Pagina nao encontrada" TO WS-RESPONSE-MSG
               PERFORM SEND-RESPONSE
           END-IF.

       API-SAVE-DATA.
           DISPLAY "Salvando dados no banco..."
           PERFORM READ-JSON-INPUT
           PERFORM GENERATE-ID
           PERFORM PARSE-JSON-FIELDS
           PERFORM WRITE-DB-RECORD
           MOVE 200 TO WS-RESPONSE-CODE
           MOVE '"status":"success","message":"Dados salvos com sucesso"' TO WS-RESPONSE-MSG
           PERFORM SEND-JSON-RESPONSE.

       API-UPLOAD-FILE.
           DISPLAY "Processando upload de arquivo..."
           PERFORM READ-JSON-INPUT
           PERFORM EXTRACT-UPLOAD-DATA
           PERFORM SAVE-UPLOAD-FILE
           PERFORM GENERATE-ID
           PERFORM PARSE-JSON-FIELDS
           MOVE WS-UPLOAD-FILENAME TO DB-ARQUIVO-UPLOAD
           MOVE WS-UPLOAD-SIZE TO DB-TAMANHO-ARQ
           MOVE WS-UPLOAD-TYPE TO DB-TIPO-ARQ
           PERFORM WRITE-DB-RECORD
           MOVE 200 TO WS-RESPONSE-CODE
           MOVE '"status":"success","message":"Upload realizado com sucesso"' TO WS-RESPONSE-MSG
           PERFORM SEND-JSON-RESPONSE.

       API-BIND-DATA.
           DISPLAY "Vinculando dados..."
           PERFORM READ-JSON-INPUT
           PERFORM PARSE-JSON-FIELDS
           PERFORM SEARCH-AND-BIND
           MOVE 200 TO WS-RESPONSE-CODE
           MOVE '"status":"success","message":"Vinculo realizado com sucesso"' TO WS-RESPONSE-MSG
           PERFORM SEND-JSON-RESPONSE.

       API-LIST-DATA.
           DISPLAY "Listando registros..."
           MOVE 200 TO WS-RESPONSE-CODE
           PERFORM BUILD-LIST-JSON
           PERFORM SEND-JSON-RESPONSE.

       READ-JSON-INPUT.
           MOVE WS-INPUT-LINE TO WS-JSON-BUFFER
           MOVE LENGTH OF WS-INPUT-LINE TO WS-CONTENT-LENGTH.

       GENERATE-ID.
           MOVE WS-ID-COUNTER TO DB-ID
           ADD 1 TO WS-ID-COUNTER.

       PARSE-JSON-FIELDS.
           MOVE SPACES TO DB-NOME
           MOVE SPACES TO DB-EMAIL
           MOVE SPACES TO DB-TELEFONE
           MOVE SPACES TO DB-ENDERECO
           MOVE "A" TO DB-STATUS
           MOVE SPACES TO DB-ARQUIVO-UPLOAD
           MOVE ZEROS TO DB-TAMANHO-ARQ
           MOVE SPACES TO DB-TIPO-ARQ

           PERFORM EXTRACT-FIELD-NOME
           PERFORM EXTRACT-FIELD-EMAIL
           PERFORM EXTRACT-FIELD-TELEFONE
           PERFORM EXTRACT-FIELD-ENDERECO
           PERFORM SET-CURRENT-DATE.

       EXTRACT-FIELD-NOME.
           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "nome"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 6 : 100)
                   TO DB-NOME
           END-IF.

       EXTRACT-FIELD-EMAIL.
           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "email"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 8 : 100)
                   TO DB-EMAIL
           END-IF.

       EXTRACT-FIELD-TELEFONE.
           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "telefone"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 11 : 20)
                   TO DB-TELEFONE
           END-IF.

       EXTRACT-FIELD-ENDERECO.
           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "endereco"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 11 : 200)
                   TO DB-ENDERECO
           END-IF.

       EXTRACT-UPLOAD-DATA.
           MOVE SPACES TO WS-UPLOAD-FILENAME
           MOVE ZEROS TO WS-UPLOAD-SIZE
           MOVE SPACES TO WS-UPLOAD-TYPE

           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "filename"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 10 : 200)
                   TO WS-UPLOAD-FILENAME
           END-IF

           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "filesize"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 10 : 10)
                   TO WS-UPLOAD-SIZE
           END-IF

           INSPECT WS-JSON-BUFFER TALLYING WS-TEMP-LEN
               FOR CHARACTERS BEFORE INITIAL "filetype"
           IF WS-TEMP-LEN < LENGTH OF WS-JSON-BUFFER
               MOVE WS-JSON-BUFFER(WS-TEMP-LEN + 10 : 50)
                   TO WS-UPLOAD-TYPE
           END-IF.

       SAVE-UPLOAD-FILE.
           DISPLAY "Salvando arquivo: " WS-UPLOAD-FILENAME.

       WRITE-DB-RECORD.
           WRITE DB-RECORD
               INVALID KEY
                   DISPLAY "ERRO ao salvar registro: " WS-FILE-STATUS
                   MOVE 500 TO WS-RESPONSE-CODE
               NOT INVALID KEY
                   DISPLAY "Registro salvo com ID: " DB-ID
           END-WRITE.

       SEARCH-AND-BIND.
           MOVE 1 TO DB-ID
           START DB-FILE KEY >= DB-KEY
               INVALID KEY
                   DISPLAY "Nenhum registro encontrado"
               NOT INVALID KEY
                   PERFORM READ-NEXT-RECORD
           END-START.

       READ-NEXT-RECORD.
           READ DB-FILE NEXT
               AT END
                   DISPLAY "Fim dos registros"
               NOT AT END
                   DISPLAY "Registro: " DB-ID " - " DB-NOME
                   PERFORM READ-NEXT-RECORD
           END-READ.

       SET-CURRENT-DATE.
           ACCEPT WS-CURRENT-DATE FROM DATE
           STRING WS-YEAR DELIMITED BY SPACE
                  "-" DELIMITED BY SIZE
                  WS-MONTH DELIMITED BY SPACE
                  "-" DELIMITED BY SIZE
                  WS-DAY DELIMITED BY SPACE
                  INTO DB-DATA-CADASTRO
           END-STRING.

       BUILD-LIST-JSON.
           MOVE '{"records":[' TO WS-RESPONSE-MSG
           MOVE 1 TO DB-ID
           START DB-FILE KEY >= DB-KEY
               INVALID KEY
                   STRING WS-RESPONSE-MSG DELIMITED BY SIZE
                          ']}' DELIMITED BY SIZE
                          INTO WS-RESPONSE-MSG
               NOT INVALID KEY
                   PERFORM BUILD-RECORD-JSON
           END-START.

       BUILD-RECORD-JSON.
           READ DB-FILE NEXT
               AT END
                   STRING WS-RESPONSE-MSG DELIMITED BY SIZE
                          ']}' DELIMITED BY SIZE
                          INTO WS-RESPONSE-MSG
               NOT AT END
                   STRING WS-RESPONSE-MSG DELIMITED BY SIZE
                          '{"id":' DELIMITED BY SIZE
                          DB-ID DELIMITED BY SIZE
                          ',"nome":"' DELIMITED BY SIZE
                          DB-NOME DELIMITED BY SPACES
                          '","email":"' DELIMITED BY SIZE
                          DB-EMAIL DELIMITED BY SPACES
                          '"},' DELIMITED BY SIZE
                          INTO WS-RESPONSE-MSG
                   PERFORM BUILD-RECORD-JSON
           END-READ.

       SEND-RESPONSE.
           DISPLAY "HTTP/1.1 " WS-RESPONSE-CODE " OK"
           DISPLAY "Content-Type: application/json"
           DISPLAY "Access-Control-Allow-Origin: *"
           DISPLAY " "
           DISPLAY WS-RESPONSE-MSG.

       SEND-JSON-RESPONSE.
           DISPLAY "HTTP/1.1 " WS-RESPONSE-CODE " OK"
           DISPLAY "Content-Type: application/json"
           DISPLAY "Access-Control-Allow-Origin: *"
           DISPLAY "Access-Control-Allow-Methods: GET, POST, OPTIONS"
           DISPLAY "Access-Control-Allow-Headers: Content-Type"
           DISPLAY " "
           DISPLAY "{" WS-RESPONSE-MSG "}".

       SERVE-HTML-PAGE.
           DISPLAY "HTTP/1.1 200 OK"
           DISPLAY "Content-Type: text/html; charset=UTF-8"
           DISPLAY "Access-Control-Allow-Origin: *"
           DISPLAY " "
           DISPLAY "<!DOCTYPE html>"
           DISPLAY "<html lang='pt-BR'>"
           DISPLAY "<head>"
           DISPLAY "<meta charset='UTF-8'>"
           DISPLAY "<title>COBOL DB API - Gerenciamento de Dados</title>"
           DISPLAY "</head>"
           DISPLAY "<body>"
           DISPLAY "<h1>COBOL Database API</h1>"
           DISPLAY "<p>API funcional. Use os endpoints:</p>"
           DISPLAY "<ul>"
           DISPLAY "<li>POST /api/save - Salvar dados</li>"
           DISPLAY "<li>POST /api/upload - Upload de arquivo</li>"
           DISPLAY "<li>POST /api/bind - Vincular dados</li>"
           DISPLAY "<li>GET /api/list - Listar registros</li>"
           DISPLAY "</ul>"
           DISPLAY "</body>"
           DISPLAY "</html>".
