-- =============================================
-- Author:		Namhm
-- Create date: 15/05/2025
-- Description:	change start and end date for Car ticket
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_apartment_vehicle_set]
    @UserId	nvarchar(450) = null,
    @CustId   nvarchar(255) = null,
    @CardVehicleId int = null,
    @startDate nvarchar(20) = null,
    @endDate nvarchar(20) = null,
    @VehicleNum int = NULL,
    @CardCd NVARCHAR(50) = NULL
AS
BEGIN TRY
    declare @valid bit = 1
    declare @messages nvarchar(100)
    
    IF(@CardCd IS NULL OR TRIM(@CardCd) = '')
    BEGIN
        SET @valid = 0;
        SET @messages = N'Vui lòng nhập thông tin "Mã thẻ"';
        GOTO FINAL;
    END
    
    DECLARE @CardId INT = (SELECT TOP 1 Code FROM MAS_CardBase WHERE Code = @CardCd);
    IF(@CardId IS NULL)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy thông tin "Mã thẻ"';
        GOTO FINAL;
    END

    if not exists(Select CardVehicleId  FROM MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId)
    BEGIN
        SET @valid = 0
        SET @messages = N'Không tìm thấy thẻ'
        GOTO FINAL
    END
    ELSE
    BEGIN
        IF @startDate > @endDate
        BEGIN
            SET @valid = 0
            SET @messages = N'Ngày kết thúc trước ngày bắt đầu'
            GOTO FINAL
        END
        ELSE IF @startDate = @endDate
        BEGIN
            SET @valid = 0
            SET @messages = N'Ngày bắt đầu và ngày kết thúc bằng nhau'
            GOTO FINAL
        END
        ELSE
        BEGIN
            UPDATE MAS_CardVehicle
            SET
                StartTime = convert(datetime, @startDate, 103),
                EndTime = convert(datetime, @endDate, 103),
                VehicleNum = @VehicleNum,
                CardId = @CardId
            WHERE CardVehicleId = @CardVehicleId
        END
    END
      FINAL:
      select @valid as valid
      ,@messages as [messages]
		
END TRY
begin catch
  declare	@ErrorNum				int,
      @ErrorMsg				varchar(200),
      @ErrorProc				varchar(50),

      @SessionID				int,
      @AddlInfo				varchar(max)

  set @ErrorNum					= error_number()
  set @ErrorMsg					= 'sp_res_apartment_vehicle_set' + error_message()
  set @ErrorProc					= error_procedure()

  set @AddlInfo					= ''

  exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment_vehicle', 'Set', @SessionID, @AddlInfo
end catch