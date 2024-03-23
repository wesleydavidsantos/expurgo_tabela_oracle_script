

--
-- Ao executar esse SCRIPT será realizado o expurgo da tabela informada
--

SET SERVEROUTPUT ON;

DECLARE

	CURSOR c_LISTA_ITEM_DELETE( p_DIAS_RETENCAO_DADOS NUMBER ) IS
		SELECT 
			 DISTINCT
			 TRUNC( DATA_CADASTRO ) DATA_CADASTRO     
		FROM
			WDS_TESTE_EXPURGO.TESTE_EXPURGO
		WHERE
			DATA_CADASTRO < SYSDATE - p_DIAS_RETENCAO_DADOS
		ORDER BY DATA_CADASTRO;
			
			
	v_LISTA_ITEM_DELETE c_LISTA_ITEM_DELETE%ROWTYPE;
		
	v_QTD_DELETE_POR_DATA NUMBER;
	
	v_QTD_DELETE_REALIZADOS NUMBER DEFAULT 0;
	
	-- Quantos dias de informações devem ser mantidos na tabela
	v_DIAS_RETENCAO_DADOS CONSTANT NUMBER := 60;
	
BEGIN


	OPEN c_LISTA_ITEM_DELETE( v_DIAS_RETENCAO_DADOS );
	LOOP
	FETCH c_LISTA_ITEM_DELETE INTO v_LISTA_ITEM_DELETE;
	EXIT WHEN c_LISTA_ITEM_DELETE%NOTFOUND;
		
		
		--
		-- Select para avaliar o WHERE para o DELETE
		-- Comentar quando for para PRODUCAO
		SELECT 
			COUNT( ID ) INTO v_QTD_DELETE_POR_DATA
		FROM
			WDS_TESTE_EXPURGO.TESTE_EXPURGO
		WHERE
			ROWID IN ( 
							SELECT 
								ROWID
							FROM
								WDS_TESTE_EXPURGO.TESTE_EXPURGO
							WHERE
								DATA_CADASTRO BETWEEN TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) AND ( TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) + 1 )
					   );
		
				
		--
		-- Em PRODUCAO remover o comentário do DELETE												 
		--DELETE FROM
		--	WDS_TESTE_EXPURGO.TESTE_EXPURGO
		--WHERE
		--	ROWID IN ( 
		--					SELECT 
		--						ROWID
		--					FROM
		--						WDS_TESTE_EXPURGO.TESTE_EXPURGO
		--					WHERE
		--						DATA_CADASTRO BETWEEN TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) AND ( TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) + 1 )
		--			   );
		--
		
		
		--
		-- Informa a quantidade de registros deletados
		-- Em PRODUCAO remover o comentário do DELETE
		--v_QTD_DELETE_POR_DATA := SQL%ROWCOUNT;
		
		
		--
		-- Em PRODUCAO comentar o DBMS_OUTPUT, senão gera erro buffer overflow
		DBMS_OUTPUT.PUT_LINE( 
								'Quantidade de deletes: ' 
								|| v_QTD_DELETE_POR_DATA || ' - Data Inicial: ' 
								|| TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) || ' - Data Final: ' 
								|| ( TRUNC( v_LISTA_ITEM_DELETE.DATA_CADASTRO ) + 1 ) 
							);
		
		
		v_QTD_DELETE_REALIZADOS := v_QTD_DELETE_REALIZADOS + v_QTD_DELETE_POR_DATA;
		
				
		IF v_QTD_DELETE_REALIZADOS > 10000 THEN
		
			v_QTD_DELETE_REALIZADOS := 0;
		
			COMMIT;
			
		END IF;
		
			
	END LOOP;		
	CLOSE c_LISTA_ITEM_DELETE;

END;
/



