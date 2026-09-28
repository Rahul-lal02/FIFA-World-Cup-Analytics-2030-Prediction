CREATE TABLE Stg_Teams_2026
(
    team_id INT,
    team_name VARCHAR(100),
    fifa_code VARCHAR(10),
    group_letter VARCHAR(5),
    confederation VARCHAR(50),
    fifa_ranking_pre_tournament INT,
    elo_rating INT,
    manager_name VARCHAR(150)
);

BULK INSERT Stg_Teams_2026
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\teams_2026.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

SELECT *
FROM Stg_Teams_2026;

SELECT COUNT(*) AS Team_Count
FROM Stg_Teams_2026;

SELECT
    s.team_name AS Team_2026,
    d.TeamID,
    d.TeamName
FROM Stg_Teams_2026 s
LEFT JOIN DimTeam d
    ON LOWER(LTRIM(RTRIM(s.team_name))) =
       LOWER(LTRIM(RTRIM(d.TeamName)))
ORDER BY s.team_name;


SELECT
    TeamID,
    TeamName
FROM DimTeam
WHERE
    TeamName LIKE '%United%'
    OR TeamName LIKE '%Korea%'
    OR TeamName LIKE '%Czech%'
    OR TeamName LIKE '%Turkey%'
    OR TeamName LIKE '%Türkiye%'
    OR TeamName LIKE '%USA%'
    OR TeamName LIKE '%Ivoire%'
    OR TeamName LIKE '%Congo%'
    OR TeamName LIKE '%Uzbek%'
    OR TeamName LIKE '%Jordan%'
    OR TeamName LIKE '%Curacao%'
    OR TeamName LIKE '%Curaçao%'
    OR TeamName LIKE '%Verde%';

    SELECT
    TeamID,
    TeamName
FROM DimTeam
WHERE
    TeamName LIKE '%Cape%'
    OR TeamName LIKE '%Congo%'
    OR TeamName LIKE '%Cura%'
    OR TeamName LIKE '%Jordan%'
    OR TeamName LIKE '%Uzbek%';

    SELECT MAX(TeamID) AS Max_TeamID
FROM DimTeam;







INSERT INTO DimTeam (TeamName)
VALUES
    ('Cabo Verde'),
    ('Congo DR'),
    ('Curaçao'),
    ('Jordan'),
    ('Uzbekistan');



    SELECT TeamID, TeamName
FROM DimTeam
WHERE TeamName IN
(
    'Cabo Verde',
    'Congo DR',
    'Curaçao',
    'Jordan',
    'Uzbekistan'
)
ORDER BY TeamID;


CREATE TABLE Stg_Venues_2026
(
    venue_id INT,
    stadium_name VARCHAR(150),
    city VARCHAR(100),
    country VARCHAR(10),
    capacity INT,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    elevation_meters INT
);

BULK INSERT Stg_Venues_2026
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\venues_2026.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

SELECT COUNT(*) AS Venue_Count
FROM Stg_Venues_2026;

SELECT *
FROM Stg_Venues_2026
ORDER BY venue_id;

SELECT
    StadiumID,
    StadiumName
FROM DimStadium
ORDER BY StadiumName;


SELECT TOP 5 *
FROM DimStadium;



INSERT INTO DimStadium (StadiumName, HostCity)
VALUES
('New York New Jersey Stadium (MetLife Stadium)', 'East Rutherford'),
('Los Angeles Stadium (SoFi Stadium)', 'Inglewood'),
('Dallas Stadium (AT&T Stadium)', 'Arlington'),
('Vancouver Stadium (BC Place)', 'Vancouver'),
('Toronto Stadium (BMO Field)', 'Toronto'),
('Guadalajara Stadium (Estadio Akron)', 'Zapopan'),
('Monterrey Stadium (Estadio BBVA)', 'Guadalupe'),
('Atlanta Stadium (Mercedes-Benz Stadium)', 'Atlanta'),
('Boston Stadium (Gillette Stadium)', 'Foxborough'),
('Houston Stadium (NRG Stadium)', 'Houston'),
('Kansas City Stadium (Arrowhead Stadium)', 'Kansas City'),
('Miami Stadium (Hard Rock Stadium)', 'Miami Gardens'),
('Philadelphia Stadium (Lincoln Financial Field)', 'Philadelphia'),
('San Francisco Bay Area Stadium (Levi''s Stadium)', 'Santa Clara'),
('Seattle Stadium (Lumen Field)', 'Seattle');



