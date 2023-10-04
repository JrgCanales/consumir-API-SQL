use rickandmorty_api

--habitantes de una locacion
CREATE OR ALTER PROCEDURE sp_get_characters_by_location @location_id_IN INT
AS
BEGIN

    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/location/' + CAST(@location_id_IN AS VARCHAR);
    DECLARE @count INT = 0, @countCharacters INT = 0;
    DECLARE @responseJSON VARCHAR(MAX), @responseHabitant VARCHAR(MAX);

	EXEC sp_HttpClient @url, @responseJSON OUT;

	SET @countCharacters = JSON_VALUE(@responseJSON, '$.info.count');

	IF (@location_id_IN < 1 OR @location_id_IN > @countCharacters)
    BEGIN
        PRINT 'El id ingresado no es válido!';
        RETURN;
    END
	
	DECLARE @countHabitants INT = (SELECT COUNT(*) FROM OPENJSON(@responseJSON, '$.residents'));

	IF @countHabitants > 0
	BEGIN
		
		SELECT *
			FROM OPENJSON(@responseJSON)
			WITH (
				id INT,
				name NVARCHAR(255)
			);

		WHILE @count < @countHabitants
		BEGIN

			DECLARE @habitantURL VARCHAR(255) = JSON_VALUE(@responseJSON, CONCAT('$.residents[', @count, ']'));
			DECLARE @positionID INT = CHARINDEX('/', REVERSE(@habitantURL));

			DECLARE @habitant_id VARCHAR(30);
			SET @habitant_id = RIGHT(@habitantURL, @positionID - 1);
			
			EXEC sp_get_character_by_id @habitant_id, @responseHabitant OUT;

			SELECT *
				FROM OPENJSON(@responseHabitant)
				WITH (
					id INT,
					name NVARCHAR(255),
					species NVARCHAR(255)
				);

			SET @count = @count + 1;

		END
		
	END

END

EXEC sp_get_characters_by_location 1