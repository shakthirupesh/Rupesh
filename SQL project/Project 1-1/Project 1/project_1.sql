#Questions – Write SQL queries to get data for the following requirements:

#1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select B.Bidder_name,COUNT(MS.Schedule_Id) AS TotalMatches,
SUM(CASE WHEN M.Match_Winner = bd.Bid_Team THEN 1 ELSE 0 END) AS Wins,
(SUM(CASE WHEN M.Match_Winner = bd.Bid_Team THEN 1 ELSE 0 END) * 100) / COUNT(MS.Schedule_Id) AS WinPercentage
FROM IPL_Bidder_Details B
INNER JOIN
IPL_Bidding_Details BD ON B.Bidder_Id = BD.Bidder_Id
INNER JOIN
IPL_Match_Schedule MS ON BD.Schedule_Id = MS.Schedule_Id
INNER JOIN
IPL_Match M ON MS.Match_Id = M.Match_Id
GROUP BY B.Bidder_name
ORDER BY WinPercentage DESC;


#2.	Display the number of matches conducted at each stadium with the stadium name and city.

SELECT S.Stadium_name,S.City,COUNT(MS.Schedule_Id) AS MatchesConducted
FROM IPL_Stadium S
LEFT JOIN
IPL_Match_Schedule MS ON S.Stadium_Id = MS.Stadium_Id
GROUP BY S.Stadium_name, S.City;

#3.	In a given stadium, what is the percentage of wins by a team which has won the toss?

SELECT S.Stadium_name,
(SUM(CASE WHEN M.Match_Winner = M.Toss_Winner THEN 1 ELSE 0 END) * 100) / COUNT(MS.Schedule_Id) AS WinPercentage
FROM IPL_Stadium S
LEFT JOIN
IPL_Match_Schedule MS ON S.Stadium_Id = MS.Stadium_Id
LEFT JOIN
IPL_Match M ON MS.Match_Id = M.Match_Id
GROUP BY S.Stadium_name;

#4.	Show the total bids along with the bid team and team name.

SELECT BD.Bid_Team,T.Team_name,sum(bp.NO_OF_BIDS) as total_bids
FROM IPL_Bidding_Details bd
JOIN
IPL_Team t ON bd.Bid_Team = t.Team_Id
join
ipl_bidder_points bp on bp.BIDDER_ID=bd.bidder_id
group by bd.Bid_Team,T.Team_name ;

#5.	Show the team id who won the match as per the win details.
SELECT t.team_id,M.Match_Id, M.Match_Winner AS WinningTeamId, T.Team_name AS WinningTeamName
FROM IPL_Match M
INNER JOIN
IPL_Team T ON M.Match_Winner = T.Team_Id
group by t.team_id,m.match_id;



#6.	Display total matches played, total matches won and total matches lost by the team along with its team name.

SELECT T.Team_name,sum(TS.Matches_played) as total_matches_palyed,
sum(TS.Matches_won)as total_matches_won ,sum(TS.Matches_lost)as total_matches_lost
from IPL_Team T
join
IPL_Team_Standings TS ON T.Team_Id = TS.Team_Id
group by t.team_id;


#7.	Display the bowlers for the Mumbai Indians team.

SELECT P.Player_name,t.team_name,tp.player_role
from IPL_Player P
join
IPL_Team_players TP on P.Player_Id = TP.Player_Id
join
IPL_Team T on TP.Team_Id = T.Team_Id
where T.Team_name = 'Mumbai Indians'
and tp.Player_role = 'Bowler';

#8.	How many all-rounders are there in each team, Display the teams with more than 4 
#all-rounders in descending order.

SELECT t.Team_name,COUNT(*) AS AllRoundersCount
FROM IPL_Team t
JOIN
IPL_Team_players tp ON t.Team_Id = tp.Team_Id
JOIN
IPL_Player p ON tp.Player_Id = p.Player_Id
WHERE tp.player_role IN ('All-Rounder')
GROUP BY t.Team_name
HAVING AllRoundersCount > 4
ORDER BY AllRoundersCount DESC;

#9.Write a query to get the total bidders points for each bidding status of those bidders
#who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
#Note the total bidders’ points in descending order and the year is bidding year.
#Display columns: bidding status, bid date as year, total bidder’s points

SELECT bd.Bid_Status AS BiddingStatus,
EXTRACT(YEAR FROM BD.Bid_Date) AS Bid_Year,
SUM(bp.Total_points) AS TotalBiddersPoints,bd.bid_team
FROM IPL_Bidding_Details bd
JOIN
IPL_Match_Schedule ms ON bd.Schedule_Id = ms.Schedule_Id
JOIN
ipl_match im on im.MATCH_ID=ms.MATCH_ID
JOIN
IPL_Team csk ON bd.Bid_Team = csk.Team_Id AND im.Match_Winner = csk.Team_id
INNER JOIN
IPL_Bidder_Points bp ON bd.Bidder_Id = bp.Bidder_Id
WHERE csk.team_name='Chennai Super Kings'
and ms.Stadium_Id = 
(SELECT Stadium_Id FROM IPL_Stadium WHERE Stadium_name = 'M. Chinnaswamy Stadium')
GROUP BY bd.Bid_Status, EXTRACT(YEAR FROM BD.Bid_Date),bd.bid_team
ORDER BY TotalBiddersPoints DESC;

#10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
#Note 
#1. use the performance_dtls column from ipl_player to get the total number of wickets
#2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
#3.	Do not use joins in any cases.
#4.	Display the following columns teamn_name, player_name, and player_role

SELECT *
FROM (
SELECT T.Team_name, P.Player_name,TP.Player_role,
SUBSTRING_INDEX(SUBSTRING_INDEX(performance_dtls, 'Wkt-', -1), ' ', 1) AS Wickets       
FROM IPL_Player P,IPL_Team_players TP,IPL_Team T
WHERE P.Player_Id = TP.Player_Id
AND TP.Team_Id = T.Team_Id
and player_role in ('Bowler', 'All-Rounder')
group by p.player_id,TP.Player_role,T.Team_name)AS t
where wickets between 18 and 24
order by wickets desc;

#11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

SELECT B.Bidder_name,
(SUM(CASE WHEN M.Toss_Winner = BD.Bid_Team THEN 1 ELSE 0 END) * 100) / COUNT(BD.Bidder_Id) AS TossWinPercentage
FROM IPL_Bidder_Details B
INNER JOIN
IPL_Bidding_Details BD ON B.Bidder_Id = BD.Bidder_Id
INNER JOIN
IPL_Match_Schedule MS ON BD.Schedule_Id = MS.Schedule_Id
INNER JOIN
IPL_Match M ON MS.Match_Id = M.Match_Id
GROUP BY B.Bidder_name
ORDER BY TossWinPercentage DESC;

#12.	find the IPL season which has min duration and max duration.
#Output columns should be like the below:
#Tournment_ID, Tourment_name, Duration column, Duration

SELECT * FROM
(SELECT Tournmt_Id, Tournmt_name, 
CONCAT(From_date, ' - ', To_date) AS Duration_column, 
DATEDIFF(To_date, From_date) AS Duration
FROM ipl_tournament order by duration limit 1) as cnt

UNION ALL

select * from
(SELECT TOURNMT_ID, TOURNMT_NAME, 
CONCAT(From_date, ' - ', To_date) AS Duration_column, 
DATEDIFF(To_date, From_date) AS Duration
FROM IPL_Tournament order by duration desc limit 1) AS CombinedResult;

#13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. 
#sort the results based on total points in descending order and month-wise in ascending order.
#Note: Display the following columns:
#1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
#Only use joins for the above query queries.