SELECT
    StadiumID,
    StadiumName,
    HostCity
FROM DimStadium
WHERE StadiumID > 205
ORDER BY StadiumID;


SELECT TOP 3 *
FROM DimWorldCup;


INSERT INTO DimWorldCup
(
    Year,
    Host,
    Teams,
    Champion,
    RunnerUp,
    TopScorer,
    Attendance,
    AttendanceAvg,
    Matches
)
VALUES
(
    2026,
    'Canada, Mexico, USA',
    48,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    104
);


SELECT *
FROM DimWorldCup
WHERE Year = 2026;



CREATE TABLE Stg_Matches_2026
(
    match_id INT,
    match_date DATE,
    kickoff_time_utc TIME,
    stage_id INT,
    venue_id INT,
    home_team_id INT,
    away_team_id INT,
    home_score INT,
    away_score INT,
    home_penalty_score INT NULL,
    away_penalty_score INT NULL,
    status VARCHAR(30),
    result_type VARCHAR(30),
    home_xg DECIMAL(5,2) NULL,
    away_xg DECIMAL(5,2) NULL,
    referee_id INT NULL,
    player_of_the_match_id INT NULL
);





BULK INSERT Stg_Matches_2026
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\matches_2026.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

SELECT COUNT(*) AS Match_Count
FROM Stg_Matches_2026;


SELECT TOP 10 *
FROM Stg_Matches_2026
ORDER BY match_id;



SELECT
    t.team_id AS FIFA2026_TeamID,
    t.team_name AS FIFA2026_TeamName,
    d.TeamID AS Existing_TeamID,
    d.TeamName AS Existing_TeamName
FROM Stg_Teams_2026 t
LEFT JOIN DimTeam d
    ON
        CASE
            WHEN t.team_name = 'Czechia' THEN 'Czech Republic'
            WHEN t.team_name = 'South Korea' THEN 'Korea Republic'
            WHEN t.team_name = 'USA' THEN 'United States'
            ELSE t.team_name
        END = d.TeamName
ORDER BY t.team_id;



UPDATE Stg_Teams_2026
SET team_name = 'Türkiye'
WHERE team_id = 16;

UPDATE Stg_Teams_2026
SET team_name = 'Curaçao'
WHERE team_id = 18;

UPDATE Stg_Teams_2026
SET team_name = 'Côte d''Ivoire'
WHERE team_id = 19;

SELECT
    team_id,
    team_name
FROM Stg_Teams_2026
WHERE team_id IN (16, 18, 19);




SELECT
    t.team_id AS FIFA2026_TeamID,
    t.team_name AS FIFA2026_TeamName,
    d.TeamID AS Existing_TeamID,
    d.TeamName AS Existing_TeamName
FROM Stg_Teams_2026 t
LEFT JOIN DimTeam d
    ON
        CASE
            WHEN t.team_name = 'Czechia' THEN 'Czech Republic'
            WHEN t.team_name = 'South Korea' THEN 'Korea Republic'
            WHEN t.team_name = 'USA' THEN 'United States'
            ELSE t.team_name
        END = d.TeamName
ORDER BY t.team_id;





SELECT
    v.venue_id AS FIFA2026_VenueID,
    v.stadium_name AS FIFA2026_Stadium,
    d.StadiumID AS Existing_StadiumID,
    d.StadiumName AS Existing_Stadium
FROM Stg_Venues_2026 v
LEFT JOIN DimStadium d
    ON
        CASE
            WHEN v.venue_id = 1 THEN 'Estadio Azteca'
            ELSE v.stadium_name
        END = d.StadiumName
ORDER BY v.venue_id;


SELECT TOP 3 *
FROM FactMatch;


CREATE TABLE Stg_Referees_2026
(
    referee_id INT,
    referee_name VARCHAR(150),
    nationality VARCHAR(100),
    confederation VARCHAR(50)
);

