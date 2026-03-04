
CREATE PROCEDURE [dbo].[sp_res_par_service_set]
	@servicePriceId int = null,
	@note NVARCHAR(250) = null
AS
BEGIN
	declare @valid bit = 1
	declare @messages nvarchar(100)

	if not exists(Select ServicePriceId  FROM PAR_ServicePrice WHERE ServicePriceId = @servicePriceId)
	 BEGIN
		SET @valid = 0
		SET @messages = N'Không tìm thấy bảng phí'
		GOTO FINAL
		END
	ELSE
	BEGIN
		UPDATE [dbo].[PAR_ServicePrice]
			SET Note = @note
		WHERE ServicePriceId = @servicePriceId
	END
		FINAL:
		select @valid as valid
		,@messages as [messages]
    RETURN
END