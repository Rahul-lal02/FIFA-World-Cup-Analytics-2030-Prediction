TRUNCATE TABLE dbo.Stg_Matches;

SELECT @@SERVERNAME;

EXEC xp_fileexist 'E:\FIFA_World_Cup_Analytics\01_Raw_data\matches_clean.csv';

TRUNCATE TABLE dbo.Stg_Matches;
GO

BULK INSERT dbo.Stg_Matches
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\matches_clean.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    KEEPNULLS,
    TABLOCK
);

TRUNCATE TABLE dbo.Stg_Matches;
GO

BULK INSERT dbo.Stg_Matches
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\matches_clean.csv'
WITH
(
    FORMAT='CSV',
    FIRSTROW=2,
    FIELDQUOTE='"',
    FIELDTERMINATOR=',',
    ROWTERMINATOR='0x0d0a',
    CODEPAGE='65001',
    KEEPNULLS
);

SELECT COUNT(*) AS TotalRows
FROM dbo.Stg_Matches;

SELECT TOP 5 *
FROM dbo.Stg_Matches;


SELECT
    home_team,
    away_team,
    [Date],
    COUNT(*) AS Cnt
FROM dbo.Stg_Matches
GROUP BY
    home_team,
    away_team,
    [Date]
HAVING COUNT(*) > 1;


SELECT TOP (10)
    home_team,
    away_team,
    Date,
    home_score,
    away_score,
    Round,
    Year
FROM dbo.Stg_Matches
ORDER BY Date DESC;

Select * from  dbo.Stg_Matches;

CREATE TABLE dbo.DimTeam
(
    TeamID INT IDENTITY(1,1) PRIMARY KEY,
    TeamName NVARCHAR(100) NOT NULL UNIQUE
);


---This will insert every unique national team exactly once.
INSERT INTO dbo.DimTeam (TeamName)
SELECT TeamName
FROM
(
    SELECT home_team AS TeamName
    FROM dbo.Stg_Matches

    UNION

    SELECT away_team
    FROM dbo.Stg_Matches
) AS Teams
ORDER BY TeamName;

SELECT *
FROM dbo.DimTeam
ORDER BY TeamName;

SELECT COUNT(*) AS TotalTeams
FROM dbo.DimTeam;

CREATE TABLE dbo.DimStadium
(
    StadiumID INT IDENTITY(1,1) PRIMARY KEY,
    StadiumName NVARCHAR(200) NOT NULL,
    HostCity NVARCHAR(100) NULL
);

---INSERTING

INSERT INTO dbo.DimStadium (StadiumName, HostCity)
SELECT DISTINCT
    LTRIM(RTRIM(
        CASE
            WHEN CHARINDEX(',', Venue) > 0
            THEN LEFT(Venue, CHARINDEX(',', Venue) - 1)
            ELSE Venue
        END
    )) AS StadiumName,

    LTRIM(RTRIM(
        CASE
            WHEN CHARINDEX(',', Venue) > 0
            THEN SUBSTRING(Venue, CHARINDEX(',', Venue) + 1, LEN(Venue))
            ELSE NULL
        END
    )) AS HostCity

FROM dbo.Stg_Matches
ORDER BY StadiumName;

SELECT COUNT(*) AS TotalStadiums
FROM dbo.DimStadium;

SELECT TOP 10 *
FROM dbo.DimStadium
ORDER BY StadiumName;

SELECT COUNT(*) AS TotalRows
FROM dbo.DimStadium;

SELECT TOP (10) *
FROM dbo.DimStadium
ORDER BY StadiumID;

CREATE TABLE dbo.DimWorldCup
(
    WorldCupID INT IDENTITY(1,1) PRIMARY KEY,
    Year INT,
    Host NVARCHAR(100),
    Teams INT,
    Champion NVARCHAR(100),
    RunnerUp NVARCHAR(100),
    TopScorer NVARCHAR(200),
    Attendance BIGINT,
    AttendanceAvg INT,
    Matches INT
);