BULK INSERT Stg_Referees_2026
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\referees_2026.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

SELECT COUNT(*) AS Referee_Count
FROM Stg_Referees_2026;

SELECT *
FROM Stg_Referees_2026
ORDER BY referee_id;

SELECT TOP 5 *
FROM DimReferee;

EXEC sp_rename
    'Stg_Referees_2026.confederation',
    'RefereeRating',
    'COLUMN';

    ALTER TABLE Stg_Referees_2026
ALTER COLUMN RefereeRating DECIMAL(3,1);

SELECT *
FROM Stg_Referees_2026
ORDER BY referee_id;

SELECT
    s.referee_id AS FIFA2026_RefereeID,
    s.referee_name AS FIFA2026_RefereeName,
    d.RefereeID AS Existing_RefereeID,
    d.RefereeName AS Existing_RefereeName
FROM Stg_Referees_2026 s
LEFT JOIN DimReferee d
    ON s.referee_name = d.RefereeName
ORDER BY s.referee_id;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DimReferee'
  AND COLUMN_NAME = 'RefereeName';


  UPDATE Stg_Referees_2026
SET referee_name = N'Clément Turpin'
WHERE referee_id = 5;

UPDATE Stg_Referees_2026
SET referee_name = N'Jesús Valenzuela'
WHERE referee_id = 7;

UPDATE Stg_Referees_2026
SET referee_name = N'César Arturo Ramos'
WHERE referee_id = 9;

UPDATE Stg_Referees_2026
SET referee_name = N'João Pinheiro'
WHERE referee_id = 17;

UPDATE Stg_Referees_2026
SET referee_name = N'Slavko Vinčić'
WHERE referee_id = 20;

UPDATE Stg_Referees_2026
SET referee_name = N'Saïd Martínez'
WHERE referee_id = 22;

UPDATE Stg_Referees_2026
SET referee_name = N'Espen Eskås'
WHERE referee_id = 25;

UPDATE Stg_Referees_2026
SET referee_name = N'Yael Falcón'
WHERE referee_id = 26;





SELECT
    referee_id,
    referee_name
FROM Stg_Referees_2026
WHERE referee_id IN (5,7,9,17,20,22,25,26)
ORDER BY referee_id;


UPDATE Stg_Referees_2026
SET referee_name = N'Slavko Vinčić'
WHERE referee_id = 20;

SELECT
    referee_id,
    referee_name
FROM Stg_Referees_2026
WHERE referee_id = 20;

ALTER TABLE Stg_Referees_2026
ALTER COLUMN referee_name NVARCHAR(150);

UPDATE Stg_Referees_2026
SET referee_name = N'Slavko Vinčić'
WHERE referee_id = 20;

SELECT
    referee_id,
    referee_name
FROM Stg_Referees_2026
WHERE referee_id = 20;


SELECT
    s.referee_id AS FIFA2026_RefereeID,
    s.referee_name AS FIFA2026_RefereeName,
    d.RefereeID AS Existing_RefereeID,
    d.RefereeName AS Existing_RefereeName
FROM Stg_Referees_2026 s
LEFT JOIN DimReferee d
    ON s.referee_name = d.RefereeName
ORDER BY s.referee_id;









INSERT INTO DimReferee (RefereeName)
VALUES
(N'Ivan Barton'),
(N'Ma Ning'),
(N'Yoshimi Yamashita'),
(N'João Pinheiro'),
(N'Maurizio Mariani'),
(N'Jalal Jayed'),
(N'Slavko Vinčić'),
(N'Adham Makhadmeh'),
(N'Saïd Martínez'),
(N'Glenn Nyberg'),
(N'Espen Eskås'),
(N'Yael Falcón'),
(N'Gustavo Tejera'),
(N'Drew Fischer');




SELECT
    RefereeID,
    RefereeName
FROM DimReferee
WHERE RefereeName IN
(
    N'Ivan Barton',
    N'Ma Ning',
    N'Yoshimi Yamashita',
    N'João Pinheiro',
    N'Maurizio Mariani',
    N'Jalal Jayed',
    N'Slavko Vinčić',
    N'Adham Makhadmeh',
    N'Saïd Martínez',
    N'Glenn Nyberg',
    N'Espen Eskås',
    N'Yael Falcón',
    N'Gustavo Tejera',
    N'Drew Fischer'
)
ORDER BY RefereeID;


