# Expurgo Tabela Oracle Script
Sistema Simples e Prático para realizar o Expurgo de dados de uma tabela


Com esse script é possível realizar e programar um sistema de expurgo sobre qualquer tabela no banco de dados Oracle.


# Modo de Usar

Para apresentar o funcionamento deste sistema de expurgo realizei a criação de dois owner, um responsável pelo script de Expugo e outro dono da tabela que vai sofrer o expurgo.

   **Criação dos Owners**

   ```sql     
      -- Owner responsável pelo Expurgo
      CREATE USER WDS_EXPURGO IDENTIFIED BY WDS_EXPURGO;
      
      GRANT CREATE SESSION TO WDS_EXPURGO;
      GRANT UNLIMITED TABLESPACE TO WDS_EXPURGO;
      GRANT CREATE TABLE TO WDS_EXPURGO;
      GRANT CREATE SEQUENCE TO WDS_EXPURGO;
      GRANT CREATE PROCEDURE TO WDS_EXPURGO;
      
      --
      -- Grants sobre as tabelas que vão sofrer Expurgo
      GRANT SELECT, DELETE ON WDS_TESTE_EXPURGO.TESTE_EXPURGO TO WDS_EXPURGO;
      
      ----
      ---- INICIO CRIA AMBIENTE DE TESTE
      
      -- Owner usado para teste
      CREATE USER WDS_TESTE_EXPURGO IDENTIFIED BY WDS_TESTE_EXPURGO;
      
      GRANT CREATE SESSION TO WDS_TESTE_EXPURGO;
      GRANT UNLIMITED TABLESPACE TO WDS_TESTE_EXPURGO;
      GRANT CREATE TABLE TO WDS_TESTE_EXPURGO;
   ```

   **Tabela de Teste que vai sofrer o Expurgo**

   ```sql     
      --
      -- Tabela para teste
      CREATE TABLE TESTE_EXPURGO 
      (
        ID NUMBER 
      , NOME VARCHAR2(20) 
      , DATA_CADASTRO DATE 
      );
      
      
      --
      -- Queries de Teste      
      SELECT COUNT(*) FROM WDS_TESTE_EXPURGO.TESTE_EXPURGO;
            
      SELECT
           MIN( DATA_CADASTRO ) DATA_MIN
          ,MAX( DATA_CADASTRO ) DATA_MAX
          ,( MAX( DATA_CADASTRO ) - MIN( DATA_CADASTRO ) ) DIAS_DE_DADOS
      FROM
          WDS_TESTE_EXPURGO.TESTE_EXPURGO;
   ```


    **Script de Carga para simular a quantidade de registros na tabela que vai sofrer expurgo**
    
   ```sql     
            
      --
      -- Realiza a carga de dados na tabela que vai sofrer expurgo
      
      SET SERVEROUTPUT ON;
      
      DECLARE
      
          v_ID NUMBER;
          
          v_DIA_INICIO DATE;
          
          v_CONTADOR_DIA NUMBER := 0;
          
          v_RANDOM_QUANTIDADE_REGISTRO NUMBER;
          
          v_COLUNA_NOME VARCHAR2(20);
      
      BEGIN
          
          FOR X IN 1..20
          LOOP
          
      		v_CONTADOR_DIA := 0;
      	
              v_DIA_INICIO := SYSDATE - 220;
          
              SELECT MAX(ID) INTO v_ID FROM TESTE_EXPURGO;
              
              IF v_ID IS NULL THEN
                  v_ID := 0;
              END IF;
              
          
              DBMS_OUTPUT.PUT_LINE( 'LOOP: ' || X );
              
              WHILE ( v_DIA_INICIO + v_CONTADOR_DIA ) < SYSDATE
              LOOP
                  
                  v_RANDOM_QUANTIDADE_REGISTRO := ceil( dbms_random.value(500,2000) );
                 
                  v_CONTADOR_DIA := v_CONTADOR_DIA + 1;
                 
                  --DBMS_OUTPUT.PUT_LINE( v_DIA_INICIO + v_CONTADOR_DIA || '  -  ' || v_RANDOM_QUANTIDADE_REGISTRO );
                 
                 
                  FOR qtd_add IN 1..v_RANDOM_QUANTIDADE_REGISTRO
                  LOOP
                      
                      v_ID := v_ID + 1;
                      
                      v_COLUNA_NOME := DBMS_RANDOM.string('L',TRUNC(DBMS_RANDOM.value(10,21)));
                  
                      INSERT INTO TESTE_EXPURGO( ID, NOME, DATA_CADASTRO ) VALUES ( v_ID, v_COLUNA_NOME, ( v_DIA_INICIO + v_CONTADOR_DIA ) );
                 
                  END LOOP;
                 
                 COMMIT;
                 
              END LOOP;
              
          END LOOP;
      
      END;
      /

   ```

   
