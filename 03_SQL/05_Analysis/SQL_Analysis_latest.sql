SELECT
    Year,
    Host,
    Champion,
    RunnerUp
FROM DimWorldCup
ORDER BY Year;

SELECT
    Champion,
    COUNT(*) AS WorldCupTitles
FROM DimWorldCup
GROUP BY Champion
ORDER BY WorldCupTitles DESC, Champion;

SELECT
    CASE
        WHEN Champion = 'West Germany' THEN 'Germany'
        ELSE Champion
    END AS Champion,
    COUNT(*) AS WorldCupTitles
FROM DimWorldCup
GROUP BY
    CASE
        WHEN Champion = 'West Germany' THEN 'Germany'
        ELSE Champion
    END
ORDER BY WorldCupTitles DESC, Champion;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT TOP 5 *
FROM dbo.DimWorldCup;



SELECT
    CASE
        WHEN Team IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE Team
    END AS Team,
    COUNT(*) AS Final_Appearances
FROM
(
    SELECT Champion AS Team
    FROM dbo.DimWorldCup

    UNION ALL

    SELECT RunnerUp AS Team
    FROM dbo.DimWorldCup
) AS Finals
GROUP BY
    CASE
        WHEN Team IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE Team
    END
ORDER BY Final_Appearances DESC;

SELECT
    Year,
    Host,
    Champion,
    RunnerUp
FROM dbo.DimWorldCup
ORDER BY Year;


SELECT TOP 5 *
FROM dbo.FactMatch;

SELECT
    Year,
    Host,
    Champion,
    RunnerUp,
    CASE
        WHEN Host = 'Germany'
             AND Champion IN ('Germany', 'West Germany')
            THEN 'Winner'

        WHEN Host = 'Germany'
             AND RunnerUp IN ('Germany', 'West Germany')
            THEN 'Runner-Up'

        WHEN Host = Champion THEN 'Winner'
        WHEN Host = RunnerUp THEN 'Runner-Up'

        ELSE 'Did Not Reach Final'
    END AS Host_Performance
FROM dbo.DimWorldCup
ORDER BY Year;


SELECT
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END AS Team,
    COUNT(*) AS Match_Wins
FROM
(
    SELECT HomeTeamID AS TeamID
    FROM dbo.FactMatch
    WHERE HomeScore > AwayScore

    UNION ALL

    SELECT AwayTeamID AS TeamID
    FROM dbo.FactMatch
    WHERE AwayScore > HomeScore
) AS Wins
JOIN dbo.DimTeam t
    ON Wins.TeamID = t.TeamID
GROUP BY
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END
ORDER BY Match_Wins DESC;

SELECT
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END AS Team,
    SUM(Goals_Scored) AS Total_Goals
FROM
(
    SELECT
        HomeTeamID AS TeamID,
        HomeScore AS Goals_Scored
    FROM dbo.FactMatch

    UNION ALL

    SELECT
        AwayTeamID AS TeamID,
        AwayScore AS Goals_Scored
    FROM dbo.FactMatch
) AS TeamGoals
JOIN dbo.DimTeam t
    ON TeamGoals.TeamID = t.TeamID
GROUP BY
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END
ORDER BY Total_Goals DESC;


SELECT TOP 10
    wc.Year,
    home.TeamName AS HomeTeam,
    fm.HomeScore,
    away.TeamName AS AwayTeam,
    fm.AwayScore,
    (fm.HomeScore + fm.AwayScore) AS Total_Goals,
    fm.Round,
    s.StadiumName
FROM dbo.FactMatch fm
JOIN dbo.DimWorldCup wc
    ON fm.WorldCupID = wc.WorldCupID
JOIN dbo.DimTeam home
    ON fm.HomeTeamID = home.TeamID
JOIN dbo.DimTeam away
    ON fm.AwayTeamID = away.TeamID
LEFT JOIN dbo.DimStadium s
    ON fm.StadiumID = s.StadiumID
ORDER BY
    Total_Goals DESC,
    wc.Year;




    WITH TeamStats AS
(
    SELECT
        HomeTeamID AS TeamID,
        COUNT(*) AS Matches_Played,
        SUM(
            CASE
                WHEN HomeScore > AwayScore THEN 1
                ELSE 0
            END
        ) AS Wins
    FROM dbo.FactMatch
    GROUP BY HomeTeamID

    UNION ALL

    SELECT
        AwayTeamID AS TeamID,
        COUNT(*) AS Matches_Played,
        SUM(
            CASE
                WHEN AwayScore > HomeScore THEN 1
                ELSE 0
            END
        ) AS Wins
    FROM dbo.FactMatch
    GROUP BY AwayTeamID
),
CombinedStats AS
(
    SELECT
        TeamID,
        SUM(Matches_Played) AS Matches_Played,
        SUM(Wins) AS Wins
    FROM TeamStats
    GROUP BY TeamID
)
SELECT
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END AS Team,
    SUM(cs.Matches_Played) AS Matches_Played,
    SUM(cs.Wins) AS Wins,
    CAST(
        SUM(cs.Wins) * 100.0 / SUM(cs.Matches_Played)
        AS DECIMAL(5,2)
    ) AS Win_Percentage
FROM CombinedStats cs
JOIN dbo.DimTeam t
    ON cs.TeamID = t.TeamID
GROUP BY
    CASE
        WHEN t.TeamName IN ('Germany', 'West Germany') THEN 'Germany'
        ELSE t.TeamName
    END
ORDER BY Win_Percentage DESC;



SELECT
    s.StadiumName,
    COUNT(fm.MatchID) AS Matches_Hosted
FROM dbo.FactMatch fm
JOIN dbo.DimStadium s
    ON fm.StadiumID = s.StadiumID
GROUP BY
    s.StadiumName
ORDER BY Matches_Hosted DESC;






SELECT TOP 10
    wc.Year,
    home.TeamName AS HomeTeam,
    away.TeamName AS AwayTeam,
    fm.HomeScore,
    fm.AwayScore,
    fm.Attendance,
    fm.Round,
    s.StadiumName
FROM dbo.FactMatch fm
JOIN dbo.DimWorldCup wc
    ON fm.WorldCupID = wc.WorldCupID
JOIN dbo.DimTeam home
    ON fm.HomeTeamID = home.TeamID
JOIN dbo.DimTeam away
    ON fm.AwayTeamID = away.TeamID
LEFT JOIN dbo.DimStadium s
    ON fm.StadiumID = s.StadiumID
WHERE fm.Attendance IS NOT NULL
ORDER BY fm.Attendance DESC;





SELECT
    wc.Year,
    wc.Host,
    SUM(fm.Attendance) AS Total_Attendance,
    AVG(CAST(fm.Attendance AS DECIMAL(18,2))) AS Average_Match_Attendance,
    COUNT(fm.MatchID) AS Total_Matches
FROM dbo.FactMatch fm
JOIN dbo.DimWorldCup wc
    ON fm.WorldCupID = wc.WorldCupID
WHERE fm.Attendance IS NOT NULL
GROUP BY
    wc.Year,
    wc.Host
ORDER BY wc.Year;