----- ***** SCHEMA ***** -----
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'nba')
    EXEC('CREATE SCHEMA nba');
GO
------------------------------------------------------------------------------------------------------------------------------



----- ***** Creating Table Player's Per Game Stats ***** -----
IF OBJECT_ID('dbo.stg_PlayerPerGame','U') IS NOT NULL DROP TABLE dbo.stg_PlayerPerGame;
CREATE TABLE dbo.stg_PlayerPerGame (
    [Season]    nvarchar(20)  NOT NULL,
    [Rk]        nvarchar(50)  NULL,
    [Player]    nvarchar(200) NULL,
	[Age]       nvarchar(50)  NULL,
	[Team]      nvarchar(50)  NULL,
    [Pos]       nvarchar(50)  NULL,
    [G]         nvarchar(50)  NULL,
    [GS]        nvarchar(50)  NULL,
    [MP]        nvarchar(50)  NULL,
    [FG]        nvarchar(50)  NULL,
    [FGA]       nvarchar(50)  NULL,
    [FG%]       nvarchar(50)  NULL,
    [ORB]       nvarchar(50)  NULL,
    [DRB]       nvarchar(50)  NULL,
    [TRB]       nvarchar(50)  NULL,
    [AST]       nvarchar(50)  NULL,
    [STL]       nvarchar(50)  NULL,
    [BLK]       nvarchar(50)  NULL,
    [TOV]       nvarchar(50)  NULL,
    [PTS]       nvarchar(50)  NULL,
);
GO
------------------------------------------------------------------------------------------------------------------------------



----- ***** NBA Players Stats from Season 2022-23 & Dropping unwanted NBA States Columns ***** -----
select * 
from dbo.[Season 2022-23];

alter table dbo.[Season 2022-23]
drop column _2P, Awards, _3PA, _2PA, _2P1, _3P, _3P1, eFG, FT, FTA, FT1, PF;


----- ***** NBA Players Stats from Season 2023-24 & Dropping unwanted NBA States Columns ***** -----
select * 
from dbo.[Season 2023-24];

alter table dbo.[Season 2023-24]
drop column _2P, Awards, _3PA, _2PA, _2P1, _3P, _3P1, eFG, FT, FTA, FT1, PF;



----- ***** NBA Players Stats from Season 2024-25 & Dropping unwanted NBA States Columns ***** -----
select * 
from dbo.[Season 2024-25];

alter table dbo.[Season 2024-25]
drop column _2P, Awards, _3PA, _2PA, _2P1, _3P, _3P1, eFG, FT, FTA, FT1, PF;
------------------------------------------------------------------------------------------------------------------------------



----- ***** Insert NBA Stats from NBA Season 2022-23 into Player's Per Game Stats table ***** -----
INSERT INTO dbo.stg_PlayerPerGame
(Season, Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, [FG%],
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS)
SELECT
 '2022-23',
 Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, FG1,
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS
FROM dbo.[Season 2022-23];

----- ***** Insert NBA Stats from NBA Season 2023-24 into Player's Per Game Stats table ***** -----
INSERT INTO dbo.stg_PlayerPerGame
(Season, Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, [FG%],
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS)
SELECT
 '2023-24',
 Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, FG1,
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS
FROM dbo.[Season 2023-24];

----- ***** Insert NBA Stats from NBA Season 2024-25 into Player's Per Game Stats table ***** -----
INSERT INTO dbo.stg_PlayerPerGame
(Season, Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, [FG%],
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS)
SELECT
 '2024-25',
 Rk, Player, Pos, Age, Team,
 G, GS, MP,
 FG, FGA, FG1,
 ORB, DRB, TRB, AST, STL, BLK, TOV, PTS
FROM dbo.[Season 2024-25];
------------------------------------------------------------------------------------------------------------------------------



