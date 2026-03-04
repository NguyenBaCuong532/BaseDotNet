Create Function dbo.GetNumbers(@Data nvarchar(800))
Returns nvarchar(800)
AS
Begin	
    Return Left(
             SubString(@Data, PatIndex('%[0-9.-]%', @Data), 8000), 
             PatIndex('%[^0-9.-]%', SubString(@Data, PatIndex('%[0-9.-]%', @Data), 8000) + 'X')-1)
End