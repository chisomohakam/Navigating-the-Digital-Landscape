-- Creating DB and Tables 
CREATE DATABASE AfriTechDB;

CREATE TABLE StagingData (
    CustomerID INT,
    CustomerName TEXT,
    Region TEXT,
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType TEXT,
    TransactionYear TEXT,
    TransactionDate DATE,
    ProductPurchased TEXT,
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor TEXT,
    InteractionDate DATE,
    Platform TEXT,
    PostType TEXT,
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment TEXT,
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT
);
--CustomerData Table 
CREATE TABLE CustomerData (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255),
    Region VARCHAR(255),
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType VARCHAR(50)
);
--Transactions Table 
CREATE TABLE Transactions (
    TransactionID SERIAL PRIMARY KEY,
    CustomerID INT,
    TransactionYear VARCHAR(4),
    TransactionDate DATE,
    ProductPurchased VARCHAR(255),
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);
--Socialmedia Table 
CREATE TABLE SocialMedia (
    PostID SERIAL PRIMARY KEY,
    CustomerID INT,
    InteractionDate DATE,
    Platform VARCHAR(50),
    PostType VARCHAR(50),
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment VARCHAR(50),
    Competitor VARCHAR(255),
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT,
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


-- Insert customer data
INSERT INTO CustomerData (CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType FROM StagingData;

-- Insert transaction data
INSERT INTO Transactions (CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor)
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor
FROM StagingData WHERE TransactionDate IS NOT NULL;


-- Insert social media data
INSERT INTO SocialMedia (CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse)
SELECT CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
FROM StagingData WHERE InteractionDate IS NOT NULL;

--Dropping StagingData 
drop table stagingDatas;

-- Data Validation 
select *
from socialmedia
limit 5

select count(*)
from customerdata
 
select count(*)
from socialmedia

select *
from socialmedia

--Checking for missing data 
	
select count (*) 
from customerdata
where customerid is null;

select count (*) 
from socialmedia 
where competitor is null;

select count (*) 
from customerdata
where customerid is null;
-- Exploratory Data Analysis(EDA).
--customer EDA
SELECT region, COUNT(*) AS customercount 
FROM customerdata 
GROUP BY region 
ORDER BY customercount desc;

select count(distinct customerId) as UniqueCustomer 
from customerdata ;

SELECT 'Customer Name' AS Customer, 
COUNT(*) AS No_of_Not_Null 
FROM customerdata 
WHERE customername IS NOT NULL 
UNION ALL 
SELECT 'Region' AS Customer, 
COUNT(*) AS No_of_Not_Null 
FROM customerdata 
WHERE region IS NOT NULL;

--Transactions EDA

SELECT 
  TO_CHAR(AVG(purchasedamount), '$999,999,999.00') AS AveragePurchaseAmount,
  TO_CHAR(MIN(purchasedamount), '$999,999,999.00') AS MinPurchaseAmount,
  TO_CHAR(MAX(purchasedamount), '$999,999,999.00') AS MaxPurchaseAmount,
  TO_CHAR(SUM(purchasedamount), '$999,999,999.00') AS TotalSales
FROM transactions;

select productpurchased, 
	count (*) as NumberOfSales,
	SUM(purchasedamount) as TotalSales
	from transactions
group by productpurchased 
order by NumberOfSales desc

select productpurchased,
count (*) as transactioncount,
sum(purchasedamount) as totalpurchases 
from transactions
where productpurchased is not null
group by productpurchased 
order by transactioncount asc;

select productrecalled, 
	count (*) as NumberOfSales,
	TO_CHAR(AVG(purchasedamount), '$999,999,999.00') AS AverageAmount
	from transactions
	where purchasedamount is not null 
group by productrecalled  

-- SocialMedia EDA 
select platform,
	to_char(avg(engagementlikes), '999,999,999.00') as AverageLikes,
	to_char(sum(engagementlikes), '999,999,999') as TotalLikes
from socialmedia
group by platform
order by AverageLikes desc, TotalLikes desc;
	
SELECT 'platform' AS platform, 
COUNT(*) AS No_of_Not_Null 
FROM socialmedia
WHERE platform IS NOT NULL 
UNION ALL 
SELECT 'sentiment' AS sentiment, 
COUNT(*) AS No_of_Not_Null 
FROM socialmedia
WHERE sentiment IS NOT NULL;

-- ANALYSIS 
--Brand mentions across socialmedia platforms 
select platform,
count (*) as TimesMentioned
from socialmedia 
where brandmention = 'true'
group by platform
order by TimesMentioned desc;

-- Sentiment Score(%)
select sentiment, count (*) * 100/
(select count(*) from socialmedia) as Sentiment_Percentage
from socialmedia 
group by sentiment
order by Sentiment_Percentage desc;

-- Engagement Rate 
select round (avg ((engagementlikes +engagementshares + engagementcomments)/  
nullif (userfollowers, 0)), 3) as EngagementRate
from socialmedia

-- BrandMention By Competitor 
select sum(case when brandmention = 'true' then 1 else 0 end) as BrandMention,
	   sum(case when competitor = 'true' then 1 else 0 end) as Competitor
from socialmedia;

-- Influencer Score 
select round(avg (influencerscores), 3) as InfluencerScore
from socialmedia;

-- Time Trend Analysis 
select to_char(date_trunc('month', interactiondate), 'yyyy/mm/dd') as month,
count (*) as Mentions, platform
from socialmedia
where brandmention = 'true'
group by month, platform
order by mentions desc;

--Crisis Response Time
select avg(date_part('epoch', (cast(firstresponsetime as timestamp ) - cast(crisiseventtime as timestamp)))/3600/24)
	as averageresponsetime
	from  socialmedia 
where crisiseventtime is not null and firstresponsetime is not null 

-- Resolution rate 
select count (*) * 100 /
(select count(*) from socialmedia where crisiseventtime is not null ) as ResolutionRate
from socialmedia
where resolutionstatus = 'true'

-- Top Influencers 
select customerid,round (avg (influencerscores), 0) influencerscores
from socialmedia
group by customerid
order by influencerscores desc
limit 10;

--  Content Effectiveness 
select posttype, round(avg (engagementlikes +engagementshares + engagementcomments), 2) Engagements 
from socialmedia
group by posttype
order by engagements desc

-- Total Revenue By Platform 
select s.platform, sum(t.Purchasedamount) TotalRevenue
from socialmedia s
join Transactions t on s.customerid = t.customerid
where t.purchasedamount is not null 
group by s.platform 
order by TotalRevenue desc;

-- Top 10 Customers and There Region
select c.customerid, c.customername, c.region,
coalesce(sum (t.purchasedamount), 0) totalpurchase 
from customerdata c
join Transactions t on c.customerid = t.customerid
group by c.customerid, c.customername, c.region
order by totalpurchase desc
limit 10;

-- Products per Engagement
select
	t.productpurchased,
	sum(s.engagementlikes) EngagementLikes,
	sum(s.engagementshares)EngagementShares,
	sum(s.engagementcomments) EngagementComments
from transactions t
join socialmedia s on s.customerid = t.customerid
group by t.productpurchased
order by EngagementLikes desc,EngagementShares desc, EngagementComments desc;




