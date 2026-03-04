

CREATE PROCEDURE [dbo].[sp_res_apartment_room_list3]
    @UserId UNIQUEIDENTIFIER = NULL,
    @projectCd NVARCHAR(50),
	@oids NVARCHAR(max),
    @filter NVARCHAR(50),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    drop table if exists #rooms

	-- Hỗ trợ cả ApartmentId (số) và oid (GUID) trong @oids
	SELECT b.RoomCode AS name,
           cast(b.ApartmentId as varchar(50)) AS value,
           b.oid AS apartOid
	into #rooms
    FROM MAS_Apartments b
    WHERE ApartmentId IN (SELECT CAST(Value AS INT) FROM dbo.fn_SplitString(@oids,',') WHERE ISNUMERIC(RTRIM(Value))=1 AND LEN(RTRIM(Value))<15)
       OR b.oid IN (SELECT TRY_CAST(Value AS UNIQUEIDENTIFIER) FROM dbo.fn_SplitString(@oids,',') WHERE TRY_CAST(RTRIM(Value) AS UNIQUEIDENTIFIER) IS NOT NULL)

    --1 
	-- #rooms có cột apartOid: cần insert cùng số cột
	insert into #rooms (name, value, apartOid)
    SELECT b.RoomCode AS name,
           cast(b.ApartmentId as varchar(50)) AS value,
           b.oid AS apartOid
    FROM MAS_Apartments b
    WHERE projectCd = @projectCd 
          AND (@filter = '' OR @filter IS NULL OR RoomCode LIKE @filter + '%')
    ORDER BY RoomCode;

	select *
	from #rooms

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_room_list3 ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Rooms',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;