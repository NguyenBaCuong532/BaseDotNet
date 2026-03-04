




CREATE PROCEDURE [dbo].[sp_Hom_Mas_Customer_Set]
    @CustId          nvarchar(450) =NULL,
    @avatar_url      nvarchar(450)=NULL,
    @birthday        nvarchar(450)=NULL,
    @email1          nvarchar(250)=NULL,
    @full_name       nvarchar(250)=NULL,
    @phone1          nvarchar(50)=NULL,
    @sex             bit,
    @userId          nvarchar(50)=NULL,
    @cif_no          nvarchar(250)=NULL,
    @idcard_no       nvarchar(20)=NULL,
    @idcard_issue_dt nvarchar(250)=NULL,
    @idcard_issue_plc nvarchar(250)=NULL,
    @res_add         nvarchar(250)=NULL,
    @res_cntry       nvarchar(250)=NULL,
    @empId           UNIQUEIDENTIFIER = NULL,
    @code            nvarchar(50) = NULL
AS
BEGIN TRY
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM MAS_Customers WHERE CustId = @CustId)
        BEGIN
            INSERT INTO dbSHome.[dbo].[MAS_Customers]
                ([CustId]
                ,[Cif_No]
                ,[FullName]
                ,[FirstName]
                ,[LastName]
                ,[IsSex]
              --  ,[Birthday]
                ,[Phone]
                ,[Phone2]
                ,[Email]
                ,[Email2]
                ,[Pass_No]
                ,[Pass_Dt]
                ,[Pass_Plc]
                ,[Address]
                ,[IsForeign]
                ,[CountryCd]
                )
            VALUES (
                @CustId
                ,@cif_no
                ,@full_name
                ,NULL
                ,NULL
                ,@sex
              --  ,CONVERT(datetime,@birthday,103)
                ,@phone1
                ,NULL
                ,@email1
                ,NULL
                ,@idcard_no
                ,CONVERT(datetime,@idcard_issue_dt,103)
                ,@idcard_issue_plc
                ,@res_add
                ,NULL
                ,@res_cntry
            );

            -- Thêm mới vào bảng mas_employee
            IF @empId IS NOT NULL
               AND NOT EXISTS (SELECT 1 FROM dbSHome.[dbo].[mas_employee] WHERE empId = @empId)
            BEGIN
                INSERT INTO dbSHome.[dbo].[mas_employee]
                    ([empId]
                    ,[code]
                    ,[custId]
                    ,[userId]
                    ,[fullName]
                    ,[email]
                    ,[phone]
                    ,[idcard_no]
                    ,[departmentName]
                    ,[orgName]
                    ,[companyName]
                    ,[positionTypeName]
                    ,[created_at]
                    ,[updated_at]
                    ,[emp_st]
                    ,[oid]
                    )
                VALUES
                    (@empId
                    ,@code
                    ,@CustId
                    ,@userId
                    ,@full_name
                    ,@email1
                    ,@phone1
                    ,@idcard_no
                    ,NULL          -- departmentName
                    ,NULL          -- orgName
                    ,NULL          -- companyName
                    ,NULL          -- positionTypeName
                    ,GETDATE()     -- created_at
                    ,GETDATE()     -- updated_at
                    ,1             -- emp_st (đang hoạt động)
                    ,NEWID()       -- oid
                    );
            END
        END
    END

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Mas_Customer_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @CustId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Mas_Customer_Set', 'Insert', @SessionID, @AddlInfo
	end catch