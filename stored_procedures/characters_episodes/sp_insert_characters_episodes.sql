use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_insert_characters_episodes
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/episode/';
    DECLARE @count INT = 0, @countEpisodes INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX), @newUrl VARCHAR(MAX);
	EXEC sp_HttpClient @url, @info OUT;

	SET @countEpisodes = JSON_VALUE(@info, '$.info.count');
	--PRINT 'Count: ' + CAST(@countLocations AS VARCHAR(MAX));

	WHILE @count < @countEpisodes
    BEGIN
		SET @count = @count + 1;
        SET @newUrl = @url + CAST(@count AS VARCHAR);
		
        EXEC sp_HttpClient @newUrl, @responseJSON OUT;

		DECLARE @countCharacters INT = (SELECT COUNT(*) FROM OPENJSON(@responseJSON, '$.characters'));

		IF @countCharacters > 0
		BEGIN
			
			DECLARE @count2 INT = 0;

			WHILE @count2 < @countCharacters
			BEGIN

				DECLARE @CharacterURL VARCHAR(255) = JSON_VALUE(@responseJSON, CONCAT('$.characters[', @count2, ']'));
				DECLARE @positionID INT = CHARINDEX('/', REVERSE(@CharacterURL));

				DECLARE @Character_id VARCHAR(30);
				SET @Character_id = RIGHT(@CharacterURL, @positionID - 1);
				DECLARE @episode_id INT = JSON_VALUE(@responseJSON, '$.id');

				INSERT INTO dbo.characters_episodes(character_id, episode_id)
					VALUES (@Character_id, @episode_id);

				SET @count2 = @count2 + 1;

			END

		END

	END

END

EXEC sp_insert_characters_episodes