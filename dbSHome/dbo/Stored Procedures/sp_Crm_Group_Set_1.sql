








CREATE procedure [dbo].[sp_Crm_Group_Set]
	@UserId	nvarchar(450), 
	@groupId int,
	@GroupName nvarchar(255), 
	@GroupMail nvarchar(255), 
	@ParentId	int,
	@Categories nvarchar(max) = null,
	@isActive  bit

as
	declare @parentLevel int;
	declare @parentGroupName nvarchar(255);
	declare @prefix varchar(10);
	declare @tbCats TABLE 
		(
			CategoryCd [nvarchar](50) null
		)
	--declare @groupId int

	begin try 
	IF NOT EXISTS(SELECT * FROM CRM_Group WHERE GroupId = @groupId)
		begin
			if @ParentId = 0 
				set @ParentId = 1

			--set @ParentId = ISNULL(@ParentId,1); 

			SELECT @parentLevel = t.GroupLevel,
			@parentGroupName = t.GroupName 
			FROM CRM_Group t 
			WHERE t.GroupId = @ParentId 

			set  @prefix = substring(@parentGroupName, 0, @parentLevel*2 );
			if(@parentLevel = 1)
				set @prefix = '|--';
			else
				set @prefix = @prefix + '--';
	 
				 INSERT INTO [dbo].[CRM_Group]
				   ([GroupName]
				   ,[HiddenName]
				   ,[ParentId]
				   ,[IsActive] 
				   ,[GroupLevel]
				   ,[GroupMail]
				   ,[CreatedBy]
				   ,[CreatedTime]
				   ,[UpdatedBy]
				   ,[UpdatedTime])
			 VALUES
				   (@prefix + @GroupName
				   ,@GroupName
				   ,@ParentId
				   ,@isActive 
				   ,@parentLevel + 1
				   ,@GroupMail
				   ,@UserId
				   ,SYSDATETIME()
				   ,@UserId
				   ,SYSDATETIME()
				   )
				set @groupId = @@IDENTITY

				if @Categories is null or @Categories = ''
					INSERT INTO @tbCats SELECT top 1 CategoryCd FROM MAS_Category_User WHERE UserId = @UserID
				else
					INSERT INTO @tbCats SELECT [part] FROM [dbo].[SplitString](@Categories,',')

				--DELETE a FROM [dbo].MAS_Category_CustGroup a
				--WHERE GroupId = @groupId
				--	and not exists(select CategoryCd From @tbCats where CategoryCd = a.CategoryCd)

				INSERT INTO [dbo].MAS_Category_CustGroup
						(CategoryCd
						,GroupId
						,[CreationTime])
				SELECT a.CategoryCd
						,@groupId
						,getdate()
				FROM @tbCats a 
					inner join MAS_Category c on a.CategoryCd = c.CategoryCd 
				WHERE not exists(select CategoryCd FROM MAS_Category_CustGroup r 
					where r.CategoryCd = a.CategoryCd and r.GroupId = @groupId)
			end
		ELSE
			begin
				UPDATE [dbo].[CRM_Group]
				SET --[HiddenName] = @HiddenName, nvarchar(255),>,
					[GroupName] = @GroupName
					,[ParentId] = @ParentId
					,[IsActive] = @isActive
					,[GroupMail] = @GroupMail
					--,[GroupLevel] = @GroupLevel, int,>
					,[CreatedBy] = @UserId
					,[CreatedTime] = GETDATE()
					,[UpdatedBy] = @UserId
					,[UpdatedTime] =  GETDATE()
				WHERE GroupId = @groupId
			end
			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Group_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@GroupName ' + cast(@GroupName as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'Insert', @SessionID, @AddlInfo
	end catch