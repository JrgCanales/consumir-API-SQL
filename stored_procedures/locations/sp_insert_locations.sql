use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_insert_locations
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/location/';
    DECLARE @count INT = 0, @countLocations INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

    EXEC sp_HttpClient @url, @info OUT;

	SET @countLocations = JSON_VALUE(@info, '$.info.count');
	--PRINT 'Count: ' + CAST(@countLocations AS VARCHAR(MAX));

	WHILE (SELECT COUNT(*) FROM dbo.locations) < @countLocations
    BEGIN
		SET @count = @count + 1;

        DECLARE @newUrl VARCHAR(MAX) = @url + CAST(@count AS VARCHAR);

        EXEC sp_HttpClient @newUrl, @responseJSON OUT;
		
		DECLARE @id INT = JSON_VALUE(@responseJSON, '$.id');
		DECLARE @name NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.name');
		DECLARE @_type NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.type');
		DECLARE @dimension NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.dimension');
		DECLARE @urlJSON NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.url');
		DECLARE @created NVARCHAR(255) = JSON_VALUE(@responseJSON, '$.created');

		INSERT INTO dbo.locations (id, name, _type, dimension, url, created)
            VALUES (@id, @name, @_type, @dimension, @urlJSON, @created);
	END
END

EXEC sp_insert_locations