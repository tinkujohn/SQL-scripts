USE [demo]
GO

/****** Object:  StoredProcedure [dbo].[QA_CHECK]    Script Date: 03-05-2021 20:09:44 ******/

/* 

SP accepts 3 parameters
 1. Test ID
 2. QA TEST table name
 3. KV pairs of parameters

 Sample execution -  exec dbo.QA_CHECK '3_test', 'qa_tests','tablename = all_products, ids = 560 '
 
 */

ALTER PROC [dbo].[QA_CHECK]
	@id varchar(50),
	@qa_table varchar(100),
	@param_kv_pairs nvarchar(max)
AS
BEGIN
--DECLARE @code nvarchar(1050)
DECLARE @flag varchar(1) = ''
DECLARE @vsql nvarchar(max)
DECLARE @params varchar(100) = ''
DECLARE @sql nvarchar(max)
DECLARE @cnt nvarchar(max)
DECLARE @exp_result nvarchar(max)
DECLARE @paramcnt int
DECLARE @kvcount int
DECLARE @var int
DECLARE @sql_string nvarchar(max)

-- query qa table to get the details of test to be performed
SET @vsql = N' SELECT  @flag  = ENABL, @params = params,  @sql = test_sql, @exp_result = exp_result
						FROM ' + @qa_table + ' where CODE = ''' + @id +'''';
EXECUTE sp_executesql @vsql , N'@flag varchar(1) output, @params varchar(100) output, @sql nvarchar(max) output , 
								@exp_result nvarchar(max) output ', @flag= @flag OUTPUT, @params= @params OUTPUT, 
								@sql = @sql OUTPUT , @exp_result = @exp_result  OUTPUT

IF @flag = 'N' OR @flag is NULL
BEGIN
	PRINT '** TEST NOT ENABLED **'
END 
ELSE
BEGIN
	SELECT @paramcnt = 1 + LEN(@params) - LEN(REPLACE(@params, ',', '')) 
	SELECT @kvcount = LEN(@param_kv_pairs) - LEN(REPLACE(@param_kv_pairs, '=', ''))
	-- check params count passed and expected params count
	IF @kvcount <> @paramcnt
		PRINT ' ERROR : Incorrect Params passed'
	ELSE
		BEGIN
		--execute below SP to build QA sql string
		exec dbo.create_sql @sql, @param_kv_pairs , @paramcnt, @return_string = @sql_string OUTPUT

		-- execute the final QA SQL string
		EXECUTE sp_executesql @sql_string, N'@var int OUTPUT', @var = @var OUTPUT

		PRINT ''
		PRINT 'QA QUERY : ' +  @sql_string
		PRINT 'PARAMS PASSED : ' +@param_kv_pairs
		PRINT 'QA OP : ' + str(@var)
		PRINT 'EXPECTED OP : ' + str(@exp_result)
		PRINT ''

		IF @var = @exp_result
			PRINT 'RESULT - PASS'
		ELSE
			PRINT 'RESULT - FAIL'
		END
END
END
GO


