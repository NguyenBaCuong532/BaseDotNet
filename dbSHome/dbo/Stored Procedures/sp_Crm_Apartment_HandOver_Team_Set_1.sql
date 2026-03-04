-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	create PROCEDURE [dbo].[sp_Crm_Apartment_HandOver_Team_Set]
	@UserId nvarchar ( 450 ), 
	@HandOverTeamId bigint,
	@DepartmentCd nvarchar(100),
	@DepartmentName nvarchar(100),
	@Type int = 1
	AS 
	BEGIN TRY
	IF EXISTS ( SELECT HandOverTeamId FROM dbo.CRM_Apartment_HandOver_Team WHERE HandOverTeamId = @HandOverTeamId) 
		BEGIN
			UPDATE [dbo].[CRM_Apartment_HandOver_Team]
			   SET DepartmentCd = @DepartmentCd,
			       DepartmentName =@DepartmentName,
				   Type = @Type
			 WHERE HandOverTeamId = @HandOverTeamId
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].[CRM_Apartment_HandOver_Team]
							   ([DepartmentCd]
							   ,[DepartmentName]
							   ,[Type])
						values (@DepartmentCd,
								@DepartmentName,
								@Type)
				 set @HandOverTeamId = @@IDENTITY
		END 
		select * from CRM_Apartment_HandOver_Team WHERE HandOverTeamId = @HandOverTeamId
		END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = 'sp_Crm_Apartment_HandOver_Attach_Set ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'CRM_Apartment_HandOver_Team',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch