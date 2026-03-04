CREATE procedure [dbo].[sp_Crm_Apartment_HandOver_Detail_Set]
	@UserID	nvarchar(450),
	@HandOverDetailId bigint,
	@HandOverId bigint,
	@ContractId bigint,
	@RoomCd nvarchar(50),
	@RoomCode nvarchar(50),
	@CustomerName nvarchar(50),
	@PhoneNumber nvarchar(50),
	@BuildingCd nvarchar(50),
	@ProjectCd nvarchar(50),
	@HandOverExpectedDate datetime,
	@RequestDateCus datetime,
	@IsPMCheck bit,
	@IsKTCheck bit,
	@IsBNTCheck bit,
	@IsAgreeReceive bit,
	@IsComplete bit
as
	begin try		
		if not exists(select HandOverDetailId from [CRM_Apartment_HandOver_Detail] where HandOverDetailId = @HandOverDetailId)
		begin
			insert into [dbo].[CRM_Apartment_HandOver_Detail]
			   (HandOverId
			   ,ContractId
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
			   ,[CreatedBy])
			values
			   (@HandOverId
			   ,@ContractId
			   ,@RoomCd
			   ,@RoomCode
			   ,@CustomerName
			   ,@PhoneNumber
			   ,@BuildingCd
			   ,@ProjectCd
			   ,@HandOverExpectedDate
			   ,@RequestDateCus
			   ,@IsPMCheck
			   ,@IsKTCheck
			   ,@IsBNTCheck
			   ,@IsAgreeReceive
			   ,@IsComplete
			   ,getdate()
			   ,@UserID)
			   set @HandOverDetailId = @@IDENTITY
			end
		else
			begin
				update [dbo].[CRM_Apartment_HandOver_Detail]
				set    HandOverId = @HandOverId
					  ,[ContractId] = @ContractId
					  ,[RoomCd] = @RoomCd
					  ,[RoomCode] = @RoomCode
					  ,[CustomerName] = @CustomerName
					  ,[PhoneNumber] = @PhoneNumber
					  ,[BuildingCd] = @BuildingCd
					  ,[ProjectCd] = @ProjectCd
					  ,[HandOverExpectedDate] = @HandOverExpectedDate
					  ,[RequestDateCus] = @RequestDateCus
					  ,[IsPMCheck] = @IsPMCheck
					  ,[IsKTCheck] = @IsKTCheck
					  ,[IsBNTCheck] = @IsBNTCheck
					  ,[IsAgreeReceive] =@IsAgreeReceive
					  ,[IsComplete] = @IsComplete
					  ,[Modified] = getdate()
					  ,[ModifiedBy] = @UserID
				 where HandOverDetailId = @HandOverDetailId
			end
		 if exists (select HandOverDetailId  from CRM_Apartment_HandOver_CheckList where HandOverDetailId = @HandOverDetailId and ProjectCd = @ProjectCd and IsDuLieuMau = 1)
			begin
				Delete from CRM_Apartment_HandOver_CheckList where HandOverDetailId = @HandOverDetailId and ProjectCd = @ProjectCd and IsDuLieuMau = 0
			end
		 insert into [dbo].[CRM_Apartment_HandOver_CheckList]
					   ([Item]
					   ,[Note]
					   ,[Manufactor]
					   ,[ParentId]
					   ,[ProjectCd]
					   ,[HandOverDetailId]
					   ,[IsDuLieuMau]
					   ,[SapXep]
					   ,[Chon]
					   ,[Created]
					   ,[CreatedBy])
		select			[Item]
					   ,[Note]
					   ,[Manufactor]
					   ,[ParentId]
					   ,[ProjectCd]
					   ,@HandOverDetailId
					   ,[IsDuLieuMau]
					   ,[SapXep]
					   ,0
					   ,getdate()
					   ,@UserID
		from           CRM_Apartment_HandOver_CheckList
		where          ProjectCd = @ProjectCd and IsDuLieuMau = 1
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Apartment_HandOver_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Crm_Apartment_HandOver_Set', 'Set', @SessionID, @AddlInfo
	end catch