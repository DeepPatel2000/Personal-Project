----- ***** Top 5 Nba Players from the last season ***** -----
SELECT TOP 5 Season, Player, Team_Final, Fantasy_Pts_Per_Game
FROM dbo.v_FantasyPoints
WHERE Season = '2024-25' AND RulesName = 'ZOOPA RULES'
ORDER BY Fantasy_Pts_Per_Game DESC;



----- ***** Top 15 players with the highest steal per game with minimum 21 to 22 fantasy points ***** ----- 
SELECT TOP (15)
    Season, Player, Team_Final, G,
    STL AS Steals_per_Game,
    CAST(STL * G AS decimal(10,1)) AS Est_Total_Steals,
    Fantasy_Pts_Per_Game
FROM dbo.v_FantasyPoints
WHERE RulesName = 'ZOOPA RULES'
  AND Fantasy_Pts_Per_Game BETWEEN 21.00 AND 23.00
  AND Season = '2024-25'
ORDER BY STL DESC, G DESC, Player;


