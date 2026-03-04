create procedure [dbo].[sp_Crm_ApartmentHandOver_GetItem]
	@UserID	nvarchar(450),
	@ProjectCd nvarchar(50),
	@BuildCd nvarchar(50),
	@HanOverId bigint
as
	begin try		
		select HandOverId
			  ,TitleHandOver
			  ,OutDateHandOver
			  ,RequestDateCus
			  ,BuildingCd
			  ,ProjectCd
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		from CRM_Apartment_HandOver where HandOverId = @HanOverId and ProjectCd = @ProjectCd and BuildingCd = @BuildCd

		---------------------------------

		select [HandOverDetailId]
			  ,[HandOverId]
			  ,[ContractId]
			  ,[RoomCd]
			  ,[RoomCode]
			  ,[CustomerName]
			  ,[PhoneNumber]
			  ,[BuildingCd]
			  ,[ProjectCd]
			  ,[HandOverExpectedDate]
			  ,[RequestDateCus]
			  ,[IsPMCheck]
			  ,[IsKTCheck]
			  ,[IsBNTCheck]
			  ,[IsAgreeReceive]
			  ,[IsComplete]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		from CRM_Apartment_HandOver_Detail 
		where HandOverId = @HanOverId 
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_ApartmentHandOver_GetItem ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_ApartmentHandOver_GetItem', 'Get', @SessionID, @AddlInfo
	end catch