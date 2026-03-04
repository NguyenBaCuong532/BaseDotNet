
--select convert(datetime,'16/08/2021 10:11',103)


CREATE procedure [dbo].[sp_Hom_Apartment_Project_Set]
	@UserID			nvarchar(450),
	@projectCd		nvarchar(20),
	@projectName	nvarchar(50),
	@address		nvarchar(250),
	@timeWorking	nvarchar(50),
	@bank_acc_name	nvarchar(250),
	@bank_acc_no	nvarchar(250),
	@bank_branch	nvarchar(200),
	@bank_name		nvarchar(250),
	@investorName	nvarchar(200),
	@mailSender		nvarchar(100),
	@dayOfIndexElectric	int,
	@dayOfIndexWater	int,
	@caculateVehicleType	int,
	@dayOfNotice1	nvarchar(20),
	@dayOfNotice2	nvarchar(20),
	@dayOfNotice3	nvarchar(20),
	@dayStopService	nvarchar(20),
	@type_discount_elec int,
	@type_discount_water int
as
	begin try		
		
		UPDATE t1
		 SET   [investorName] = @investorName
			  ,[address] = @address
			  ,[timeWorking] = @timeWorking
			  ,[bank_acc_no] = @bank_acc_no
			  ,[bank_acc_name] = @bank_acc_name
			  ,[bank_branch] = @bank_branch
			  ,[bank_name] = @bank_name
			  ,[mailSender] = @mailSender
			  ,dayOfIndexElectric = @dayOfIndexElectric
			  ,dayOfIndexWater	= @dayOfIndexWater
			  ,caculateVehicleType = @caculateVehicleType
			  ,dayOfNotice1 = convert(datetime,@dayOfNotice1,103)
			  ,dayOfNotice2 = convert(datetime,@dayOfNotice2,103)
			  ,dayOfNotice3 = convert(datetime,@dayOfNotice3,103)
			  ,dayStopService = convert(datetime,@dayStopService,103)
			  ,type_discount_elec = @type_discount_elec
			  ,type_discount_water = @type_discount_water
		FROM [MAS_Projects] t1
		WHERE t1.projectCd = @projectCd


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Project_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch