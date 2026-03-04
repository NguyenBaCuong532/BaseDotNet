








CREATE procedure [dbo].[sp_Crm_Base_To_Group]
	@UserId	nvarchar(255), 
	@CustId nvarchar(max), 
	@GroupIds nvarchar(max), 
	@IsLeaveOldGroup bit 
as
declare @parentLevel int;

	begin try 
	if(@IsLeaveOldGroup = 1)
	begin
		delete from a 
		from [dbo].[CRM_Membership]  a
		 join fn_Crm_Split_String(@CustId, ',') b
		 on a.CustId = b.splitdata 
	   delete from [dbo].[CRM_Membership] where [CustId] = @CustId;
	end	

	INSERT INTO [dbo].[CRM_Membership]
           ([CustId]
           ,[GroupId]
           ,[CreatedTime]
           ,[CreatedBy]) 
	select 
           b.splitdata
		   , a.splitdata
		   ,SYSDATETIME()
           ,@UserId
           from fn_Crm_Split_String(@GroupIds, ',') a 
		   join fn_Crm_Split_String(@CustId, ',') b on 1 =1 
		   left join CRM_Membership cm on a.splitdata   = cm.GroupId and b.splitdata = cm.CustId
		    where cm.CustId is null 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Insert_Customer_To_Group] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@GroupId ' + cast(@GroupIds as nvarchar) + ' @CustId' + cast(@CustId as nvarchar) 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Group', 'Insert', @SessionID, @AddlInfo
	end catch