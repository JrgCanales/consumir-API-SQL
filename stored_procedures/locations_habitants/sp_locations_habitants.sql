use rickandmorty_api

CREATE OR ALTER PROCEDURE sp_insert_location_habitants
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/location/';
    DECLARE @count INT = 0, @countLocations INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX), @newUrl VARCHAR(MAX);
	EXEC sp_HttpClient @url, @info OUT;

	SET @countLocations = JSON_VALUE(@info, '$.info.count');
	--PRINT 'Count: ' + CAST(@countLocations AS VARCHAR(MAX));

	WHILE @count < @countLocations
    BEGIN
		SET @count = @count + 1;
        SET @newUrl = @url + CAST(@count AS VARCHAR);
		
        EXEC sp_HttpClient @newUrl, @responseJSON OUT;

		DECLARE @countHabitants INT = (SELECT COUNT(*) FROM OPENJSON(@responseJSON, '$.residents'));

		IF @countHabitants > 0
		BEGIN
			
			DECLARE @count2 INT = 0;

			WHILE @count2 < @countHabitants
			BEGIN

				DECLARE @habitantURL VARCHAR(255) = JSON_VALUE(@responseJSON, CONCAT('$.residents[', @count2, ']'));
				DECLARE @positionID INT = CHARINDEX('/', REVERSE(@habitantURL));

				DECLARE @habitant_id VARCHAR(30);
				SET @habitant_id = RIGHT(@habitantURL, @positionID - 1);
				DECLARE @location_id INT = JSON_VALUE(@responseJSON, '$.id');

				INSERT INTO dbo.locations_habitants(character_id, location_id)
					VALUES (@habitant_id, @location_id);

				SET @count2 = @count2 + 1;

			END

		END

	END

END

EXEC sp_insert_location_habitants
