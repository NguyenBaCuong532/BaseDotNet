



create procedure [dbo].[utl_errorlog_set]

	@ErrorCd						int, 
	@ErrorMsg						varchar(200), 
	@ProcName						varchar(50), 

	@TableName						varchar(50), 
	@ActionType						varchar(3),
	@SessionID						bigint,

	@AddlInfo						varchar(max)

as

	insert into utl_error_log
			(errorNum,
			errorMsg,
			procName,

			tableName,
			actionType,
			sessionID,

			addlInfo,
			createdDate)

	select	ErrorNum				= @ErrorCd,
			ErrorMsg				= @ErrorMsg,
			ProcName				= @ProcName,

			TableName				= @TableName,
			ActionType				= @ActionType,
			SessionID				= @SessionID,

			AddlInfo				= @AddlInfo,
			CreatedDate				= getdate()