----- ***** Staging rows into a clean, typed, query-ready foundation table for analytics ***** -----
IF OBJECT_ID('dbo.PlayerPerGame','U') IS NOT NULL DROP TABLE dbo.PlayerPerGame;
CREATE TABLE dbo.PlayerPerGame
(
    PlayerPerGameID int IDENTITY(1,1) PRIMARY KEY,
    Season      varchar(20) NOT NULL,
    Rk          int         NULL,
    Player      varchar(200) NOT NULL,
    Pos         varchar(10)  NULL,
    Age         int          NULL,
    Team          varchar(10)  NOT NULL,
    G           decimal(6,1) NULL,
    GS          decimal(6,1) NULL,
    MP          decimal(6,1) NULL,
    FG          decimal(6,2) NULL,
    FGA         decimal(6,2) NULL,
    [FG%]       decimal(6,3) NULL,
    ORB         decimal(6,2) NULL,
    DRB         decimal(6,2) NULL,
    TRB         decimal(6,2) NULL,
    AST         decimal(6,2) NULL,
    STL         decimal(6,2) NULL,
    BLK         decimal(6,2) NULL,
    TOV         decimal(6,2) NULL,
    PTS         decimal(6,2) NULL,
    -- Derived/normalized
    Team_Final  varchar(10)  NULL,
    IsTOT       bit          NOT NULL CONSTRAINT DF_PlayerPerGame_IsTOT DEFAULT(0)
);
GO

INSERT INTO dbo.PlayerPerGame
(
    Season, Rk, Player, Pos, Age, Team, G, GS, MP, FG, FGA, [FG%], ORB, DRB, TRB, AST, STL, BLK, TOV, PTS, Team_Final, IsTOT
)
SELECT
    LTRIM(RTRIM(Season)),
    TRY_CONVERT(int, [Rk]),
    LTRIM(RTRIM([Player])),
    LTRIM(RTRIM([Pos])),
    TRY_CONVERT(int, [Age]),
    UPPER(LTRIM(RTRIM([Team]))),
    TRY_CONVERT(decimal(6,1), [G]),
    TRY_CONVERT(decimal(6,1), [GS]),
    TRY_CONVERT(decimal(6,1), [MP]),
    TRY_CONVERT(decimal(6,2), [FG]),
    TRY_CONVERT(decimal(6,2), [FGA]),
    TRY_CONVERT(decimal(6,3), NULLIF([FG%],'')),
    TRY_CONVERT(decimal(6,2), [ORB]),
    TRY_CONVERT(decimal(6,2), [DRB]),
    TRY_CONVERT(decimal(6,2), [TRB]),
    TRY_CONVERT(decimal(6,2), [AST]),
    TRY_CONVERT(decimal(6,2), [STL]),
    TRY_CONVERT(decimal(6,2), [BLK]),
    TRY_CONVERT(decimal(6,2), [TOV]),
    TRY_CONVERT(decimal(6,2), [PTS]),
    NULL, -- Team_Final to be set below
    CASE WHEN UPPER(LTRIM(RTRIM([Team]))) IN ('TOT','2TM','3TM','4TM') THEN 1 ELSE 0 END
FROM dbo.stg_PlayerPerGame;
GO
------------------------------------------------------------------------------------------------------------------------------


----- ***** Resolve “final team” & your special 2TM/TOT rule. Some players get trades during NBA seasons therefore, they have muilpte teams they play for during one season ***** -----
-- 4a) Compute FinalTeam per Player/Season
WITH stint AS (
    SELECT
        Season, Player, Rk, Team,
        ROW_NUMBER() OVER (PARTITION BY Season, Player ORDER BY Rk DESC) AS rn
    FROM dbo.PlayerPerGame
    WHERE Team NOT IN ('TOT','2TM','3TM','4TM')  -- actual teams only
)
UPDATE p
SET Team_Final = s_min.Team
FROM dbo.PlayerPerGame p
CROSS APPLY (
    SELECT TOP (1) s.Team
    FROM stint s
    WHERE s.Season = p.Season AND s.Player = p.Player
    ORDER BY s.rn DESC  -- lowest Rk
) AS s_min
WHERE p.Team_Final IS NULL;

-- 4b) Sanity: if a row is not an aggregate, use its own team as final
UPDATE p
SET Team_Final = p.Team
FROM dbo.PlayerPerGame p
WHERE p.Team_Final IS NULL;

