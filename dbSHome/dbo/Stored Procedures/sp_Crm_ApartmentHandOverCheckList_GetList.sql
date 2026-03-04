

CREATE procedure [dbo].[sp_Crm_ApartmentHandOverCheckList_GetList]
	@UserId nvarchar(450)=null,
	@HandOverDetailId bigint,
	@ProjectCd nvarchar(50)
as
	begin try		
		 SELECT [CheckListId]
			  ,[Item]
			  ,[Note]
			  ,[Manufactor]
			  ,[ParentId]
			  ,[ProjectCd]
			  ,[HandOverDetailId]
			  ,0 as IsDuLieuMau
			  ,[SapXep]
			  ,[Chon]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_CheckList]
		  WHERE ParentId is null and ProjectCd = @ProjectCd and IsDuLieuMau = 1 and HandOverDetailId is null
		  ORDER BY SapXep

		 SELECT [CheckListId]
			  ,[Item]
			  ,[Note]
			  ,[Manufactor]
			  ,[ParentId]
			  ,[ProjectCd]
			  ,[HandOverDetailId]
			  ,[IsDuLieuMau]
			  ,[SapXep]
			  ,[Chon]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_CheckList]
		  WHERE ParentId is not null and ProjectCd = @ProjectCd and IsDuLieuMau = 0 and HandOverDetailId = @HandOverDetailId
		  ORDER BY SapXep

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_ApartmentHandOverCheckList_GetList ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_CheckList', 'GET', @SessionID, @AddlInfo
	end catch