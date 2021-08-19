-- This was a practice file of querying NHL stats for the 2021 season, after about 3 days of 
--Learning SQL, among other things. This was my experience after only about 3 days of practice.
-- So I'm probably much better now.
--Performing SQL Queries on a database of NHL statistics from the 2020-2021 season

--Let's start by checking if I imported the database correctly...
select *
from NHLStats2021..['NHL_Player_Stats']

select *
from NHLStats2021..['NHL_Playoff_Stats']

--Yes I did!
--How many players played in the NHL this year?

select Count(Player_Name) as Number_of_Players
from NHLStats2021..['NHL_Player_Stats']

select SUM(Points) as Total_Points
from NHLStats2021..['NHL_Player_Stats']

-- 913 different people played in the NHL! What's your excuse?
-- Next, let's order by most points in each team

select *
from NHLStats2021..['NHL_Player_Stats']
order by Team, Points desc;

--Actually, lets only include The team and the points, not everything...

select Player_Name, Team, Points
from NHLStats2021..['NHL_Player_Stats']
order by Team, Points desc;

--On second thought, nicer to have Goals and assists too, to see where the points came from.


select Player_Name, Team, Goals, Assists, Points
from NHLStats2021..['NHL_Player_Stats']
where Team like 'VAN'
order by Points desc;

--Now let's do some math. How about points per game played?

select Player_Name, Team, Games, Points, (Points/Games) as Pts_per_Gm
from NHLStats2021..['NHL_Player_Stats']
order by (Points/Games) desc;

--Check who the top 10 scorers were in the league this year (Top function yay!

Select Top 10 Player_Name, Team, MAX(Goals) as Most_Goals
From NHLStats2021..['NHL_Player_Stats']
Group by Player_Name, Team
Order by Most_Goals desc ;

-- Which players got most of their points from scoring goals? Which got most of their points by assisting??

select Player_Name, Team, Goals, Assists, Points, (Goals/Points)*100 as Goals_Percentage
from NHLStats2021..['NHL_Player_Stats']
where Points != 0 
order by (Goals/Points)*100, Goals desc;

select Player_Name, Team, Goals, Assists, Points, (Assists/Points)*100 as Assists_Percentage
from NHLStats2021..['NHL_Player_Stats']
where Points != 0 
order by (Assists/Points)*100 desc, Assists desc;

--Slight Problem, we are getting several players who have only scored a single goal or gotten a single assist. Let's filter these out.

select Player_Name, Team, Goals, Assists, Points, (Goals/Points)*100 as Goals_Percentage
from NHLStats2021..['NHL_Player_Stats']
where Points != 0 and goals>=10
order by (Goals/Points)*100 desc, Goals desc;

select Player_Name, Team, Goals, Assists, Points, (Assists/Points)*100 as Assists_Percentage
from NHLStats2021..['NHL_Player_Stats']
where Points != 0 and Assists>=10
order by (Assists/Points)*100 desc, Assists desc;


--Let's see a top 5 scorers for each team. This will require us to make a CTE, and I want each team to have 5 scorers each.

with Top5 as
(select *, row_number() over (Partition by Team order by points desc) as rn
from NHLStats2021..['NHL_Player_Stats'])

select *
From Top5
where rn <=5;

-- And the points per game of the Top 5 players on each team

with Top5 as
(select *, row_number() over (Partition by Team order by points desc) as rn
from NHLStats2021..['NHL_Player_Stats'])

select Player_Name, Team, Games, Points, (Points/Games) as Pts_per_Gm
From Top5
where rn <=5;

--We also ave a goalie stats table. Let's check that out!
--Order by save percentage because that's the best stat, obviously. I was a goaltender myself in high school, can you tell?
--Only include goaltender who've played a decent amount of games.

select *
From NHLStats2021..['NHL_Goalie_Stats']
where Games>5 
order by 'SV%' desc;


-- Lets join the regular season and Playoff tables. I'll use a right join because there are many players
-- Who played during the regular season but not the playoffs

Select Poff.Name, Poff.Team, reg.Goals as regular_season_goals, reg.Assists as regular_season_assists, reg.Points as regular_season_points, Poff.G as playoff_goals, Poff.A as playoff_assists, Poff.P as playoff_points 
From NHLStats2021..['NHL_Player_Stats'] reg
Right Join NHLStats2021..['NHL_Playoff_Stats'] Poff
on reg.Player_Name=Poff.Name
and reg.Team=Poff.Team
order by Poff.P desc

--And our tables are merged, Matching both shared columns, the name of the player and the team they play for.
--Notice that there are several players who have 'NULL' for their regular season points. This is because the two tables
--have inconsistant data entry. For example, the player 'Nicholas Suzuki' is named 'Nich Suzuki' in the regualr season table.
--Additionally, the team 'TBL', stading for the Tampa Bay Lightning, have their team code 'TBL' in the playoff table, but
--have the code 'TB' in the regualr season table. This data will require some cleaning.

Select Poff.Name, Poff.Team, reg.Goals as regular_season_goals, reg.Assists as regular_season_assists, reg.Points as regular_season_points, Poff.G as playoff_goals, Poff.A as playoff_assists, Poff.P as playoff_points 
From NHLStats2021..['NHL_Player_Stats'] reg
Right Join NHLStats2021..['NHL_Playoff_Stats'] Poff
on reg.Player_Name=Poff.Name
order by Poff.P desc

--Doing the join again without trying to match the team fixes many of the problems. We still have some issues, like 
--'Suzuki' again. We can spend some time in another project cleaning these tables up with some SQL commands.
--Let's add in points per game now, to see if players are consistant from the regualr season to the post season.

Select Poff.Name, Poff.Team, reg.Goals as regular_season_goals, reg.Assists as regular_season_assists, 
reg.Points as regular_season_points, Poff.G as playoff_goals, Poff.A as playoff_assists, Poff.P as playoff_points,
(reg.Points/reg.Games) as regular_season_PPG, (Poff.P/Poff.GP) as playoff_PPG
From NHLStats2021..['NHL_Player_Stats'] reg
Right Join NHLStats2021..['NHL_Playoff_Stats'] Poff
on reg.Player_Name=Poff.Name
order by Poff.P desc

--And the only problems we seem to have are still the NULLs. This can, again, be fixed with some data cleaning.


--How about the percentage of points that each team scored, out of the total?
--In here are some of the things I tried. Partitioning into sets got me each teams total points, but
--than each percentage would add that total points for each team equal to the number of players they had, instead of 
--Just adding all the total points together. So I tried to do it without a CTE, and that was also Frustrating.
--Leaving this here so others can see what I tried and my knowledge of partitions and such.
--I'm pretty sure it's mostly a problem with my formula, which isn't an SQL issue, it's an "I'm dumb" issue. I have a lot of those.

--Each Teams Points
select Team, Sum(Points) as Total_Points
From NHLStats2021..['NHL_Player_Stats']
Group by Team
Order by Total_Points desc;

-- And the same query using a CTE


with TeamPoints as
(select Team, Sum(Points) as Total_Points
From NHLStats2021..['NHL_Player_Stats']
Group by Team)

select Team, Total_Points--, SUM(Total_Points), Total_Points/(Sum(Total_Points))
From TeamPoints								
where Team not like 'FA' --Certain players are listed as a free agent, which does not put their points into a team list
group by Team, Total_Points
order by Total_Points desc;

