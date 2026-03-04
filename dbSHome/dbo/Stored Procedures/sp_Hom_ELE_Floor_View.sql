
/****** Script for SelectTopNRows command from SSMS  ******/
-- exec sp_Hom_ELE_Floor_View null,'003545','NFC-985F43','03','R1','CT1'
CREATE procedure [dbo].[sp_Hom_ELE_Floor_View]
	@UserId			nvarchar(50),
	@CardCd			nvarchar(50) =null,
	@HardwareId	    nvarchar(200),
	@ProjectCd      nvarchar(50) = null,
	@BuildCd		nvarchar(50) = null,
	@BuildZone      nvarchar(50) = null
as
	begin try
		declare @Code as nvarchar(50) --= @CardCd
		set		@Code = (select card_num from MAS_CardBase a join MAS_Cards b on a.Code = b.CardCd where Code = @CardCd)

		

		select t.[FloorNumber] as HardWareId
			  ,@ProjectCd as ProjectCd
			  ,(select ProjectName from MAS_Projects where ProjectCd = T.ProjectCd and (@ProjectCd is null or ProjectCd = @ProjectCd)) as ProjectName
			  ,T.buildingCd as BuildCd
			  ,T.BuildZone as BuildZone
			  ,t.[FloorName]
			  ,t.[FloorNumber] as FloorNum
			  ,t.FloorType 
		FROM [MAS_Elevator_Floor] t
			join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
		  WHERE d.HardwareId = @HardwareId 
				and d.IsActived = 1
				and exists(SELECT a.[CardCd]
					FROM [dbo].[MAS_Cards] a 
						join MAS_CardBase b on a.CardCd = b.Code 
					WHERE (Card_Num = @Code) 
						and a.Card_St = 1
						and (T.FloorType = 'CC'
							or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
								and (exists(select 1 from MAS_Apartment_Card ac 
									join MAS_Apartments ma on ac.ApartmentId = ma.ApartmentId 
									join MAS_Rooms mr on ma.RoomCode = mr.RoomCode 
									join MAS_Buildings mb on mr.BuildingCd = mb.BuildingCd 
									where ac.CardId = a.CardId and mr.FloorNo = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.buildingCd)
									)
								)
							or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
							or ((a.CardTypeId = 4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.BuildCd = t.buildingCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.BuildCd = t.buildingCd and ec.FloorNumber = t.FloorNumber))
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
		set @ErrorMsg					= 'sp_Hom_Get_FloorInfo_View ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' + @UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FloorInfo', 'GET', @SessionID, @AddlInfo
	end catch