SELECT
    s.referee_id AS FIFA2026_RefereeID,
    s.referee_name AS FIFA2026_RefereeName,
    d.RefereeID AS Existing_RefereeID
FROM Stg_Referees_2026 s
LEFT JOIN DimReferee d
    ON s.referee_name = d.RefereeName
ORDER BY s.referee_id;

SELECT
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN home_score IS NOT NULL THEN 1 ELSE 0 END) AS Matches_With_Scores,
    SUM(CASE WHEN home_xg IS NOT NULL THEN 1 ELSE 0 END) AS Matches_With_XG
FROM Stg_Matches_2026;

SELECT TOP 1 *
FROM Stg_Matches_2026;



CREATE TABLE Stg_TournamentStages_2026
(
    stage_id INT,
    stage_name VARCHAR(100),
    stage_order VARCHAR(50)
);

BULK INSERT Stg_TournamentStages_2026
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\tournament_stages_2026.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);


SELECT *
FROM Stg_TournamentStages_2026
ORDER BY stage_id;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FactMatch'
  AND COLUMN_NAME IN ('Round', 'Score', 'Notes');

  SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMNPROPERTY(
        OBJECT_ID('FactMatch'),
        COLUMN_NAME,
        'IsIdentity'
    ) AS IsIdentity
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FactMatch'
ORDER BY ORDINAL_POSITION;



SELECT TOP 10
    MatchID,
    HomeScore,
    AwayScore,
    HomePenalty,
    AwayPenalty,
    Score,
    Notes
FROM FactMatch
WHERE Score IS NOT NULL
ORDER BY MatchID DESC;

SELECT COUNT(*) AS Existing_2026_Matches
FROM FactMatch
WHERE WorldCupID = 23;





