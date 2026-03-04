CREATE FUNCTION fn_apartment_format (
    @roomCode NVARCHAR(50)
    , @floorNo NVARCHAR(50)
    , @buildingName NVARCHAR(50)
    )
RETURNS NVARCHAR(250)
AS
BEGIN
    RETURN CONCAT (
            @roomCode
            , ' • '
            , @floorNo
            , ' • '
            , @buildingName
            )
END