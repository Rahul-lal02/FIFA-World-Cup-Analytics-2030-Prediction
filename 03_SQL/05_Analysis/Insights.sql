---SQL Insights---

---Top 10 highest-scoring World Cup matches.---

SELECT TOP 10
    ht.TeamName AS HomeTeam,
    at.TeamName AS AwayTeam,
    f.HomeScore,
    f.AwayScore,
    (f.HomeScore + f.AwayScore) AS TotalGoals,
    f.MatchDate,
    f.Round
FROM FactMatches f
JOIN DimTeam ht ON f.HomeTeamID = ht.TeamID
JOIN DimTeam at ON f.AwayTeamID = at.TeamID
ORDER BY TotalGoals DESC, f.MatchDate DESC;

---------------------------------------------------
---Teams that has most goals in World Cup history.---

SELECT TOP 10
    T.TeamName,
    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID THEN FM.HomeScore
            WHEN FM.AwayTeamID = T.TeamID THEN FM.AwayScore
            ELSE 0
        END
    ) AS TotalGoals
FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID
GROUP BY
    T.TeamID,
    T.TeamName
ORDER BY
    TotalGoals DESC;
----------------------------------

----Teams with most World Cup titles---

SELECT
    Champion AS TeamName,
    COUNT(*) AS WorldCupWins
FROM DimWorldCup
GROUP BY Champion
ORDER BY WorldCupWins DESC;

-------------------------------------------
---teams that have played the most World Cup matches--


SELECT TOP 10
    T.TeamName,
    COUNT(*) AS MatchesPlayed
FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID
GROUP BY
    T.TeamID,
    T.TeamName
ORDER BY
    MatchesPlayed DESC;
-----------------------------------------

---how many matches were won by the home team, away team, or ended in a draw.---
SELECT
    CASE
        WHEN HomeScore > AwayScore THEN 'Home Win'
        WHEN HomeScore < AwayScore THEN 'Away Win'
        ELSE 'Draw'
    END AS MatchResult,
    COUNT(*) AS MatchCount
FROM FactMatches
GROUP BY
    CASE
        WHEN HomeScore > AwayScore THEN 'Home Win'
        WHEN HomeScore < AwayScore THEN 'Away Win'
        ELSE 'Draw'
    END
ORDER BY MatchCount DESC;
----------------------------------------------------------
---the average total goals scored per World Cup match.---

