

-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thông tin cardbase
-- =============================================
CREATE procedure [dbo].[sp_Hom_Card_Base_Set]
	@UserId nvarchar(450)
	,@Card_Num nvarchar(20)
	,@Code nvarchar(20)
as
	begin try
	if exists (select Card_Num from [MAS_CardBase] where Card_Num = @Card_Num)
		begin
			UPDATE [dbo].[MAS_CardBase]
			   SET [Card_Num] = @Card_Num
				  ,[Code] = @Code
				  ,IsUsed = 1
				  ,[SysDate] = getdate()
			 WHERE Card_Num = @Card_Num
		end
	else
		begin
			INSERT INTO [dbo].[MAS_CardBase]
				   ([Card_Num]
				   ,[Code]
				   ,IsUsed
				   ,[SysDate])
			 VALUES
				   (@Card_Num
				   ,@Code
				   ,1
				   ,getdate()
				   )
		end

		 --EXEC [dbo].[sp_Hou_BLD_Building_Map_ByBuilding] 
			--	   @UserId
			--	  ,@BuildingCd
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hou_MAS_CardBase_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_CardBase', 'SET', @SessionID, @AddlInfo
	end catch