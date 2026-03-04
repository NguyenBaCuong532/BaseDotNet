



CREATE procedure [dbo].[sp_Crm_Group_List]
	@UserID nvarchar(450),
	@id int	,
	@Total				int out,
	@TotalFiltered		int out

	
as 

begin try
	declare @t table(id int,parentId int,name nvarchar(255), [level] int)
	declare @temp table(id int,parentId int,name nvarchar(255), [level] int, rn nvarchar(200))

	if @id is null or @id = 0 set @id = 1
 
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
 
 --if exists(SELECT b.CategoryCd FROM MAS_Category_User b 
	--	inner join MAS_Category_CustGroup c on b.CategoryCd = c.CategoryCd WHERE UserId = @UserID)
 --begin
	--select	@Total					= count(a.id)
	--		FROM @temp a  
	--		WHERE exists(SELECT b.CategoryCd FROM MAS_Category_User b 
	--			inner join MAS_Category_CustGroup c on b.CategoryCd = c.CategoryCd WHERE UserId = @UserID and c.GroupId = a.id)
	--	set	@TotalFiltered = @Total 

	SELECT cg.*
	,value = GroupId 
	,name = HiddenName
	FROM @temp t
		join CRM_Group cg 
		on t.id = cg.GroupId
		--WHERE exists(SELECT cc.GroupId
		--	FROM MAS_Category_CustGroup cc  
		--	WHere cc.GroupId = t.ID and
		--		  (exists(select userid from [MAS_Category_User] a
		--			where a.UserId = @UserId and a.CategoryCd = cc.CategoryCd)
		--		 or exists(select userid from [MAS_Category_User] a 
		--			inner join MAS_Category b on a.CategoryCd = b.ParentCd 
		--			where a.UserId = @UserId and b.CategoryCd = cc.CategoryCd)
		--		  )
		--		)
	order by RN
--end
--else
--begin
--	select	@Total					= count(a.id)
--			FROM @temp a  
--		set	@TotalFiltered = @Total 

--	SELECT cg.*
--	FROM @temp t
--		join CRM_Group cg 
--		on t.id = cg.GroupId
--	order by RN

--end

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

		set @AddlInfo					= '@GroupId ' + @id

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Group', 'GET', @SessionID, @AddlInfo
	end catch