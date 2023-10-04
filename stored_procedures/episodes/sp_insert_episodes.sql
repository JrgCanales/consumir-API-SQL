CREATE OR ALTER PROCEDURE sp_insert_episodes
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/episode/';
    DECLARE @count INT = 0, @countEpisodes INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

    EXEC sp_HttpClient @url, @info OUT;

	SET @countEpisodes = JSON_VALUE(@info, '$.info.count');

	WHILE (SELECT COUNT(*) FROM dbo.episodes) < (@countEpisodes)
    BEGIN
		SET @count = @count + 1;

        DECLARE @newUrl VARCHAR(MAX) = @url + CAST(@count AS VARCHAR);

        EXEC sp_HttpClient @newUrl, @responseJSON OUT;
		
		DECLARE @id INT = JSON_VALUE(@responseJSON, '$.id');
		DECLARE @name NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.name');
		DECLARE @air_date NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.air_date');
		DECLARE @episode NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.episode');
		DECLARE @urlJSON NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.url');
		DECLARE @created NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.created');

		INSERT INTO dbo.episodes(id, name, air_date, episode, url, created)
            VALUES (@id, @name, @air_date, @episode, @urlJSON, @created);
	END
END

EXEC sp_insert_episodes
