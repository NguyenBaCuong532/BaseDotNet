

CREATE procedure [dbo].[sp_Crm_ApartmentHandOver_GetList]
	@UserId nvarchar(450)=null,
	@ProjectCd nvarchar(50)=null,
	@BuildCd nvarchar(50)=null
as
	begin try		
		--SELECT [HandOverId]
		--	  ,[TitleHandOver]
		--	  ,[OutDateHandOver]
		--	  ,[RequestDateCus]
		--	  ,a.[BuildingCd] as BuildingCd
		--	  ,c.BuildingName
		--	  ,a.[ProjectCd] as ProjectCd
		--	  ,b.ProjectName 
		--	  ,a.Note
		--	  ,a.HandOverStatus
		--	  ,[IsClose]
		--	  ,[Created]
		--	  ,[CreatedBy]
		--	  ,[Modified]
		--	  ,[ModifiedBy]
		--FROM [dbo].[CRM_Apartment_HandOver] a inner join .dbo.BLD_Projects b on a.ProjectCd = b.ProjectCd
		--									   inner join .dbo.BLD_Buildings c on a.BuildingCd = c.BuildingCd
		--where (@ProjectCd is null or a.ProjectCd like @ProjectCd +'%')
		--and   (@BuildCd is null or a.BuildingCd  like @BuildCd +'%')

		SELECT [HandOverDetailId]
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
	  FROM [dbo].[CRM_Apartment_HandOver_Detail]
	  where (@ProjectCd is null or ProjectCd like @ProjectCd +'%')
		and   (@BuildCd is null or BuildingCd  like @BuildCd +'%')

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_ApartmentHandOver_GetList ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver,CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch