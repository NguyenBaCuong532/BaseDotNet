

-- =============================================
-- Author:		duongpx
-- Create date: 8/26/2025 3:31:09 PM
-- Description:	Lịch sử gọi thang
-- =============================================
CREATE   procedure [dbo].[sp_app_elevator_access_view]
	@userId uniqueidentifier,
	@CardCd			nvarchar(50) =null,
	@HardwareId	    nvarchar(200) = null,
	@ProjectCd      nvarchar(50) = null,
	@BuildCd		nvarchar(50) = null,
	@BuildZone      nvarchar(50) = null
	, @acceptLanguage NVARCHAR(50) = 'vi-VN'
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
									join MAS_Apartments ma on (ac.apartOid = ma.oid or (ac.apartOid is null and ac.ApartmentId = ma.ApartmentId))
									left join MAS_Elevator_Floor ef on ma.floorOid = ef.oid
									join MAS_Buildings mb on ma.buildingOid = mb.oid
									where ac.CardId = a.CardId and ISNULL(ef.FloorName, ma.floorNo) = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.buildingCd)
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
		set @ErrorMsg					= 'sp_app_elevator_access_view ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' --+ @UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FloorInfo', 'GET', @SessionID, @AddlInfo
	end catch