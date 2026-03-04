

--create procedure sp_bzz_config_data_set update to table bzz_config_data with key and value
CREATE procedure [dbo].[sp_config_data_set](
    @key nvarchar(100),
    @value varchar(200)
)
as
begin try
    update sys_config_data set value1 = @value where key_2 = @key
end try
begin catch
    declare @ErrorNum int,
        @ErrorMsg varchar(200),
        @ErrorProc varchar(50),

        @SessionID int,
        @AddlInfo varchar(max)

    set @ErrorNum = error_number()
    set @ErrorMsg = 'sp_config_data_set ' + error_message()
    set @ErrorProc = error_procedure()

    set @AddlInfo = ' '

    exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sys_config_data', 'SET', @SessionID, @AddlInfo
end catch