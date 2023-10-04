use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_get_character_by_id @character_id_IN INT, @result VARCHAR(MAX) OUTPUT
AS
BEGIN

	DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/character/' + CAST(@character_id_IN AS VARCHAR);
    DECLARE @responseJSON VARCHAR(MAX);
	EXEC sp_HttpClient @url, @responseJSON OUT;

	SET @result = @responseJSON;

END

DECLARE @output VARCHAR(MAX);
EXEC sp_get_character_by_id @character_id_IN = 1, @result = @output OUTPUT;
PRINT @output;