INSERT INTO FactMatch
(
    WorldCupID,
    HomeTeamID,
    AwayTeamID,
    StadiumID,
    RefereeID,
    MatchDate,
    Round,
    HomeScore,
    AwayScore,
    HomeXG,
    AwayXG,
    HomePenalty,
    AwayPenalty,
    Attendance,
    Score,
    Notes
)
SELECT
    23 AS WorldCupID,

    -- 2026 Home Team Mapping
    CASE s.home_team_id
        WHEN 1 THEN 47
        WHEN 2 THEN 70
        WHEN 3 THEN 45
        WHEN 4 THEN 20
        WHEN 5 THEN 12
        WHEN 6 THEN 8
        WHEN 7 THEN 59
        WHEN 8 THEN 74
        WHEN 9 THEN 9
        WHEN 10 THEN 48
        WHEN 11 THEN 34
        WHEN 12 THEN 64
        WHEN 13 THEN 81
        WHEN 14 THEN 55
        WHEN 15 THEN 4
        WHEN 16 THEN 78
        WHEN 17 THEN 30
        WHEN 18 THEN 89
        WHEN 19 THEN 17
        WHEN 20 THEN 24
        WHEN 21 THEN 49
        WHEN 22 THEN 43
        WHEN 23 THEN 73
        WHEN 24 THEN 77
        WHEN 25 THEN 6
        WHEN 26 THEN 25
        WHEN 27 THEN 38
        WHEN 28 THEN 50
        WHEN 29 THEN 72
        WHEN 30 THEN 87
        WHEN 31 THEN 63
        WHEN 32 THEN 82
        WHEN 33 THEN 29
        WHEN 34 THEN 65
        WHEN 35 THEN 39
        WHEN 36 THEN 53
        WHEN 37 THEN 3
        WHEN 38 THEN 1
        WHEN 39 THEN 5
        WHEN 40 THEN 90
        WHEN 41 THEN 58
        WHEN 42 THEN 88
        WHEN 43 THEN 91
        WHEN 44 THEN 15
        WHEN 45 THEN 27
        WHEN 46 THEN 18
        WHEN 47 THEN 32
        WHEN 48 THEN 54
    END AS HomeTeamID,

    -- 2026 Away Team Mapping
    CASE s.away_team_id
        WHEN 1 THEN 47
        WHEN 2 THEN 70
        WHEN 3 THEN 45
        WHEN 4 THEN 20
        WHEN 5 THEN 12
        WHEN 6 THEN 8
        WHEN 7 THEN 59
        WHEN 8 THEN 74
        WHEN 9 THEN 9
        WHEN 10 THEN 48
        WHEN 11 THEN 34
        WHEN 12 THEN 64
        WHEN 13 THEN 81
        WHEN 14 THEN 55
        WHEN 15 THEN 4
        WHEN 16 THEN 78
        WHEN 17 THEN 30
        WHEN 18 THEN 89
        WHEN 19 THEN 17
        WHEN 20 THEN 24
        WHEN 21 THEN 49
        WHEN 22 THEN 43
        WHEN 23 THEN 73
        WHEN 24 THEN 77
        WHEN 25 THEN 6
        WHEN 26 THEN 25
        WHEN 27 THEN 38
        WHEN 28 THEN 50
        WHEN 29 THEN 72
        WHEN 30 THEN 87
        WHEN 31 THEN 63
        WHEN 32 THEN 82
        WHEN 33 THEN 29
        WHEN 34 THEN 65
        WHEN 35 THEN 39
        WHEN 36 THEN 53
        WHEN 37 THEN 3
        WHEN 38 THEN 1
        WHEN 39 THEN 5
        WHEN 40 THEN 90
        WHEN 41 THEN 58
        WHEN 42 THEN 88
        WHEN 43 THEN 91
        WHEN 44 THEN 15
        WHEN 45 THEN 27
        WHEN 46 THEN 18
        WHEN 47 THEN 32
        WHEN 48 THEN 54
    END AS AwayTeamID,

    -- Stadium Mapping
    CASE s.venue_id
        WHEN 1 THEN 39
        WHEN 2 THEN 206
        WHEN 3 THEN 207
        WHEN 4 THEN 208
        WHEN 5 THEN 209
        WHEN 6 THEN 210
        WHEN 7 THEN 211
        WHEN 8 THEN 212
        WHEN 9 THEN 213
        WHEN 10 THEN 214
        WHEN 11 THEN 215
        WHEN 12 THEN 216
        WHEN 13 THEN 217
        WHEN 14 THEN 218
        WHEN 15 THEN 219
        WHEN 16 THEN 220
    END AS StadiumID,

    -- Referee Mapping
    r.RefereeID,

    s.match_date AS MatchDate,

    -- Round Mapping
    ts.stage_name AS Round,

    s.home_score AS HomeScore,
    s.away_score AS AwayScore,

    s.home_xg AS HomeXG,
    s.away_xg AS AwayXG,

    s.home_penalty_score AS HomePenalty,
    s.away_penalty_score AS AwayPenalty,

    NULL AS Attendance,

    -- Existing Score format uses an en dash
    CAST(s.home_score AS NVARCHAR(10))
        + N'–' +
    CAST(s.away_score AS NVARCHAR(10)) AS Score,

    NULL AS Notes

FROM Stg_Matches_2026 s

LEFT JOIN Stg_TournamentStages_2026 ts
    ON s.stage_id = ts.stage_id

LEFT JOIN DimReferee r
    ON r.RefereeID =
        CASE s.referee_id
            WHEN 1 THEN 296
            WHEN 2 THEN 87
            WHEN 3 THEN 235
            WHEN 4 THEN 29
            WHEN 5 THEN 79
            WHEN 6 THEN 88
            WHEN 7 THEN 173
            WHEN 8 THEN 318
            WHEN 9 THEN 71
            WHEN 10 THEN 323
            WHEN 11 THEN 240
            WHEN 12 THEN 307
            WHEN 13 THEN 324
            WHEN 14 THEN 17
            WHEN 15 THEN 325
            WHEN 16 THEN 112
            WHEN 17 THEN 326
            WHEN 18 THEN 327
            WHEN 19 THEN 328
            WHEN 20 THEN 329
            WHEN 21 THEN 330
            WHEN 22 THEN 331
            WHEN 23 THEN 265
            WHEN 24 THEN 332
            WHEN 25 THEN 333
            WHEN 26 THEN 334
            WHEN 27 THEN 335
            WHEN 28 THEN 336
        END;

