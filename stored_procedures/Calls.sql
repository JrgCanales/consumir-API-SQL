use rickandmorty_api;

-------------------- EJECUCIÓN DE LOS SP ---------------------
---------------------- sp de inserción -----------------------
EXEC sp_insert_locations;
GO

EXEC sp_insert_episodes;
GO

EXEC sp_insert_characters;
GO

EXEC sp_insert_characters_episodes;
GO

EXEC sp_insert_location_habitants;
GO

----------------------- resto de sp ------------------------
BEGIN
	DECLARE @output VARCHAR(MAX);
	EXEC sp_get_character_by_id @character_id_IN = 1, @result = @output OUTPUT;
	PRINT @output;
END

EXEC sp_get_characters_by_location 1;
GO

EXEC sp_get_characters_by_status 'Alive';
GO