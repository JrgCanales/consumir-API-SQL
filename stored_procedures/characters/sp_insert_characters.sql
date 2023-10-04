use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_insert_characters
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/character/';
    DECLARE @count INT = 0, @countCharacters INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

	EXEC sp_HttpClient @url, @info OUT;

	SET @countCharacters = JSON_VALUE(@info, '$.info.count');
	--PRINT 'Count: ' + CAST(@countLocations AS VARCHAR(MAX));

	WHILE (SELECT COUNT(*) FROM dbo.characters) < (@countCharacters/90)
	BEGIN
		SET @count = @count + 1;

        DECLARE @newUrl VARCHAR(MAX) = @url + CAST(@count AS VARCHAR);

        EXEC sp_HttpClient @newUrl, @responseJSON OUT;

		DECLARE @locationURL VARCHAR(50) = (select [value] from OPENJSON(@responseJSON, '$.location') where [key] = 'url')
		DECLARE @locationID VARCHAR(30)
		DECLARE @posicionID INT = CHARINDEX('/', REVERSE(@locationURL))
		SET @locationID = RIGHT(@locationURL, @posicionID - 1)
		
		DECLARE @id INT = JSON_VALUE(@responseJSON, '$.id');
		DECLARE @name NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.name');
		DECLARE @status NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.status');
		DECLARE @species NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.species');
		DECLARE @_type NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.type');
		DECLARE @gender NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.gender');
		DECLARE @location int = @locationID;
		DECLARE @image NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.image');
		DECLARE @characterURL NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.url');
		DECLARE @created NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.created')

		INSERT INTO dbo.characters(id, name, status, species, _type, gender, location_id, image, url, created)
            VALUES (@id, @name, @status, @species, @_type, @gender, @location, @image, @characterURL, @created);
	END
END

EXEC sp_insert_characters