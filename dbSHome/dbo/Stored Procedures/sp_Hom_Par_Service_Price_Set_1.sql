
CREATE procedure [dbo].[sp_Hom_Par_Service_Price_Set]
	@UserID				nvarchar(450),
	@ProjectCd			nvarchar(30),
	@servicePriceId		int,
	@typeId				int = null,
	@serviceTypeId		int = null,
	@serviceTypeName	nvarchar(250),
	@serviceId			int = null,
	@serviceName		nvarchar(250),
	@price				int = null,
	@price2				int = null,
	@calculateType		int = null,
	@isFree				int = null,
	@unit				nvarchar(50),
	@note				nvarchar(250), 
	@isUsed				int

as
	begin try		
        declare @valid bit = 1
		declare @messages nvarchar(200) = 'Cập nhật thành công'
		if exists (select ServicePriceId from PAR_ServicePrice where ServicePriceId = @servicePriceId)
			begin
				UPDATE t1
				 SET   [ProjectCd] = @ProjectCd
					  ,TypeId = @typeId
					  ,ServiceTypeId = @serviceTypeId
					  ,ServiceTypeName = @serviceTypeName
					  ,ServiceId = @serviceId
					  ,ServiceName = @serviceName
					  ,Price = @price
					  ,Price2 = @price2
					  ,CalculateType = @calculateType
					  ,isFree = @isFree
					  ,Unit = @unit
					  ,Note = @note
					  ,IsUsed = @isUsed
				FROM [PAR_ServicePrice] t1
				WHERE t1.ServicePriceId = @servicePriceId
			end
		else 
			begin
				INSERT INTO [dbo].[PAR_ServicePrice]
				   ([ProjectCd]
					  ,[TypeId]
					  ,[ServiceTypeId]
					  ,[ServiceTypeName]
					  ,[ServiceId]
					  ,[ServiceName]
					  ,[Price]
					  ,[Unit]
					  ,[Note]
					  ,[Price2]
					  ,[CalculateType]
					  ,[IsFree], [IsUsed])
				VALUES
				   (@ProjectCd
					  ,@typeId
					  ,@serviceTypeId
					  ,@serviceTypeName
					  ,@serviceId
					  ,@serviceName
					  ,@price
					  ,@unit
					  ,@note
					  ,@price2
					  ,@calculateType
					  ,@IsFree, @isUsed
								   )
			end
			

	end try
	begin catch
		declare	@ErrorNum				int = error_number(),
					@ErrorMsg				varchar(200) = 'sp_Hom_Par_Service_Price_Set ' + error_message(),
					@ErrorProc				varchar(50) = error_procedure(),

					@SessionID				int,
					@AddlInfo				varchar(max) = ' - @userId ' + @userId
        set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Par_Service_Price_Set', 'Update', @SessionID, @AddlInfo
	end catch
    SELECT @valid as valid
		  	,@messages as [messages]