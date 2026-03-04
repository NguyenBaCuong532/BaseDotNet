CREATE procedure [dbo].[sp_res_elevator_bank_shafts_get]
	@UserId UNIQUEIDENTIFIER = NULL,
	@IdEBS int = null,
	@ProjectCd  nvarchar(30),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try		


	SELECT ES.Id,
		   ES.ElevatorBank,
		   ES. ElevatorShaftName, 
		   ES.ElevatorShaftNumber,
		   ES.ProjectCd ,
		   ES. BuildZone

	FROM [dbo].ELE_BankShaft ES 
		WHERE (@IdEBS IS NULL OR ES.Id = @IdEBS)
		OR ( @ProjectCd IS NULL OR ES.ProjectCd = @ProjectCd)
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_BankShaft_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BankShaft', 'GET', @SessionID, @AddlInfo
	end catch