INSERT INTO dbo.DimWorldCup
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
SELECT
    Year,
    Host,
    Teams,
    Champion,
    [Runner_Up],
    TopScorrer,
    Attendance,
    AttendanceAvg,
    Matches
FROM dbo.Stg_WorldCup;

SELECT TOP 1 *
FROM dbo.Stg_WorldCup;

SELECT COUNT(*) AS TotalWorldCups
FROM dbo.DimWorldCup;

SELECT *
FROM dbo.DimWorldCup
ORDER BY Year;

CREATE TABLE dbo.DimReferee
(
    RefereeID INT IDENTITY(1,1) PRIMARY KEY,
    RefereeName NVARCHAR(200)
);

INSERT INTO dbo.DimReferee (RefereeName)
SELECT DISTINCT Referee
FROM dbo.Stg_Matches
WHERE Referee IS NOT NULL;

SELECT COUNT(*) AS TotalReferees
FROM dbo.DimReferee;

SELECT TOP (10) *
FROM dbo.DimReferee
ORDER BY RefereeName;




CREATE TABLE dbo.FactMatch
(
    MatchID INT IDENTITY(1,1) PRIMARY KEY,

    WorldCupID INT,
    HomeTeamID INT,
    AwayTeamID INT,
    StadiumID INT,
    RefereeID INT,

    MatchDate DATE,
    Round NVARCHAR(100),

    HomeScore INT,
    AwayScore INT,

    HomeXG FLOAT NULL,
    AwayXG FLOAT NULL,

    HomePenalty FLOAT NULL,
    AwayPenalty FLOAT NULL,

    Attendance INT,

    Score NVARCHAR(50),
    Notes NVARCHAR(MAX),

    FOREIGN KEY (WorldCupID) REFERENCES DimWorldCup(WorldCupID),
    FOREIGN KEY (HomeTeamID) REFERENCES DimTeam(TeamID),
    FOREIGN KEY (AwayTeamID) REFERENCES DimTeam(TeamID),
    FOREIGN KEY (StadiumID) REFERENCES DimStadium(StadiumID),
    FOREIGN KEY (RefereeID) REFERENCES DimReferee(RefereeID)
);


INSERT INTO dbo.FactMatch
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
    wc.WorldCupID,
    ht.TeamID,
    at.TeamID,
    s.StadiumID,
    r.RefereeID,

    m.Date,
    m.Round,
    m.home_score,
    m.away_score,
    m.home_xg,
    m.away_xg,
    m.home_penalty,
    m.away_penalty,
    m.Attendance,
    m.Score,
    m.Notes

FROM dbo.Stg_Matches m

INNER JOIN dbo.DimWorldCup wc
    ON m.Year = wc.Year

INNER JOIN dbo.DimTeam ht
    ON m.home_team = ht.TeamName

INNER JOIN dbo.DimTeam at
    ON m.away_team = at.TeamName

INNER JOIN dbo.DimStadium s
    ON s.StadiumName =
       LTRIM(RTRIM(LEFT(m.Venue, CHARINDEX(',', m.Venue + ',') - 1)))

LEFT JOIN dbo.DimReferee r
    ON m.Referee = r.RefereeName;


SELECT COUNT(*) AS TotalMatches
FROM dbo.FactMatch;

SELECT TOP 10 *
FROM dbo.FactMatch;


---Duplicates checking

SELECT
    StadiumName,
    COUNT(*) AS Total
FROM dbo.DimStadium
GROUP BY StadiumName
HAVING COUNT(*) > 1;

SELECT
    RefereeName,
    COUNT(*) AS Total
FROM dbo.DimReferee
GROUP BY RefereeName
HAVING COUNT(*) > 1;

SELECT
    TeamName,
    COUNT(*) AS Total
FROM dbo.DimTeam
GROUP BY TeamName
HAVING COUNT(*) > 1;

