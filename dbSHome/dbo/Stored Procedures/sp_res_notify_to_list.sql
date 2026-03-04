-- =============================================
-- Author:		duongpx
-- Create date: 8/17/2024 11:17:16 AM
-- Description:	danh sách gửi thông báo
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_notify_to_list]
	 @userId UNIQUEIDENTIFIER = null
	,@acceptLanguage nvarchar(50) = N'vi-VN'
	,@source_ref	uniqueidentifier = null
	,@n_id uniqueidentifier	= null
	,@to_type nvarchar(10) = '0' --0 emp, 1 recuit
	,@to_level int = NULL
	,@to_groups nvarchar(max) = NULL
    ,@project_code NVARCHAR(50) = NULL
as
	begin try
		declare @actions nvarchar(200)
	--1
		select
			   @source_ref = iif(a.to_type = 0,source_ref,null)
			  ,@actions	= isnull(a.actionlist,'')
			  ,@project_code = iif(isnull(a.to_type,1) = 1,isnull(a.external_sub,''),'')
			  ,@to_type = isnull(a.to_type,'1')
		from NotifyInbox a
		where n_id = @n_id

		select
        a.n_id-- as id
			  ,a.access_role
			  ,access_name	= r.objName
		from
        NotifyInbox a
        left join dbo.fn_config_data_gets_lang('notify_access_role', @acceptLanguage) r on isnull(a.access_role,1) = r.objValue2
		where n_id = @n_id

		
		select
        to_level = l.objCode
			  ,to_name = l.objName
			  ,columnType	= l.objGroup
			  ,columnObject = replace(objValue1,'projectCd=','projectCd=' + isnull(@project_code,''))
		from dbo.fn_config_data_gets_lang('notify_to_level' + cast(isnull(@to_type,'') as nvarchar(50)), @acceptLanguage) l
		order by l.objCode

		SELECT b.id 
			  ,b.to_level 
			  ,b.to_groups 
			  ,to_type = @to_type
			  ,b.to_row 
			  ,to_name = l.objName + '(' +cast(isnull([to_count],0) as varchar(10)) + ')'
			  ,columnType	= l.objGroup
			  ,columnObject = replace(replace(objValue1,'projectCd=','projectCd=' + isnull(@project_code,'')),'Oids=','Oids=' + b.to_groups)
		FROM NotifyTo b 
		LEFT JOIN dbo.fn_config_data_gets_lang('notify_to_level' + isnull(@to_type,''), @acceptLanguage) l ON l.objCode = cast(b.to_level as varchar(10))
		WHERE b.sourceId = @n_id
		and to_groups is not null and to_groups <> ''
		order by b.createDt

		--access
		select
        value = objCode
			  ,name = objName
		from dbo.fn_config_data_gets_lang('notify_access_role', @acceptLanguage)
		order by intOrder desc
    
		--action
		select
        value = objCode
			  ,name = objName
		from dbo.fn_config_data_gets_lang('notify_template', @acceptLanguage)
		where objCode in (select part from dbo.SplitString(@actions,','))
		order by intOrder 

	end try
	begin catch
		declare	@ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)
		set @ErrorNum = error_number()
		set @ErrorMsg = 'sp_res_notify_to_list ' + error_message()
		set @ErrorProc = error_procedure()
		set @AddlInfo = ' '
		exec utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'SchemeField', 'GET', @SessionID, @AddlInfo
	end catch