SELECT
    COUNT(*) AS Total_Matches,
    SUM(HomeScore + AwayScore) AS Total_Goals
FROM FactMatch;






SELECT
    COUNT(*) AS Total2026,
    SUM(CASE WHEN HomeTeamID IS NULL THEN 1 ELSE 0 END) AS MissingHomeTeam,
    SUM(CASE WHEN AwayTeamID IS NULL THEN 1 ELSE 0 END) AS MissingAwayTeam,
    SUM(CASE WHEN StadiumID IS NULL THEN 1 ELSE 0 END) AS MissingStadium,
    SUM(CASE WHEN RefereeID IS NULL THEN 1 ELSE 0 END) AS MissingReferee,
    SUM(CASE WHEN Round IS NULL THEN 1 ELSE 0 END) AS MissingRound
FROM FactMatch
WHERE WorldCupID = 23;

SELECT
    WorldCupID,
    Year,
    Host,
    Teams,
    Champion,
    RunnerUp,
    TopScorer,
    Attendance,
    AttendanceAvg,
    Matches
FROM DimWorldCup
WHERE Year = 2026;


UPDATE DimWorldCup
SET
    Champion = 'Spain',
    RunnerUp = 'Argentina',
    TopScorer = 'Kylian Mbappé',
    Attendance = 6810966,
    AttendanceAvg = 65490
WHERE Year = 2026;

SELECT
    WorldCupID,
    Year,
    Host,
    Teams,
    Champion,
    RunnerUp,
    TopScorer,
    Attendance,
    AttendanceAvg,
    Matches
FROM DimWorldCup
WHERE Year = 2026;



/* ============================================================
   2026 FIFA WORLD CUP — MATCH ATTENDANCE
   Source: verified 2026 match attendance mapping
   ============================================================ */

IF OBJECT_ID('tempdb..#Attendance2026') IS NOT NULL
    DROP TABLE #Attendance2026;

CREATE TABLE #Attendance2026
(
    match_id INT,
    attendance INT
);

INSERT INTO #Attendance2026 (match_id, attendance)
VALUES
(1,80824),
(2,44985),
(3,43002),
(4,70492),
(5,64146),
(6,52497),
(7,80663),
(8,67966),
(9,68274),
(10,68021),
(11,69285),
(12,50987),
(13,62764),
(14,67640),
(15,70108),
(16,66775),
(17,80545),
(18,63106),
(19,69045),
(20,68527),
(21,42942),
(22,70389),
(23,68777),
(24,80824),
(25,67442),
(26,70026),
(27,52497),
(28,45522),
(29,68324),
(30,64146),
(31,68827),
(32,66925),
(33,43036),
(34,68598),
(35,68777),
(36,51243),
(37,64003),
(38,68239),
(39,70317),
(40,52497),
(41,80663),
(42,68324),
(43,70649),
(44,68371),
(45,63983),
(46,43036),
(47,68777),
(48,45358),
(49,64478),
(50,68239),
(51,52497),
(52,66925),
(53,80824),
(54,51243),
(55,68324),
(56,80663),
(57,70137),
(58,68391),
(59,70492),
(60,68827),
(61,64146),
(62,43036),
(63,66925),
(64,52497),
(65,68278),
(66,45065),
(67,80663),
(68,68324),
(69,69045),
(70,70649),
(71,64478),
(72,68239),
(73,69237),
(74,63945),
(75,51243),
(76,68777),
(77,80663),
(78,69665),
(79,80824),
(80,68239),
(81,68827),
(82,66925),
(83,43036),
(84,70492),
(85,52497),
(86,64478),
(87,69045),
(88,70244),
(89,68324),
(90,68777),
(91,80663),
(92,80824),
(93,70649),
(94,66925),
(95,68239),
(96,52497),
(97,63811),
(98,70492),
(99,64478),
(100,69045),
(101,70176),
(102,68239),
(103,64478),
(104,80663);


/* ============================================================
   UPDATE FACTMATCH
   ============================================================ */

