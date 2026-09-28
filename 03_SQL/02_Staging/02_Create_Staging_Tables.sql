USE FIFA_WorldCup_DB;
GO

/*===========================================================
  STAGING TABLE : WORLD CUP
===========================================================*/

CREATE TABLE Stg_WorldCup
(
    Year INT,
    Host NVARCHAR(100),
    Teams INT,
    Champion NVARCHAR(100),
    RunnerUp NVARCHAR(100),
    TopScorrer NVARCHAR(100),
    Attendance BIGINT,
    AttendanceAvg INT,
    Matches INT
);

GO

/*===========================================================
  STAGING TABLE : FIFA RANKING
===========================================================*/

CREATE TABLE Stg_FIFARanking
(
    Team NVARCHAR(100),
    Team_Code NVARCHAR(10),
    Association NVARCHAR(50),
    Rank INT,
    Previous_Rank INT,
    Points DECIMAL(10,2),
    Previous_Points DECIMAL(10,2)
);

GO

/*===========================================================
  STAGING TABLE : MATCHES
===========================================================*/

CREATE TABLE Stg_Matches
(
    home_team NVARCHAR(100),
    away_team NVARCHAR(100),

    home_score INT,
    home_xg DECIMAL(5,2),
    home_penalty INT,

    away_score INT,
    away_xg DECIMAL(5,2),
    away_penalty INT,

    home_manager NVARCHAR(100),
    home_captain NVARCHAR(100),

    away_manager NVARCHAR(100),
    away_captain NVARCHAR(100),

    Attendance INT,

    Venue NVARCHAR(200),
    Officials NVARCHAR(MAX),

    Round NVARCHAR(100),

    Date DATE,

    Score NVARCHAR(30),

    Referee NVARCHAR(100),

    Notes NVARCHAR(MAX),

    Host NVARCHAR(100),

    Year INT,

    home_goal NVARCHAR(MAX),
    away_goal NVARCHAR(MAX),

    home_goal_long NVARCHAR(MAX),
    away_goal_long NVARCHAR(MAX),

    home_own_goal NVARCHAR(MAX),
    away_own_goal NVARCHAR(MAX),

    home_penalty_goal NVARCHAR(MAX),
    away_penalty_goal NVARCHAR(MAX),

    home_penalty_miss_long NVARCHAR(MAX),
    away_penalty_miss_long NVARCHAR(MAX),

    home_penalty_shootout_goal_long NVARCHAR(MAX),
    away_penalty_shootout_goal_long NVARCHAR(MAX),

    home_penalty_shootout_miss_long NVARCHAR(MAX),
    away_penalty_shootout_miss_long NVARCHAR(MAX),

    home_red_card NVARCHAR(MAX),
    away_red_card NVARCHAR(MAX),

    home_yellow_red_card NVARCHAR(MAX),
    away_yellow_red_card NVARCHAR(MAX),

    home_yellow_card_long NVARCHAR(MAX),
    away_yellow_card_long NVARCHAR(MAX),

    home_substitute_in_long NVARCHAR(MAX),
    away_substitute_in_long NVARCHAR(MAX)
);
SELECT * FROM dbo.Stg_WorldCup;
SELECT * FROM dbo.Stg_FIFARanking;
SELECT * FROM dbo.Stg_Matches;

SELECT * FROM INFORMATION_SCHEMA.TABLES;

BULK INSERT Stg_WorldCup
FROM 'E:\FIFA_World_Cup_Analytics\01_Raw_data\world_cup.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

SELECT COUNT(*) FROM Stg_WorldCup;

SELECT COUNT(*) AS TotalRows
FROM Stg_WorldCup;

DROP TABLE IF EXISTS Stg_Matches;
DROP TABLE IF EXISTS Stg_FIFARanking;
DROP TABLE IF EXISTS Stg_WorldCup;



SELECT COUNT(*) AS TotalRows
FROM Stg_FIFARanking;

DROP TABLE IF EXISTS Stg_Matches;

SELECT @@VERSION;

