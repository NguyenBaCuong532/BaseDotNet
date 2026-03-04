
-- =============================================
-- Author:		namhm
-- Create date: 07/07/2025
-- Description:	Kiểm tra có phải là chủ hộ không theo sđt
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_noble_owner_phone] 
	@userId nvarchar(50) = null,
	@acceptLanguage	nvarchar(50) = 'vi-VN',
	@phone varchar(50) = NULL
AS
	begin try
    -- Kiểm tra có chủ hộ trong bảng MAS_Apartments không
    IF EXISTS (
        SELECT 1
        FROM MAS_Apartments a
        JOIN UserInfo m ON a.UserLogin = m.LoginName
        JOIN MAS_Customers c ON m.CustId = c.CustId
        WHERE c.Phone = @Phone
    )
    BEGIN
        -- Result Set 1: Thông tin chủ hộ
        SELECT TOP 1
            1 AS isOwner,
            c.FullName,
            c.Phone,
            c.Email
        FROM MAS_Apartments a
        LEFT JOIN UserInfo m ON a.UserLogin = m.LoginName
        JOIN MAS_Customers c ON m.CustId = c.CustId
        WHERE c.Phone = @Phone;

        -- Result Set 2: Danh sách căn hộ
        SELECT
            a.projectCd,
            a.RoomCode
        FROM MAS_Apartments a
        LEFT JOIN UserInfo m ON a.UserLogin = m.LoginName
        JOIN MAS_Customers c ON m.CustId = c.CustId
        WHERE c.Phone = @Phone;
    END
    ELSE
    BEGIN
        -- Result Set 1: Thông tin chủ hộ lấy từ bảng thành viên (MAS_Apartment_Member)
        SELECT TOP 1
            1 AS isOwner,
            c.FullName,
            c.Phone,
            c.Email
        FROM MAS_Apartment_Member am
        JOIN MAS_Customers c ON am.CustId = c.CustId
        WHERE am.RelationId = 0
          AND c.Phone = @Phone;

        -- Result Set 2: Danh sách căn hộ từ bảng thành viên
        SELECT
            a.projectCd,
            a.RoomCode
        FROM MAS_Apartment_Member am
        JOIN MAS_Apartments a ON am.ApartmentId = a.ApartmentId
        JOIN MAS_Customers c ON am.CustId = c.CustId
        WHERE am.RelationId = 0
          AND c.Phone = @Phone;
    END

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Check_IsApartment_Owner_ByPhone' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Check_IsApartment_Owner_ByPhone', 'GET', @SessionID, @AddlInfo
	end catch