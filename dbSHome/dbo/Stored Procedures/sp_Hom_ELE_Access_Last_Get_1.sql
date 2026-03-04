
/****** Script for SelectTopNRows command from SSMS  ******/
-- exec sp_Hom_ELE_Floor_View null,'003545','NFC-985F43','03','R1','CT1'
CREATE procedure [dbo].[sp_Hom_ELE_Access_Last_Get]
	@UserId			nvarchar(50),
	@mode			int
as
	begin try
		declare @logid bigint

		set @logid = (select top 1 l.LogId from MAS_Elevator_Log l 
				where l.UserId = @UserId and l.LogDt > dateadd(minute,-1,getdate()) 
				order by l.LogDt desc)
		

		select t.[FloorNumber] as HardWareId
			  ,d.ProjectCd as ProjectCd
			  ,p.ProjectName
			  ,T.AreaCd as BuildCd
			  ,T.BuildZone as BuildZone
			  ,t.[FloorName]
			  ,t.[FloorNumber] as FloorNum
			  ,t.FloorType 
			  ,case when exists(select 1 from MAS_Elevator_User where userId = @UserId and floorName = t.FloorName) then 1 else 0 end isLastest
		FROM [MAS_Elevator_Floor] t
			join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
			join MAS_Elevator_Log l on d.HardwareId = l.HardwareId
			join MAS_Projects p on d.ProjectCd = p.projectCd 
			join UserInfo u on u.UserId = try_cast(l.userId as uniqueidentifier)
		  WHERE l.logid = @logid
				and d.IsActived = 1
				and exists(SELECT a.[CardCd]
					FROM [dbo].[MAS_Cards] a 
						join MAS_CardBase b on a.CardCd = b.Code 
					WHERE (CustId = u.CustId) 
						and a.Card_St = 1
						and (T.FloorType = 'CC'
							or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
								and (exists(select 1 from MAS_Apartment_Card ac 
									join MAS_Apartments ma on ac.ApartmentId = ma.ApartmentId 
									join MAS_Rooms mr on ma.RoomCode = mr.RoomCode 
									join MAS_Buildings mb on mr.BuildingCd = mb.BuildingCd 
									where ac.CardId = a.CardId and mr.FloorNo = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.AreaCd)
									)
								)
							or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
							or ((a.CardTypeId = 4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd and ec.FloorNumber = t.FloorNumber))
							) 
						)
			ORDER BY t.[FloorNumber]


			end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_Access_Last_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' + @UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FloorInfo', 'GET', @SessionID, @AddlInfo
	end catch