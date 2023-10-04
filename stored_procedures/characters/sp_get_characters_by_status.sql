use rickandmorty_api

--habitantes por estado
CREATE OR ALTER PROCEDURE sp_get_characters_by_status @status_IN VARCHAR(25)
AS
BEGIN

	IF @status_IN NOT IN ('Alive', 'Dead', 'unknown')
    BEGIN
        PRINT 'El estado ingresado no es válido!';
        RETURN;
    END

    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/character/';
    DECLARE @count INT = 0, @countCharacters INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

	EXEC sp_HttpClient @url, @info OUT;

	SET @countCharacters = JSON_VALUE(@info, '$.info.count');

	WHILE @count < @countCharacters
	BEGIN
		SET @count = @count + 1;

        DECLARE @newUrl VARCHAR(MAX) = @url + CAST(@count AS VARCHAR);

        EXEC sp_HttpClient @newUrl, @responseJSON OUT;

		IF (JSON_VALUE(@responseJSON, '$.status') = @status_IN)
		BEGIN

			SELECT *
				FROM OPENJSON(@responseJSON)
				WITH (
					id INT,
					name NVARCHAR(255),
					status NVARCHAR(255),
					species NVARCHAR(255),
					gender NVARCHAR(255)
				);
			
		END
		
	END

END

EXEC sp_get_characters_by_status 'Alive'

