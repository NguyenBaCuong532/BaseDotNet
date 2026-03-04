

CREATE procedure [dbo].[utl_Insert_ErrorLog]

	@ErrorCd						int, 
	@ErrorMsg						varchar(200), 
	@ProcName						varchar(50), 

	@TableName						varchar(50), 
	@ActionType						varchar(3),
	@SessionID						bigint,

	@AddlInfo						varchar(max)

as

	insert into utl_Error_Log
			(ErrorNum,
			ErrorMsg,
			ProcName,

			TableName,
			ActionType,
			SessionID,

			AddlInfo,
			CreatedDate)

	select	ErrorNum				= @ErrorCd,
			ErrorMsg				= @ErrorMsg,
			ProcName				= @ProcName,

			TableName				= @TableName,
			ActionType				= @ActionType,
			SessionID				= @SessionID,

			AddlInfo				= @AddlInfo,
			CreatedDate				= getdate()