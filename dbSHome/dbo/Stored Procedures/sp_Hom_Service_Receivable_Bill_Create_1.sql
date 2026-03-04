-- exec sp_Hom_Service_Receivable_Bill_Create '81739c5c-2ca0-4e0f-acab-63373ea8a34a',null,

CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Create]
	@userId nvarchar(450),
	@receiveIds	nvarchar(max)=null,
	@ProjectCd nvarchar(30)
as
	begin try

		if @receiveIds is null or @receiveIds = ''
		begin
			UPDATE t
			   SET IsBill = 0
				  ,bill_st = 0
			 FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join MAS_Buildings c on b.BuildingCd = c.BuildingCd 
			 WHERE IsPayed = 0 
				and isExpected = 1
				and t.ProjectCd = @ProjectCd

			SELECT t.ReceiveId
				  ,0 as receiveBillStatus
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join MAS_Buildings c on b.BuildingCd = c.BuildingCd 
			 WHERE IsPayed = 0 
				and isExpected = 1
				and t.ProjectCd = @ProjectCd
		end
		else
		begin
			UPDATE t
			   SET IsBill = 0
			      ,bill_st = 0
			 FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join MAS_Buildings c on b.BuildingCd = c.BuildingCd 
			 WHERE isExpected = 1
				--and IsPayed = 0 
				and t.ReceiveId in (SELECT part FROM [dbo].[SplitString](@receiveIds,',')) 
			
			SELECT t.ReceiveId
				  ,0 as receiveBillStatus
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join MAS_Buildings c on b.BuildingCd = c.BuildingCd 
			 WHERE isExpected = 1
				and IsPayed = 0 
				and t.ReceiveId in (SELECT part FROM [dbo].[SplitString](@receiveIds,',')) 
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Create' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo
	end catch