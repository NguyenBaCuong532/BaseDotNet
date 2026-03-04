




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[viewCardExport_lift]
AS
SELECT        TOP (100) PERCENT d.custid AS [Personal Number], [dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) AS [Lasst name], 
'' AS [First Name], 'Default' AS [Master group], p.RoomCode AS Department, 'floor ' + CAST(r.Floor AS nvarchar) AS [User template], 
                         [Card_Hex]  AS [Card serial number], '' AS [Card serial number2], '' AS [Card serial number3], convert(nvarchar(30),a.IssueDate,120) AS [Entry date], 
                         isnull(case when a.Card_St = 3 then convert(nvarchar(30),a.IssueDate,120) else null end,'') AS [Exit date]
						 --,SUBSTRING(UPPER(master.dbo.fn_varbintohexstr(CONVERT(varbinary, CAST(c.Card_Cd AS bigint)))), 3, 16) as tt
						 --,c.Card_Cd
						 ,a.CardId
FROM            dbo.MAS_Cards AS a INNER JOIN
				dbo.MAS_Customers AS d ON a.custId = d.CustId inner join
                         dbo.MAS_Apartment_Member AS b ON d.CustId = b.CustId INNER JOIN
						 MAS_Apartments as p on b.ApartmentId = p.ApartmentId and a.ApartmentId = b.ApartmentId inner join
						 MAS_Rooms r on p.RoomCode = r.RoomCode inner join
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code INNER JOIN
						 MAS_Contacts cc on p.Cif_No = cc.Cif_No 
                         
						 where not cardid in (select CardId From MAS_Card_Sync where IsLift = 1)

union all
SELECT        TOP (100) PERCENT c.Guid_Cd AS [Personal Number], [dbo].[fChuyenCoDauThanhKhongDau] (d.FullName) AS [Lasst name], 
'' AS [First Name], 'Default' AS [Master group], 'Sunshine VIP' AS Department, 'all floor' AS [User template], 
                         [Card_Hex]  AS [Card serial number], '' AS [Card serial number2], '' AS [Card serial number3], convert(nvarchar(30),a.IssueDate,120) AS [Entry date], 
                         isnull(case when a.Card_St = 3 then convert(nvarchar(30),a.IssueDate,120) else null end,'') AS [Exit date]
						 --,SUBSTRING(UPPER(master.dbo.fn_varbintohexstr(CONVERT(varbinary, CAST(c.Card_Cd AS bigint)))), 3, 16) as tt
						 --,c.Card_Cd
						 ,a.CardId
FROM            dbo.MAS_Cards AS a 
			INNER JOIN
   --                      dbo.MAS_Apartments AS b ON a.ApartmentId = b.ApartmentId INNER JOIN
                         dbo.MAS_CardBase AS c ON a.CardCd = c.Code 
                         left join dbo.MAS_Customers AS d ON a.CustId = d.CustId
						 where IsVip = 1 and not cardid in (select CardId From MAS_Card_Sync where IsLift = 1)
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'viewCardExport_lift';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'd
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'viewCardExport_lift';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 418
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 456
               Bottom = 136
               Right = 626
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 6
               Left = 664
               Bottom = 136
               Right = 834
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'viewCardExport_lift';

