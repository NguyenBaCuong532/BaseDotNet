





-- exec sp_Hom_Apartment_Project_Get null,'','01'

CREATE procedure [dbo].[sp_Hom_Apartment_Project_Get]
	@UserId			nvarchar(450),
	@clientId		nvarchar(50),
	@projectCd		nvarchar(2)
as
	begin try
		
	
		--1 
		SELECT distinct [projectCd]
			  ,[projectName]
			  ,[investorName]
			  ,[address]
			  ,[timeWorking]
			  ,[bank_acc_no]
			  ,[bank_acc_name]
			  ,[bank_branch]
			  ,[bank_name]
			  ,[mailSender]
		  FROM [dbSHome].[dbo].[MAS_Projects] p
	  WHERE p.projectCd = @projectCd 
	

		SELECT '1' as group_cd
		      ,'Thông tin' as group_name 


		SELECT distinct a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,'1' as group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'projectCd' then b.projectCd
					when 'projectName' then b.projectName
					when 'address' then b.address
					when 'timeWorking' then b.timeWorking
					when 'bank_acc_no' then b.bank_acc_no
					 when 'bank_acc_name' then b.bank_acc_name
					 when 'bank_branch' then b.bank_branch
					 when 'bank_name' then b.bank_name
					 when 'mailSender' then b.mailSender
					 when 'investorName' then b.investorName
					end
					) 
				--when 'decimal' then cast(case field_name 
				--	 when 'freeAmt' then f.Amount
				--	 end as nvarchar(100)) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'dayOfNotice1' then format(b.dayOfNotice1,'dd/MM/yyyy HH:mm:ss')
					when 'dayOfNotice2'  then format(b.dayOfNotice2,'dd/MM/yyyy HH:mm:ss')
					when 'dayOfNotice3'  then format(b.dayOfNotice3,'dd/MM/yyyy HH:mm:ss')
					when 'dayStopService'  then format(b.dayStopService,'dd/MM/yyyy HH:mm:ss')
					end)
					 
				else convert(nvarchar(50),case field_name 
					when 'dayOfIndexElectric' then b.dayOfIndexElectric
					when 'dayOfIndexWater' then b.dayOfIndexWater
					when 'caculateVehicleType' then b.caculateVehicleType
					when 'type_discount_elec' then b.type_discount_elec
					when 'type_discount_water' then b.type_discount_water
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject
				,isSpecial
				,isRequire
				,isDisable
				,isVisiable
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
			FROM sys_config_form a
			,[dbo].[MAS_Projects] b
			WHERE  b.projectCd = @projectCd
				and a.table_name = 'MAS_Projects' and (a.isVisiable = 1 or a.isRequire =1)
			order by ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Project_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'HomProject', 'GET', @SessionID, @AddlInfo
	end catch