SELECT bd.Bidder_Id,b.Bidder_name,YEAR(bd.Bid_Date) AS Year,
MONTH(bd.Bid_Date) AS Month,SUM(bp.Total_points) AS Total_points
FROM IPL_Bidding_Details bd
JOIN
IPL_Bidder_Points bp
ON bd.Bidder_Id = bp.Bidder_Id
join ipl_bidder_details b
on b.bidder_id=bd.BIDDER_ID
WHERE YEAR(bd.Bid_Date) = 2017
GROUP BY bd.Bidder_Id,b.Bidder_name,YEAR(bd.Bid_Date),MONTH(bd.Bid_Date)
ORDER BY Total_points DESC,Year ASC,Month ASC;

#14.	Write a query for the above question using sub queries by having the same constraints as the above question.

SELECT Bidder_Id, Bidder_name, YEAR(Bid_Date) AS "Year", MONTH(Bid_Date) AS "Month", Total_points
FROM (
    SELECT bd.Bidder_Id, ip.Bidder_name, bd.bid_Date, SUM(bp.Total_points) AS Total_points
    FROM IPL_Bidding_Details bd
    JOIN IPL_Bidder_Points bp
ON bd.Bidder_Id = bp.Bidder_Id
    join ipl_bidder_details ip
on ip.bidder_id=bd.BIDDER_ID
    WHERE YEAR(bd.Bid_Date) = 2017
    GROUP BY bd.Bidder_Id, ip.Bidder_name,bd.bid_date,year(bd.bid_date),month(bd.bid_date)
) AS Subquery
ORDER BY Total_points DESC, "Year", "Month";

#15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
#Output columns should be:
#like:
#Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, 
#Lowest_3_Bidders  --> columns contains name of bidder;

WITH BiddersWithPoints AS (
SELECT BD.Bidder_Id,BD.Bidder_name,SUM(BP.Total_points) AS TotalPoints
FROM IPL_Bidding_Details BD
INNER JOIN
IPL_Bidder_Points BP ON BD.Bidder_Id = BP.Bidder_Id
WHERE EXTRACT(YEAR FROM BD.Bid_Date) = 2018
GROUP BY BD.Bidder_Id, BD.Bidder_name)

select * from
(SELECT bd.Bidder_Id, Total_Points, Bidder_name AS Highest_lowest_Bidders
FROM ipl_bidder_points bp
join ipl_bidder_details bd on bd.BIDDER_ID=bp.BIDDER_ID
ORDER BY Total_Points DESC limit 3) as cnt

union all

select * from 
(SELECT bd.Bidder_Id,Total_Points, bidder_name AS Lowest_3_Bidders
FROM ipl_bidder_points bp
join
ipl_bidder_details bd on bd.BIDDER_ID=bp.BIDDER_ID
ORDER BY Total_Points ASC limit 3) cont;

#16.	Create two tables called Student_details and Student_details_backup.

#Table 1: Attributes 		Table 2: Attributes
#Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

#Feel free to add more columns the above one is just an example schema.
#Assume you are working in an Ed-tech company namely Great Learning where you will be
# inserting and modifying the details of the students in the Student details table.
# Every time the students changed their details like mobile number,
 #You need to update their details in the student details table.  
 #Here is one thing you should ensure whenever the new students' details come ,
 #you should also store them in the Student backup table so that if you modify the details in
 #the student details table, you will be having the old details safely.
#You need not insert the records separately into both tables rather Create a trigger
 #in such a way that It should insert the details into the Student back table when you 
# inserted the student details into the student table automatically.

CREATE TABLE Student_Details (
    Student_id INT PRIMARY KEY,
    Student_name VARCHAR(255),
    Mail_id VARCHAR(255),
    Mobile_no VARCHAR(15)
);

CREATE TABLE Student_Backup (
    Student_id INT PRIMARY KEY,
    Student_name VARCHAR(255),
    Mail_id VARCHAR(255),
    Mobile_no VARCHAR(15),
    Timestamp TIMESTAMP
);

