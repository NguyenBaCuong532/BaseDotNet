














/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[viewCardExport_lobby]
AS
SELECT        TOP (100) PERCENT a.CardCd AS [Person No],'CH/' + rtrim(b.RoomCode) AS Organization,

cast([dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) as nvarchar(31)) AS [Person Name], 

case when IsSex = 1 then 1 else 2 end AS [Gender], 1 AS [ID Type], null as [ID No.],
 FORMAT(d.birthday,'yyy/MM/dd') AS [Date of Birth], null[Phone No.],null[Job Title],null[Address],null[Email],null[Country],null[City],1[Degree],
 1 [Device Operation Role],FORMAT(a.IssueDate,'yyy/MM/dd') AS [On Board Date],null AS [Termination Date],
                         [Card_Num]  AS [Card No.]
						 --,c.Card_Cd
						 --,a.CardCd
FROM            dbo.MAS_Cards AS a INNER JOIN
                         dbo.MAS_Apartments AS b ON a.ApartmentId = b.ApartmentId INNER JOIN
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code INNER JOIN
                         dbo.MAS_Customers AS d ON a.CustId = d.CustId
						 where not cardid in (select CardId From MAS_Card_Sync where isLobby = 1)

union all

SELECT        TOP (100) PERCENT a.CardCd AS [Person No],'VIP/' + a.CardCd AS Organization,

cast([dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) as nvarchar(31)) AS [Person Name], 

1 AS [Gender], 1 AS [ID Type], null as [ID No.],
 '' AS [Date of Birth], null[Phone No.],null[Job Title],null[Address],null[Email],null[Country],null[City],1[Degree],
 1 [Device Operation Role],FORMAT(a.IssueDate,'yyy/MM/dd') AS [On Board Date],null AS [Termination Date],
                         [Card_Num]  AS [Card No.]
						 --,c.Card_Cd
						 --,a.CardCd
FROM            dbo.MAS_Cards AS a INNER JOIN
                         --dbo.MAS_Apartments AS b ON a.ApartmentId = b.ApartmentId INNER JOIN
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code 
                         left join dbo.MAS_Customers AS d ON a.CustId = d.CustId
						 where not cardid in (select CardId From MAS_Card_Sync where isLobby = 1) and IsVip = 1