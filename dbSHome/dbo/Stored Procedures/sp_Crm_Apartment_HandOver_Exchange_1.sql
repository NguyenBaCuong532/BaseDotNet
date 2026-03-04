

CREATE procedure [dbo].[sp_Crm_Apartment_HandOver_Exchange]
	@UserId nvarchar(450)=null,
	@HandOverId nvarchar(50)=null
as
	begin try		
		SELECT [ExchangeId]
		  ,[HandOverId]
		  ,[Title]
		  ,[UserAssign]
		  ,a.[DepartmentCd]
		  ,b.DepartmentName
		  ,StatusType
		  ,b.Type as TypeDepartmentRequest
		  ,case when (StatusType = 0 or StatusType is null) then N'Đang chờ xử lý' else N'Hoàn thành' end StatusName
		  ,[Created]
		  ,[CreatedBy]
		  ,[Modified]
		  ,[ModifiedBy]
	  FROM [dbo].[CRM_Apartment_HandOver_Exchange] a inner join CRM_Apartment_HandOver_Team b on a.DepartmentCd = b.DepartmentCd
	  WHERE (@HandOverId is null or HandOverId = @HandOverId)
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Apartment_HandOver_Exchange ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Exchange', 'GET', @SessionID, @AddlInfo
	end catch