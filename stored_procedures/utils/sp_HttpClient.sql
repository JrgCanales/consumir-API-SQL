use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_HttpClient @url VARCHAR(MAX), @result VARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE @token INT;
    DECLARE @ret INT;
    DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX))

    EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
    EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET' , @url, 'false';
    EXEC @ret = sp_OAMethod @token, 'send';

    INSERT INTO @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

    SELECT @result = Json_Table FROM @json;
END