SELECT
    COUNT(*) AS TotalMatches,
    SUM(HomeScore + AwayScore) AS TotalGoals,
    CAST(
        AVG(CAST(HomeScore + AwayScore AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AvgGoalsPerMatch
FROM FactMatches;
--------------------------------------
---the matches with the most total goals.---
SELECT TOP 10
    T1.TeamName AS HomeTeam,
    T2.TeamName AS AwayTeam,
    FM.HomeScore,
    FM.AwayScore,
    (FM.HomeScore + FM.AwayScore) AS TotalGoals,
    FM.MatchDate,
    FM.Round
FROM FactMatches FM
JOIN DimTeam T1
    ON FM.HomeTeamID = T1.TeamID
JOIN DimTeam T2
    ON FM.AwayTeamID = T2.TeamID
ORDER BY
    TotalGoals DESC,
    FM.MatchDate;

-------------------------------------
---Team win percentage---
SELECT TOP 10
    T.TeamName,

    COUNT(*) AS MatchesPlayed,

    SUM(
        CASE
            WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
              OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Wins,

    SUM(
        CASE
            WHEN FM.HomeScore = FM.AwayScore
            THEN 1
            ELSE 0
        END
    ) AS Draws,

    SUM(
        CASE
            WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore < FM.AwayScore)
              OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore < FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Losses,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                  OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
                THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS WinPercentage

FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(*) >= 20

ORDER BY
    WinPercentage DESC;
--------------------------------
---Best attacking teams---
SELECT TOP 10
    T.TeamName,

    COUNT(*) AS MatchesPlayed,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID THEN FM.HomeScore
            WHEN FM.AwayTeamID = T.TeamID THEN FM.AwayScore
            ELSE 0
        END
    ) AS GoalsScored,

    CAST(
        1.0 * SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID THEN FM.HomeScore
                WHEN FM.AwayTeamID = T.TeamID THEN FM.AwayScore
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AvgGoalsPerMatch

FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(*) >= 20

ORDER BY
    AvgGoalsPerMatch DESC;
--------------------------------------

---the teams that have conceded the fewest goals per match.---

SELECT TOP 10
    T.TeamName,

    COUNT(*) AS MatchesPlayed,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID THEN FM.AwayScore
            WHEN FM.AwayTeamID = T.TeamID THEN FM.HomeScore
            ELSE 0
        END
    ) AS GoalsConceded,

    CAST(
        1.0 * SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID THEN FM.AwayScore
                WHEN FM.AwayTeamID = T.TeamID THEN FM.HomeScore
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AvgGoalsConceded

FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(*) >= 20

ORDER BY
    AvgGoalsConceded ASC;
----------------------------------------

---combine attack + defense and calculate goal difference per match.---
SELECT TOP 10
    T.TeamName,
    COUNT(*) AS MatchesPlayed,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID THEN FM.HomeScore
            WHEN FM.AwayTeamID = T.TeamID THEN FM.AwayScore
            ELSE 0
        END
    ) AS GoalsScored,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID THEN FM.AwayScore
            WHEN FM.AwayTeamID = T.TeamID THEN FM.HomeScore
            ELSE 0
        END
    ) AS GoalsConceded,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore - FM.AwayScore
            WHEN FM.AwayTeamID = T.TeamID
                THEN FM.AwayScore - FM.HomeScore
            ELSE 0
        END
    ) AS GoalDifference,

    CAST(
        1.0 *
        SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID
                    THEN FM.HomeScore - FM.AwayScore
                WHEN FM.AwayTeamID = T.TeamID
                    THEN FM.AwayScore - FM.HomeScore
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS AvgGoalDifference

FROM FactMatches FM
JOIN DimTeam T
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(*) >= 20

ORDER BY
    AvgGoalDifference DESC;
---------------------------------------------
---World Cup performance by tournament---
SELECT
    WC.Year,
    WC.Host,
    WC.Champion,
    WC.[RunnerUp],
    WC.Teams,
    WC.Matches
FROM DimWorldCup WC
ORDER BY WC.Year;

----------------------------------
---the number of World Cup titles won by each country directly from DimWorldCup.---
SELECT
    Champion,
    COUNT(*) AS WorldCupTitles
FROM DimWorldCup
GROUP BY Champion
ORDER BY WorldCupTitles DESC;

---------------------------------
----Tournament champion + runner-up analysis---
SELECT
    TeamName,
    COUNT(*) AS FinalAppearances,
    SUM(CASE WHEN FinishType = 'Champion' THEN 1 ELSE 0 END) AS Titles,
    SUM(CASE WHEN FinishType = 'Runner-Up' THEN 1 ELSE 0 END) AS RunnerUps
FROM
(
    SELECT
        Champion AS TeamName,
        'Champion' AS FinishType
    FROM DimWorldCup
    WHERE Champion IS NOT NULL

    UNION ALL

    SELECT
        RunnerUp AS TeamName,
        'Runner-Up' AS FinishType
    FROM DimWorldCup
    WHERE RunnerUp IS NOT NULL
) AS Finals
GROUP BY TeamName
ORDER BY FinalAppearances DESC;
-------------------------------
----Team Final Success Rate---
SELECT
    TeamName,
    COUNT(*) AS FinalAppearances,

    SUM(CASE
        WHEN FinishType = 'Champion' THEN 1
        ELSE 0
    END) AS Titles,

    SUM(CASE
        WHEN FinishType = 'Runner-Up' THEN 1
        ELSE 0
    END) AS RunnerUps,

    CAST(
        100.0 *
        SUM(CASE
            WHEN FinishType = 'Champion' THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS FinalWinRate

FROM
(
    SELECT
        Champion AS TeamName,
        'Champion' AS FinishType
    FROM DimWorldCup
    WHERE Champion IS NOT NULL

    UNION ALL

    SELECT
        RunnerUp AS TeamName,
        'Runner-Up' AS FinishType
    FROM DimWorldCup
    WHERE RunnerUp IS NOT NULL
) AS Finals

GROUP BY TeamName

ORDER BY FinalWinRate DESC;

--------------------------------------------------
---Tournament participation---
SELECT
    T.TeamName,
    COUNT(DISTINCT FM.WorldCupID) AS WorldCupsPlayed
FROM DimTeam T
JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID
GROUP BY T.TeamName
ORDER BY WorldCupsPlayed DESC;

-------------------------------------------------------
---Average goals per match by World Cup---
SELECT
    WC.Year,
    WC.Host,
    COUNT(FM.MatchID) AS MatchesPlayed,
    SUM(FM.HomeScore + FM.AwayScore) AS TotalGoals,
    CAST(
        1.0 * SUM(FM.HomeScore + FM.AwayScore)
        / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS AvgGoalsPerMatch
FROM DimWorldCup WC
JOIN FactMatches FM
    ON WC.WorldCupID = FM.WorldCupID
GROUP BY
    WC.Year,
    WC.Host
ORDER BY AvgGoalsPerMatch DESC;

----------------------------------------
---Home vs Away Performance by World Cup---
SELECT
    WC.Year,
    WC.Host,

    SUM(CASE
        WHEN T1.TeamName = WC.Host
             AND FM.HomeScore > FM.AwayScore
        THEN 1

        WHEN T2.TeamName = WC.Host
             AND FM.AwayScore > FM.HomeScore
        THEN 1

        ELSE 0
    END) AS HostWins,

    SUM(CASE
        WHEN T1.TeamName = WC.Host
             AND FM.HomeScore < FM.AwayScore
        THEN 1

        WHEN T2.TeamName = WC.Host
             AND FM.AwayScore < FM.HomeScore
        THEN 1

        ELSE 0
    END) AS HostLosses,

    SUM(CASE
        WHEN (T1.TeamName = WC.Host OR T2.TeamName = WC.Host)
             AND FM.HomeScore = FM.AwayScore
        THEN 1
        ELSE 0
    END) AS HostDraws

FROM DimWorldCup WC

JOIN FactMatches FM
    ON WC.WorldCupID = FM.WorldCupID

JOIN DimTeam T1
    ON FM.HomeTeamID = T1.TeamID

JOIN DimTeam T2
    ON FM.AwayTeamID = T2.TeamID

GROUP BY
    WC.Year,
    WC.Host

ORDER BY
    WC.Year;

---------------------------------------------------------------
---Team performance by World Cup---
SELECT
    T.TeamName,
    COUNT(FM.MatchID) AS MatchesPlayed,

    SUM(
        CASE
            WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
              OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Wins,

    SUM(
        CASE
            WHEN FM.HomeScore = FM.AwayScore
            THEN 1
            ELSE 0
        END
    ) AS Draws,

    SUM(
        CASE
            WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore < FM.AwayScore)
              OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore < FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Losses,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                  OR (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
                THEN 1
                ELSE 0
            END
        )
        / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS WinPercentage

FROM DimTeam T
JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(FM.MatchID) >= 10

ORDER BY
    WinPercentage DESC,
    MatchesPlayed DESC;

    -----------------------------------------------
    ----Goals For vs Goals Against---
    SELECT
    T.TeamName,
    COUNT(FM.MatchID) AS MatchesPlayed,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore
            ELSE FM.AwayScore
        END
    ) AS GoalsScored,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.AwayScore
            ELSE FM.HomeScore
        END
    ) AS GoalsConceded,

    CAST(
        1.0 *
        SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID
                    THEN FM.HomeScore
                ELSE FM.AwayScore
            END
        ) / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS GoalsPerMatch,

    CAST(
        1.0 *
        SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID
                    THEN FM.AwayScore
                ELSE FM.HomeScore
            END
        ) / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS ConcededPerMatch

FROM DimTeam T

JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(FM.MatchID) >= 10

ORDER BY
    GoalsPerMatch DESC;

---------------------------------------------------
----Goal Difference and Goal Difference per Match.---
SELECT
    T.TeamName,
    COUNT(FM.MatchID) AS MatchesPlayed,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore
            ELSE FM.AwayScore
        END
    ) AS GoalsScored,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.AwayScore
            ELSE FM.HomeScore
        END
    ) AS GoalsConceded,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore - FM.AwayScore
            ELSE FM.AwayScore - FM.HomeScore
        END
    ) AS GoalDifference,

    CAST(
        1.0 *
        SUM(
            CASE
                WHEN FM.HomeTeamID = T.TeamID
                    THEN FM.HomeScore - FM.AwayScore
                ELSE FM.AwayScore - FM.HomeScore
            END
        ) / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS GoalDifferencePerMatch

FROM DimTeam T

JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(FM.MatchID) >= 10

ORDER BY
    GoalDifferencePerMatch DESC;

-----------------------------------------
----How successful is each team specifically in knockout matches---
SELECT
    T.TeamName,

    COUNT(FM.MatchID) AS KnockoutMatches,

    SUM(
        CASE
            WHEN
                (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                OR
                (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Wins,

    SUM(
        CASE
            WHEN FM.HomeScore = FM.AwayScore
            THEN 1
            ELSE 0
        END
    ) AS Draws,

    SUM(
        CASE
            WHEN
                (FM.HomeTeamID = T.TeamID AND FM.HomeScore < FM.AwayScore)
                OR
                (FM.AwayTeamID = T.TeamID AND FM.AwayScore < FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Losses,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN
                    (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                    OR
                    (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
                THEN 1
                ELSE 0
            END
        ) / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS KnockoutWinPercentage

FROM DimTeam T

JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

WHERE FM.Round IN (
    'Round of 16',
    'Quarter-finals',
    'Semi-finals',
    'Final',
    'Third-place match'
)

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(FM.MatchID) >= 5

ORDER BY
    KnockoutWinPercentage DESC,
    KnockoutMatches DESC;


-------------------------------------------
---World Cup appearances by team---
SELECT
    T.TeamName,
    COUNT(DISTINCT FM.WorldCupID) AS WorldCupAppearances
FROM DimTeam T
JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID
GROUP BY
    T.TeamID,
    T.TeamName
ORDER BY
    WorldCupAppearances DESC,
    T.TeamName;

    -----------------------------------------
---Tournament participation vs performance---
SELECT
    T.TeamName,

    COUNT(DISTINCT FM.WorldCupID) AS WorldCupAppearances,

    COUNT(FM.MatchID) AS MatchesPlayed,

    SUM(
        CASE
            WHEN
                (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                OR
                (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
            THEN 1
            ELSE 0
        END
    ) AS Wins,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN
                    (FM.HomeTeamID = T.TeamID AND FM.HomeScore > FM.AwayScore)
                    OR
                    (FM.AwayTeamID = T.TeamID AND FM.AwayScore > FM.HomeScore)
                THEN 1
                ELSE 0
            END
        ) / COUNT(FM.MatchID)
        AS DECIMAL(5,2)
    ) AS WinPercentage,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore
            ELSE FM.AwayScore
        END
    ) AS GoalsScored,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.AwayScore
            ELSE FM.HomeScore
        END
    ) AS GoalsConceded,

    SUM(
        CASE
            WHEN FM.HomeTeamID = T.TeamID
                THEN FM.HomeScore - FM.AwayScore
            ELSE FM.AwayScore - FM.HomeScore
        END
    ) AS GoalDifference

FROM DimTeam T

JOIN FactMatches FM
    ON T.TeamID = FM.HomeTeamID
    OR T.TeamID = FM.AwayTeamID

GROUP BY
    T.TeamID,
    T.TeamName

HAVING COUNT(FM.MatchID) >= 10

ORDER BY
    WinPercentage DESC,
    GoalDifference DESC;