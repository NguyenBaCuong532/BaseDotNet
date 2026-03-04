
-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin MAS_Elevator_Card
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_card_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id uniqueidentifier
	,@CardId int
	,@CardRole int
	,@CardType int
	,@ProjectCd nvarchar(30)
	,@buildingCd  nvarchar(50)
	,@areaCd  nvarchar(50) = null
	,@FloorNumber int
	,@Note nvarchar(50)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin
	begin try
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
	if exists (select Id from [dbo].[MAS_Elevator_Card] where OId = @Id)
		begin
			--if exists(select 1 from [MAS_Elevator_Card] where ProjectCd = @ProjectCd and [areaCd] = @areaCd and Oid <> @Id)
			--begin
			--	set @valid = 0
			--	set @messages = N'Đã tồn tại không thể sửa trùng'
			--	goto FINAL
			--end

			update	   [dbo].[MAS_Elevator_Card]
		    set		   [CardId] = @CardId
					  ,[CardRole] =@CardRole
					  ,[CardType] = @CardType
					  ,[ProjectCd] =@ProjectCd
					  ,[BuildCd] =@buildingCd 
					  ,[areaCd] = @areaCd
					  ,[FloorNumber] = @FloorNumber
					  ,[Note] = @Note
					  ,[created_at] = getdate()
			 where Oid = @Id
		end
	else
		begin
			set @Id = newid()
			insert into [dbo].[MAS_Elevator_Card]
					   ([CardId]
					   ,[CardRole]
					   ,[CardType]
					   ,[ProjectCd]
					   ,BuildCd
					   ,[areaCd]
					   ,[FloorNumber]
					   ,[Note]
					   ,created_at
					   ,Oid
					   )
			values	   (@CardId
					   ,@CardRole
					   ,@CardType
					   ,@ProjectCd
					   ,@buildingCd 
					   ,@areaCd
					   ,@FloorNumber
					   ,@Note
					   ,getdate()
					   ,@id
						)
			
		end

		set @valid = 1
		set @messages = N'Thành công!'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_card_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Card', 'POST,PUT', @SessionID, @AddlInfo
	end catch
FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end