UPDATE f
SET f.Attendance = a.attendance
FROM FactMatch f
INNER JOIN Stg_Matches_2026 s
    ON f.WorldCupID = 23
    AND f.MatchDate = s.match_date
    AND f.HomeTeamID =
        CASE s.home_team_id
            WHEN 1 THEN 47
            WHEN 2 THEN 70
            WHEN 3 THEN 45
            WHEN 4 THEN 20
            WHEN 5 THEN 12
            WHEN 6 THEN 8
            WHEN 7 THEN 59
            WHEN 8 THEN 74
            WHEN 9 THEN 9
            WHEN 10 THEN 48
            WHEN 11 THEN 34
            WHEN 12 THEN 64
            WHEN 13 THEN 81
            WHEN 14 THEN 55
            WHEN 15 THEN 4
            WHEN 16 THEN 78
            WHEN 17 THEN 30
            WHEN 18 THEN 89
            WHEN 19 THEN 17
            WHEN 20 THEN 24
            WHEN 21 THEN 49
            WHEN 22 THEN 43
            WHEN 23 THEN 73
            WHEN 24 THEN 77
            WHEN 25 THEN 6
            WHEN 26 THEN 25
            WHEN 27 THEN 38
            WHEN 28 THEN 50
            WHEN 29 THEN 72
            WHEN 30 THEN 87
            WHEN 31 THEN 63
            WHEN 32 THEN 82
            WHEN 33 THEN 29
            WHEN 34 THEN 65
            WHEN 35 THEN 39
            WHEN 36 THEN 53
            WHEN 37 THEN 3
            WHEN 38 THEN 1
            WHEN 39 THEN 5
            WHEN 40 THEN 90
            WHEN 41 THEN 58
            WHEN 42 THEN 88
            WHEN 43 THEN 91
            WHEN 44 THEN 15
            WHEN 45 THEN 27
            WHEN 46 THEN 18
            WHEN 47 THEN 32
            WHEN 48 THEN 54
        END
    AND f.AwayTeamID =
        CASE s.away_team_id
            WHEN 1 THEN 47
            WHEN 2 THEN 70
            WHEN 3 THEN 45
            WHEN 4 THEN 20
            WHEN 5 THEN 12
            WHEN 6 THEN 8
            WHEN 7 THEN 59
            WHEN 8 THEN 74
            WHEN 9 THEN 9
            WHEN 10 THEN 48
            WHEN 11 THEN 34
            WHEN 12 THEN 64
            WHEN 13 THEN 81
            WHEN 14 THEN 55
            WHEN 15 THEN 4
            WHEN 16 THEN 78
            WHEN 17 THEN 30
            WHEN 18 THEN 89
            WHEN 19 THEN 17
            WHEN 20 THEN 24
            WHEN 21 THEN 49
            WHEN 22 THEN 43
            WHEN 23 THEN 73
            WHEN 24 THEN 77
            WHEN 25 THEN 6
            WHEN 26 THEN 25
            WHEN 27 THEN 38
            WHEN 28 THEN 50
            WHEN 29 THEN 72
            WHEN 30 THEN 87
            WHEN 31 THEN 63
            WHEN 32 THEN 82
            WHEN 33 THEN 29
            WHEN 34 THEN 65
            WHEN 35 THEN 39
            WHEN 36 THEN 53
            WHEN 37 THEN 3
            WHEN 38 THEN 1
            WHEN 39 THEN 5
            WHEN 40 THEN 90
            WHEN 41 THEN 58
            WHEN 42 THEN 88
            WHEN 43 THEN 91
            WHEN 44 THEN 15
            WHEN 45 THEN 27
            WHEN 46 THEN 18
            WHEN 47 THEN 32
            WHEN 48 THEN 54
        END
INNER JOIN #Attendance2026 a
    ON s.match_id = a.match_id;


    SELECT
    COUNT(*) AS Total_2026_Matches,
    COUNT(Attendance) AS Matches_With_Attendance,
    SUM(Attendance) AS Total_2026_Attendance,
    AVG(CAST(Attendance AS DECIMAL(12,2))) AS Average_2026_Attendance,
    MAX(Attendance) AS Highest_2026_Attendance,
    MIN(Attendance) AS Lowest_2026_Attendance
FROM FactMatch
WHERE WorldCupID = 23;