-- 4c) A view that "keeps the 2TM/TOT row" but shows final team name instead of the aggregate code
CREATE OR ALTER VIEW nba.v_PlayerPerGame_Normalized AS
SELECT
    Season, Rk, Player, Pos, Age,
    CASE WHEN IsTOT = 1 THEN Team_Final ELSE Team END AS Tm_Shown,
    G, GS, MP, FG, FGA, [FG%], ORB, DRB, TRB, AST, STL, BLK, TOV, PTS,
    Team_Final, IsTOT
FROM dbo.PlayerPerGame;
GO
------------------------------------------------------------------------------------------------------------------------------



----- ***** Keep only the total stats of players that were traded during the season ***** -----
DELETE FROM dbo.PlayerPerGame
WHERE Team <> '2TM'
  AND Player IN (
      SELECT Player
      FROM dbo.PlayerPerGame
      WHERE Team = '2TM'
  );

DELETE FROM dbo.PlayerPerGame
WHERE Team <> '3TM'
  AND Player IN (
      SELECT Player
      FROM dbo.PlayerPerGame
      WHERE Team = '3TM'
  );


select *
from dbo.PlayerPerGame
------------------------------------------------------------------------------------------------------------------------------



----- ***** Calaculate and Add 'Missed Field Goals Attemets' ***** -----
IF COL_LENGTH('nba.PlayerPerGame','FG_Missed') IS NULL
    ALTER TABLE dbo.PlayerPerGame
    ADD FG_Missed AS (CAST(([FGA] - [FG]) AS DECIMAL(6,2))) PERSISTED;
GO

select *
from dbo.PlayerPerGame
------------------------------------------------------------------------------------------------------------------------------



----- ***** Adding Fantasy Scoring System ***** ----- 
IF OBJECT_ID('dbo.FantasyScoringRules','U') IS NOT NULL DROP TABLE dbo.FantasyScoringRules;
CREATE TABLE dbo.FantasyScoringRules
(
    RulesID int IDENTITY(1,1) PRIMARY KEY,
    RulesName varchar(100) UNIQUE NOT NULL,
    -- per-game linear weights
    w_PTS   float NOT NULL DEFAULT 1.0,
    w_AST   float NOT NULL DEFAULT 1.5,
    w_STL   float NOT NULL DEFAULT 3.0,
    w_BLK   float NOT NULL DEFAULT 3.0,
    w_TOV   float NOT NULL DEFAULT -1.0,
    w_FG_Missed   float NOT NULL DEFAULT -0.5,   -- FG Missed
    w_ORB   float NOT NULL DEFAULT 1.2,
	w_DRB   float NOT NULL DEFAULT 1.0
);

-- Example presets (tweak as you like)
INSERT INTO dbo.FantasyScoringRules (RulesName, w_PTS, w_AST, w_STL, w_BLK, w_TOV,  w_FG_Missed, w_ORB, w_DRB)
VALUES
('ZOOPA RULES', 1.0, 1.5, 3.0, 3.0, -1.0, -0.5, 1.2, 1.0);
GO

CREATE OR ALTER VIEW dbo.V_FantasyPoints AS
WITH base AS (
    SELECT *
    FROM dbo.PlayerPerGame
)
SELECT
    b.Season, b.Player, b.Pos, b.Age, b.Team_Final,
    b.G, b.MP, b.PTS, b.AST, b.STL, b.BLK, b.TOV, b.ORB, b.DRB, b.FG_Missed , 
    r.RulesName,
    CAST( b.PTS  * r.w_PTS
        + b.AST  * r.w_AST
        + b.STL  * r.w_STL
        + b.BLK  * r.w_BLK
        + b.TOV  * r.w_TOV
        + b.FG_Missed * r.w_FG_Missed
		+ b.ORB * r.w_ORB
		+ b.DRB * r.w_DRB
      AS decimal(10,2)) AS Fantasy_Pts_Per_Game
FROM base b
CROSS JOIN dbo.FantasyScoringRules r;
GO
------------------------------------------------------------------------------------------------------------------------------

select * from dbo.FantasyScoringRules