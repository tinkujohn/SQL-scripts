USE [demo]
GO

/****** Object:  StoredProcedure [dbo].[create_sql]    Script Date: 03-05-2021 20:15:31 ******/


/* 

SP accepts 2 parameters
 1. SQL string to be replaced
 2. String of parameter kv pairs eg : 'tablename = all_products, ids = 560 '
 3. No of params in KV string

 Sample execution -  exec [dbo].[create_sql] 'select today()','today = get_date()',1
 
 */


ALTER PROC [dbo].[create_sql]
	@input_String nvarchar(max),
	@param_string nvarchar(max),
	@num_params int,
	@return_string nvarchar(max) output
as

BEGIN
DECLARE @tests nvarchar(max) = @param_string
SET @tests = REPLACE(@tests,' ','')
DECLARE @str1 nvarchar(max) = REPLACE(@input_String, 'SELECT', 'SELECT @var = ') 
DECLARE @i int = 0
DECLARE @max int = @num_params
DECLARE @pos_comma int = 0
DECLARE @pos_eq int = 0
DECLARE @searchkv nvarchar(max)
DECLARE @key nvarchar(max) = ''
DECLARE @value nvarchar(max) = ''

while @i < @max
BEGIN
	SET @i = @i + 1
	set @searchkv = substring(@tests, @pos_comma, @pos_comma + cast(replace(str(charindex(',', @tests, @pos_comma )),'0', str(len(@tests)+1)) AS INT))
	--print 'seach kv is :'+ @searchkv
	set @key = substring(@searchkv, @pos_eq, charindex('=', @searchkv, @pos_eq ))
	set @value = substring( @searchkv , charindex('=', @searchkv, @pos_eq)+1, len(@searchkv))
	set @str1 = replace( @str1, @key, @value)
	set @pos_comma = @pos_comma + charindex(',', @tests, @pos_comma) + 1
end
set @return_string = @str1
END
GO


