
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

