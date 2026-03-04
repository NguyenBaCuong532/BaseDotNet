

CREATE procedure [dbo].[sp_res_virtual_acc_set]
	@userId nvarchar(50) = null,
	@acceptLanguage	nvarchar(50) = 'vi-VN',
	@entryId uniqueidentifier = null,
    @amount DECIMAL(18,0) = NULL,
    @virtualAccount nvarchar(50) = null,
    @metadata NVARCHAR(250) = NULL,
    @source NVARCHAR(250) = NULL
as
	begin try
        declare @valid bit = 1
        declare @messages nvarchar(100) = N'Lưu tài khoản ảo thành công' 

		INSERT INTO [dbo].[transaction_payment_draft]
		(
			[Oid],
			[sourceOid],
			[amount],
			[brct],
			[created],
			[created_by],
			[virtualAcc],
			[displayName],
			[actualAccount],
			[type],
			[customerName],
            [metadata],
            [source]
		)
		SELECT
			NEWID() AS Oid,
			@entryId AS sourceOid, -- bạn có thể đổi nếu muốn dùng cột khác
			ISNULL(@amount,ISNULL(a.TotalAmt, 0)) AS amount,
			1 AS brct,
			GETDATE() AS created,
			@userId AS created_by,
			@virtualAccount,
			bk.Bank_Acc_Name AS displayName,
			bk.Bank_Acc_Num AS actualAccount,
			'Bill' AS [type], -- hoặc thay bằng mã bạn muốn
			c.FullName AS customerName,
            @metadata,
            @source
		FROM [dbo].MAS_Service_ReceiveEntry a
			LEFT JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			LEFT JOIN MAS_Buildings bui ON b.buildingOid = bui.oid
			LEFT JOIN dbo.MAS_Projects pro ON pro.projectCd = b.projectCd AND pro.sub_projectCd = b.sub_projectCd
			LEFT JOIN MAS_Service_Bank bk ON b.projectCd = bk.ProjectCd
			LEFT JOIN PAR_ServicePrice p ON b.projectCd = p.ProjectCd AND ServiceTypeId = 1
			LEFT JOIN UserInfo u ON b.UserLogin = u.loginName
			LEFT JOIN MAS_Customers c ON u.CustId = c.CustId
		WHERE a.entryId = @entryId;


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_booking_virtual_acc_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_app_booking_virtual_acc_set', 'Update', @SessionID, @AddlInfo
	end catch
    FINAL:
	    select @valid as valid
		       ,@messages as [messages]