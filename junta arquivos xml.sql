/*
CREATED BY �LEF DA SILVA FERNANDES
ON 2021/08/30
TO COBUCCIO PROCESSADORA DE DADOS
*/

BEGIN

DROP TABLE IF EXISTS [dbo].[#TABELA_TESTE];

CREATE TABLE #TABELA_TESTE (LINHA VARCHAR(MAX));

-- O comando 'BULK INSERT' ajuda na importa��o do texto presente no caminho descrito no 'FROM' e joga todo o valor dentro da tabela tempor�ria '#TABELA_TESTE', 
--come�ando pela linha '3' (FISRTSROW  = 3) para ignorar os cabe�alhos e usando o '</Cli>' como fim de linha para separar os registros por clientes.
BULK INSERT #TABELA_TESTE 
FROM 'yourfile.xml'
WITH ( 
FIRSTROW = 3, 
ROWTERMINATOR = '</Cli>'
)

DROP TABLE IF EXISTS [dbo].[#TABELA_XML];

--Por conta do uso do '</Cli>' na importa��o do XML essa parte da string � "jogada no lixo", por�m precisamos dela pra deixar o arquivo completo, 
--ent�o adicionamos o '</Cli>' novamente em cada registro com a concatena��o de strings
SELECT CONCAT(LINHA,'</Cli>') AS LINHA
INTO #TABELA_XML 
FROM (SELECT * FROM #TABELA_TESTE WHERE LINHA NOT LIKE '%Doc3040%') A;


--Faremos a verifica��o de cada cliente informado pela empresa terceirizada. Precisamos juntar os valores desta com os nossos para assim classificar correntamente cada opera��o de cr�dito de nossos clientes.
DECLARE @CONTADOR INT = 0;

WHILE (@CONTADOR < (SELECT COUNT (*) FROM #TABELA_XML))
BEGIN
SET @CONTADOR =  @CONTADOR + 1
PRINT @CONTADOR
END

DECLARE @XML XML

SET @XML = (SELECT TOP 1 LINHA FROM #TABELA_XML)

SELECT @XML.value('(Cli/Op)[1]/@Contrt', 'varchar(45)') AS Contrt, @XML.value('(Cli/Op)[1]/@VlrContr', 'varchar(45)') AS VlrContr

END 