SELECT *
FROM dbo.DimStadium
WHERE StadiumName = 'Olympiastadion';

SELECT DISTINCT Venue
FROM dbo.Stg_Matches
WHERE Venue LIKE 'Olympiastadion%';

TRUNCATE TABLE dbo.FactMatch;

SELECT *
FROM dbo.DimStadium
WHERE StadiumName LIKE '%Olympia%';

SELECT
    StadiumName,
    HostCity,
    COUNT(*) AS Total
FROM dbo.DimStadium
GROUP BY StadiumName, HostCity
ORDER BY StadiumName;


---Corrected command fopr inserting
INSERT INTO dbo.FactMatch
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
    wc.WorldCupID,
    ht.TeamID,
    at.TeamID,
    s.StadiumID,
    r.RefereeID,
    m.Date,
    m.Round,
    m.home_score,
    m.away_score,
    m.home_xg,
    m.away_xg,
    m.home_penalty,
    m.away_penalty,
    m.Attendance,
    m.Score,
    m.Notes

FROM dbo.Stg_Matches m

INNER JOIN dbo.DimWorldCup wc
    ON m.Year = wc.Year

INNER JOIN dbo.DimTeam ht
    ON m.home_team = ht.TeamName

INNER JOIN dbo.DimTeam at
    ON m.away_team = at.TeamName

INNER JOIN dbo.DimStadium s
    ON s.StadiumName =
        LTRIM(RTRIM(LEFT(m.Venue, CHARINDEX(',', m.Venue + ',') - 1)))
   AND s.HostCity =
        LTRIM(RTRIM(
            SUBSTRING(
                m.Venue,
                CHARINDEX(',', m.Venue + ',') + 1,
                LEN(m.Venue)
            )
        ))

LEFT JOIN dbo.DimReferee r
    ON m.Referee = r.RefereeName;

---Valadating everything

    SELECT COUNT(*) AS FactRows
FROM FactMatch;

SELECT *
FROM FactMatch
WHERE HomeTeamID IS NULL;


SELECT *
FROM FactMatch
WHERE AwayTeamID IS NULL;

SELECT *
FROM FactMatch
WHERE StadiumID IS NULL;

SELECT *
FROM FactMatch
WHERE WorldCupID IS NULL;

SELECT *
FROM FactMatch
WHERE RefereeID IS NULL;

SELECT DISTINCT
    s.Referee
FROM Stg_Matches s
LEFT JOIN DimReferee r
    ON LTRIM(RTRIM(s.Referee)) = LTRIM(RTRIM(r.RefereeName))
WHERE r.RefereeID IS NULL;

SELECT TOP 10 Referee
FROM Stg_Matches
WHERE Referee IS NOT NULL;

SELECT TOP 10 RefereeName
FROM DimReferee;



SELECT
    s.Referee,
    LEN(s.Referee) AS StgLen,
    DATALENGTH(s.Referee) AS StgBytes,
    r.RefereeName,
    LEN(r.RefereeName) AS DimLen,
    DATALENGTH(r.RefereeName) AS DimBytes
FROM Stg_Matches s
JOIN DimReferee r
ON s.Referee LIKE '%' + r.RefereeName + '%'
WHERE s.Referee LIKE '%Björn Kuipers%';

SELECT COUNT(*) FROM DimReferee;

SELECT COUNT(*) AS NullReferee
FROM FactMatches
WHERE RefereeID IS NULL;

SELECT COUNT(*) AS TotalTeams
FROM DimTeam;

SELECT COUNT(*) AS TotalStadiums
FROM DimStadium;

SELECT COUNT(*) AS TotalReferees
FROM DimReferee;

SELECT COUNT(*) AS TotalMatches
FROM Stg_Matches;


SELECT COUNT(*) AS Teams
FROM DimTeam;

SELECT COUNT(*) AS Stadiums
FROM DimStadium;

