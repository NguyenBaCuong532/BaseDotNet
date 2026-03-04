




CREATE procedure [dbo].[sp_Crm_Opportunity_Del]
	@userId nvarchar(450),
	@Id bigint	
	
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100)
		if not exists(select id from CRM_Opportunity where id = @id and create_by = @userId)
		begin
			set @valid = 0
			set @messages = N'Ban chưa được phân quyền xóa'
		end 
		else
		begin
			delete from [CRM_Opportunity_Attach] 
			where opp_Id = @Id

			delete from CRM_Opportunity_Process
			where opp_Id = @Id

			delete from [dbo].Crm_Opportunity 
			where id = @id 
			and create_by = @userId
		end

		 select @valid as valid
			  ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity', 'DEL', @SessionID, @AddlInfo
	end catch