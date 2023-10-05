--------------- ACTIVAR OLE AUTOMATION PROCEDURES --------------
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO


------------------- CREACIÓN DE LA BASE DE DATOS -------------------
USE master;

GO
IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'rickandmorty_api'
)

CREATE DATABASE rickandmorty_api
GO

USE rickandmorty_api;

IF OBJECT_ID('locations', 'U') IS NOT NULL
DROP TABLE locations

GO
CREATE TABLE locations
(
    id INT NOT NULL PRIMARY KEY, 
    name NVARCHAR(255) NOT NULL,
    _type NVARCHAR(255) NOT NULL,
    dimension NVARCHAR(255) NOT NULL,
    url NVARCHAR(255) NOT NULL,
    created NVARCHAR(255) NOT NULL
);
GO

IF OBJECT_ID('episodes', 'U') IS NOT NULL
DROP TABLE episodes

GO
CREATE TABLE episodes
(
    id INT NOT NULL PRIMARY KEY, 
    name NVARCHAR(255) NOT NULL,
    air_date NVARCHAR(255) NOT NULL,
    episode NVARCHAR(255) NOT NULL,
    url NVARCHAR(255) NOT NULL,
    created NVARCHAR(255) NOT NULL
);
GO

IF OBJECT_ID('characters', 'U') IS NOT NULL
DROP TABLE characters

GO
CREATE TABLE characters
(
    id INT NOT NULL PRIMARY KEY, 
    name NVARCHAR(255) NOT NULL,
    status NVARCHAR(255) NOT NULL,
    species NVARCHAR(255) NOT NULL,
    _type NVARCHAR(255) NOT NULL,
    gender NVARCHAR(255) NOT NULL,
    location_id INT NOT NULL,
    image NVARCHAR(MAX) NOT NULL,
    url NVARCHAR(255) NOT NULL,
    created NVARCHAR(255) NOT NULL,
    CONSTRAINT fk_location_character FOREIGN KEY (location_id) REFERENCES locations(id)
);
GO

IF OBJECT_ID('characters_episodes', 'U') IS NOT NULL
DROP TABLE characters_episodes

GO
CREATE TABLE characters_episodes
(
    character_id INT NOT NULL,
    episode_id INT NOT NULL,
    CONSTRAINT fk_character FOREIGN KEY (character_id) REFERENCES characters(id),
    CONSTRAINT fk_episode FOREIGN KEY (episode_id) REFERENCES episodes(id),
    PRIMARY KEY (character_id, episode_id)
);
GO

IF OBJECT_ID('locations_habitants', 'U') IS NOT NULL
DROP TABLE locations_habitants

GO
CREATE TABLE locations_habitants
(
	character_id INT NOT NULL,
    location_id INT NOT NULL,
	CONSTRAINT fk_character_location FOREIGN KEY (character_id) REFERENCES characters(id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(id),
    PRIMARY KEY (character_id, location_id)
);
GO


----------- CREACIÓN DE LOS PROCEDIMIENTOS ALMACENADOS -----------
--------------------- sp para obtener datos ----------------------
GO
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
GO


-------------------- sp para inserción de datos ---------------------
GO
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
GO


GO
CREATE OR ALTER PROCEDURE sp_insert_episodes
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/episode/';
    DECLARE @count INT = 0, @countEpisodes INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

    EXEC sp_HttpClient @url, @info OUT;

	SET @countEpisodes = JSON_VALUE(@info, '$.info.count');

	WHILE (SELECT COUNT(*) FROM dbo.episodes) < @countEpisodes
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
GO


GO
CREATE OR ALTER PROCEDURE sp_insert_characters
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/character/';
    DECLARE @count INT = 0, @countCharacters INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX);

	EXEC sp_HttpClient @url, @info OUT;

	SET @countCharacters = JSON_VALUE(@info, '$.info.count');

	WHILE (SELECT COUNT(*) FROM dbo.characters) < (@countCharacters)
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
GO


GO
CREATE OR ALTER PROCEDURE sp_insert_characters_episodes
AS
BEGIN
    DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/episode/';
    DECLARE @count INT = 0, @countEpisodes INT = 0;
    DECLARE @info VARCHAR(MAX), @responseJSON VARCHAR(MAX), @newUrl VARCHAR(MAX);
	EXEC sp_HttpClient @url, @info OUT;

	SET @countEpisodes = JSON_VALUE(@info, '$.info.count');

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
GO


GO
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
GO


-------------------- sp para filtrado de datos ---------------------
GO
CREATE OR ALTER PROCEDURE sp_get_character_by_id @character_id_IN INT, @result VARCHAR(MAX) OUTPUT
AS
BEGIN

	DECLARE @url VARCHAR(MAX) = 'https://rickandmortyapi.com/api/character/' + CAST(@character_id_IN AS VARCHAR);
    DECLARE @responseJSON VARCHAR(MAX);
	EXEC sp_HttpClient @url, @responseJSON OUT;

	SET @result = @responseJSON;

END
GO


GO
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
GO


GO
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
GO