SELECT COUNT(*) AS Referees
FROM DimReferee;

SELECT COUNT(*) AS WorldCups
FROM DimWorldCup;

SELECT COUNT(*) AS TotalMatches
FROM Stg_Matches;


SELECT TOP 5 *
FROM DimStadium;




INSERT INTO FactMatches
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
    wc.WorldCupID,
    ht.TeamID,
    at.TeamID,
    ds.StadiumID,
    dr.RefereeID,
    CAST(sm.Date AS DATE),
    sm.Round,
    sm.home_score,
    sm.away_score,
    sm.home_xg,
    sm.away_xg,
    sm.home_penalty,
    sm.away_penalty,
    sm.Attendance,
    sm.Score,
    sm.Notes
FROM Stg_Matches sm

LEFT JOIN DimWorldCup wc
    ON sm.Year = wc.Year

LEFT JOIN DimTeam ht
    ON LTRIM(RTRIM(sm.home_team)) = LTRIM(RTRIM(ht.TeamName))

LEFT JOIN DimTeam at
    ON LTRIM(RTRIM(sm.away_team)) = LTRIM(RTRIM(at.TeamName))

LEFT JOIN DimStadium ds
    ON LTRIM(RTRIM(sm.Venue)) =
       LTRIM(RTRIM(ds.StadiumName + ', ' + ds.HostCity))

LEFT JOIN DimReferee dr
    ON LTRIM(RTRIM(sm.Referee)) =
       LTRIM(RTRIM(dr.RefereeName));

--==========================================
-- Verify rows inserted
--==========================================
SELECT COUNT(*) AS TotalFactMatches
FROM FactMatches;

--==========================================
-- Check for NULL foreign keys
--==========================================
SELECT
    SUM(CASE WHEN WorldCupID IS NULL THEN 1 ELSE 0 END) AS WorldCup_NULL,
    SUM(CASE WHEN HomeTeamID IS NULL THEN 1 ELSE 0 END) AS HomeTeam_NULL,
    SUM(CASE WHEN AwayTeamID IS NULL THEN 1 ELSE 0 END) AS AwayTeam_NULL,
    SUM(CASE WHEN StadiumID IS NULL THEN 1 ELSE 0 END) AS Stadium_NULL,
    SUM(CASE WHEN RefereeID IS NULL THEN 1 ELSE 0 END) AS Referee_NULL
FROM FactMatches;

SELECT 
    COUNT(*) AS MissingRefereesInSource
FROM Stg_Matches
WHERE Referee IS NULL;

SELECT COUNT(*) AS TotalReferees
FROM DimReferee;

SELECT
    SUM(CASE WHEN WorldCupID IS NULL THEN 1 ELSE 0 END) AS WorldCup_NULL,
    SUM(CASE WHEN HomeTeamID IS NULL THEN 1 ELSE 0 END) AS HomeTeam_NULL,
    SUM(CASE WHEN AwayTeamID IS NULL THEN 1 ELSE 0 END) AS AwayTeam_NULL,
    SUM(CASE WHEN StadiumID IS NULL THEN 1 ELSE 0 END) AS Stadium_NULL,
    SUM(CASE WHEN RefereeID IS NULL THEN 1 ELSE 0 END) AS Referee_NULL
FROM FactMatches;


SELECT COUNT(*) AS MissingRefereesInSource
FROM Stg_Matches
WHERE Referee IS NULL;

SELECT COUNT(*) AS TotalReferees
FROM DimReferee;

SELECT COUNT(*) AS Teams FROM DimTeam;

SELECT COUNT(*) AS Stadiums FROM DimStadium;

SELECT COUNT(*) AS Referees FROM DimReferee;

SELECT COUNT(*) AS WorldCups FROM DimWorldCup;

SELECT COUNT(*) AS TotalMatches FROM Stg_Matches;

SELECT COUNT(*) AS FactMatches FROM FactMatches;



SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable, ForeignKeyName;