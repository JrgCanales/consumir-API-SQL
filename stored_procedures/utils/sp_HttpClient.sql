use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_HttpClient @url VARCHAR(MAX), @result VARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @intToken INT,
			@object INT,
			@statusText NVARCHAR(32);

    DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX));

    EXEC @object = sp_OACreate 'MSXML2.XMLHTTP', @intToken OUT;
    EXEC @object = sp_OAMethod @intToken, 'open', NULL, 'GET' , @url, 'false';
    EXEC @object = sp_OAMethod @intToken, 'send';
	EXEC @object = sp_OAGetProperty @intToken, 'statusText', @statusText OUT;

    INSERT INTO @json (Json_Table) EXEC sp_OAGetProperty @intToken, 'responseText';

	IF (@statusText <> 'OK')
	BEGIN
		DECLARE @ErroMsg NVARCHAR(40) = 'An error occurred in the request.';
		PRINT @ErroMsg;

		RETURN;
	END

	SELECT @result = Json_Table FROM @json;
END
