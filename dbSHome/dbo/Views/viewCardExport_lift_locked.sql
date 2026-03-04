



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[viewCardExport_lift_locked]
AS
SELECT        TOP (100) PERCENT d.custid AS [Personal Number], [dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) AS [Lasst name], 
'' AS [First Name], 'Default' AS [Master group], b.RoomCode AS Department, 'floor ' + CAST(r.Floor AS nvarchar) AS [User template], 
                         [Card_Hex]  AS [Card serial number], '' AS [Card serial number2], '' AS [Card serial number3], convert(nvarchar(30),a.IssueDate,120) AS [Entry date], 
                         isnull(case when a.Card_St = 3 then convert(nvarchar(30),a.IssueDate,120) else null end,'') AS [Exit date]
						 --,SUBSTRING(UPPER(master.dbo.fn_varbintohexstr(CONVERT(varbinary, CAST(c.Card_Cd AS bigint)))), 3, 16) as tt
						 ,a.CardCd
						 ,a.CardId
FROM            dbo.MAS_Cards AS a INNER JOIN
					dbo.MAS_Customers AS d ON a.custId = d.CustId inner join
                         MAS_Apartment_Member cc on d.CustId = cc.CustId  INNER JOIN
						 dbo.MAS_Apartments AS b ON cc.ApartmentId = b.ApartmentId INNER JOIN
						 MAS_Rooms r on b.RoomCode = r.RoomCode inner join
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code 

						 where a.Card_St = 3 --not cardid in (select CardId From MAS_Card_Sync where IsLift = 1)

union all
SELECT        TOP (100) PERCENT c.Guid_Cd AS [Personal Number], [dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) AS [Lasst name], 
'' AS [First Name], 'Default' AS [Master group], 'Sunshine VIP' AS Department, 'all floor' AS [User template], 
                         [Card_Hex]  AS [Card serial number], '' AS [Card serial number2], '' AS [Card serial number3], convert(nvarchar(30),a.IssueDate,120) AS [Entry date], 
                         isnull(case when a.Card_St = 3 then convert(nvarchar(30),a.IssueDate,120) else null end,'') AS [Exit date]
						 --,SUBSTRING(UPPER(master.dbo.fn_varbintohexstr(CONVERT(varbinary, CAST(c.Card_Cd AS bigint)))), 3, 16) as tt
						 ,a.CardCd
						 ,a.CardId
FROM            dbo.MAS_Cards AS a 
			INNER JOIN
   --                      dbo.MAS_Apartments AS b ON a.ApartmentId = b.ApartmentId INNER JOIN
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code 
                         left join dbo.MAS_Customers AS d ON a.CustId = d.CustId
						 where IsVip = 1 and a.Card_St = 3 --not cardid in (select CardId From MAS_Card_Sync where IsLift = 1)