-- Author:		thanhpdh@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin truc thang may
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Hom_ELE_BankShaft_Set]
	@UserId nvarchar ( 450 ), 
	@Id INT,
	@ElevatorBank INT,
	@ElevatorShaftName nvarchar ( 255 ),
	@ElevatorShaftNumber INT,
	@ProjectCd INT,
	@BuildZone nvarchar ( 255 ) AS BEGIN
		TRY
	IF EXISTS ( SELECT Id FROM dbo.ELE_BankShaft WHERE Id = @Id ) 
	BEGIN
			UPDATE dbo.ELE_BankShaft 
			SET ElevatorBank = @ElevatorBank,
				ElevatorShaftName = @ElevatorShaftName,
				ElevatorShaftNumber = @ElevatorShaftNumber,
				ProjectCd = @ProjectCd,
				BuildZone = @BuildZone,
				created_at = getdate( ),
				created_by = @UserId 
		WHERE
			Id = @Id 
		END 
		ELSE 
		BEGIN
			INSERT INTO dbo.ELE_BankShaft
			( 
				ElevatorBank, 
				ElevatorShaftName, 
				ElevatorShaftNumber, 
				ProjectCd, 
				BuildZone, 
				created_at, 
				created_by 
			)
			VALUES
			(   
				@ElevatorBank,
				@ElevatorShaftName,
				@ElevatorShaftNumber,
				@ProjectCd, 
				@BuildZone, 
				getdate( ),
				@UserId 
			) 
		END 
		END try BEGIN
	catch DECLARE
	@ErrorNum INT,
	@ErrorMsg VARCHAR ( 200 ),
	@ErrorProc VARCHAR ( 50 ),
	
	@SessionID INT,
	@AddlInfo VARCHAR ( MAX ) 
	SET @ErrorNum = error_number( ) 
	SET @ErrorMsg = 'sp_Hom_ELE_BankShaft_Set ' + error_message( ) 
	SET @ErrorProc = error_procedure( ) 
	SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
	'ELE_BankShaft',
	'POST,PUT', @SessionID, @AddlInfo 
	END catch