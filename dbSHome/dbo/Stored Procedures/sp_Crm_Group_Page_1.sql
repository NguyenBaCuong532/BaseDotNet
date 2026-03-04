



CREATE procedure [dbo].[sp_Crm_Group_Page]
	@UserID				nvarchar(450),
	@id					int	,
	@Offset				int				= 0,
	@Filter nvarchar(50),
	@gridWidth			int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
	
as 

begin try
	declare @t table(id int,parentId int,name nvarchar(255), [level] int)
	declare @temp table(id int,parentId int,name nvarchar(255), [level] int, rn nvarchar(200))

		set @id = isnull(@id,1)
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		if @id = 0 set @id = 1

	insert into @t select GroupId, ParentId, GroupName,GroupLevel as [level] from CRM_Group where ParentId = @id; 

	
	WITH tree (id, parentid, [level], name, rn) as 
	(
	   SELECT id, parentid, [level], name,
		   convert(varchar(max),right(row_number() over (order by id),10)) rn
	   FROM @t
	   --WHERE parentid = 0

	   UNION ALL

	   SELECT c2.GroupId as id, c2.parentid, tree.[level] + 1, c2.GroupName as name,
		   rn + '/' + convert(varchar(max),right(row_number() over (order by tree.id),10))
	   FROM CRM_Group c2 
		 INNER JOIN tree ON tree.id = c2.parentid
	)
	insert into @temp
	SELECT t.id,t.parentid,t.name,t.level,t.rn
	FROM tree t
	--join CRM_Group cg 
	--on t.id = cg.GroupId
	order by RN
 
 if exists(SELECT b.CategoryCd FROM MAS_Category_User b 
		inner join MAS_Category_CustGroup c on b.CategoryCd = c.CategoryCd WHERE UserId = @UserID)
 begin
	select	@Total					= count(cg.GroupId)
			--FROM @temp a  
			--WHERE exists(SELECT b.CategoryCd FROM MAS_Category_User b 
			--	inner join MAS_Category_CustGroup c on b.CategoryCd = c.CategoryCd WHERE UserId = @UserID and c.GroupId = a.id)
			FROM @temp t
				join CRM_Group cg 
				on t.id = cg.GroupId
				WHERE exists(SELECT cc.GroupId
					FROM MAS_Category_CustGroup cc  
					WHere cc.GroupId = t.ID and
						  (exists(select userid from [MAS_Category_User] a
							where a.UserId = @UserId and a.CategoryCd = cc.CategoryCd)
						 or exists(select userid from [MAS_Category_User] a 
							inner join MAS_Category b on a.CategoryCd = b.ParentCd 
							where a.UserId = @UserId and b.CategoryCd = cc.CategoryCd)
						  )
						)
		set	@TotalFiltered = @Total 

		if @Offset = 0
		begin
			select * from dbo.fn_config_list_gets('view_Crm_Group_Page', @gridWidth - 100) 
			order by [ordinal]
		end
	

	SELECT cg.[groupId] 
		  ,cg.[hiddenName] 
		  ,cg.[groupName] 
		  ,cg.[parentId]
		  ,cg.[isActive]
		  ,cg.[groupMail]
		  ,cg.[groupLevel]
		  ,cg.[createdBy]
		  ,cg.[createdTime]
		  ,cg.[updatedBy]
		  ,cg.[updatedTime]
	FROM @temp t
		join CRM_Group cg 
		on t.id = cg.GroupId
		WHERE exists(SELECT cc.GroupId
			FROM MAS_Category_CustGroup cc  
			WHere cc.GroupId = t.ID and
				  (exists(select userid from [MAS_Category_User] a
					where a.UserId = @UserId and a.CategoryCd = cc.CategoryCd)
				 or exists(select userid from [MAS_Category_User] a 
					inner join MAS_Category b on a.CategoryCd = b.ParentCd 
					where a.UserId = @UserId and b.CategoryCd = cc.CategoryCd)
				  )
				)
	order by RN
		offset @Offset rows	
		fetch next @PageSize rows only
end
else
begin
	select	@Total					= count(a.id)
			FROM @temp a  
		set	@TotalFiltered = @Total 

		if @Offset = 0
		begin
			select * from dbo.fn_config_list_gets ('view_Crm_Group_Page', @gridWidth - 100) 
			order by [ordinal]
		end

	SELECT cg.[groupId] 
		  ,cg.[hiddenName] 
		  ,cg.[groupName] 
		  ,cg.[parentId]
		  ,cg.[isActive]
		  ,cg.[groupMail]
		  ,cg.[groupLevel]
		  ,cg.[createdBy]
		  ,cg.[createdTime]
		  ,cg.[updatedBy]
		  ,cg.[updatedTime]
	FROM @temp t
		join CRM_Group cg 
		on t.id = cg.GroupId
	order by RN
	offset @Offset rows	
	fetch next @PageSize rows only
end

end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Get_Group_Tree] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@GroupId ' --+ @id

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Group', 'GET', @SessionID, @AddlInfo
	end catch