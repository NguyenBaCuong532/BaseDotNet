
create FUNCTION [dbo].[fn_FileSize](@backupsize decimal(20,2))
RETURNS varchar(20)
AS
Begin
DECLARE @size varchar(20)
IF (@backupsize<1024)
Begin
Select @Size = cast(@backupsize as varchar(10)) +' Byte'
End
IF (@backupsize>=1024 and @backupsize<=1048576)
Begin
Select @Size = cast(cast(@backupsize/1024 as decimal(20,2)) as varchar(10)) +' KB'
End
IF (@backupsize>=1048576 and @backupsize<=1073741824)
Begin
Select @Size = cast(cast(@backupsize/1048576 as decimal(20,2)) as varchar(10)) +' MB'
End
IF (@backupsize>=1073741824 and @backupsize<=1099511627776)
Begin
Select @Size =cast(cast(@backupsize/1073741824 as decimal(20,2)) as varchar(10)) +' GB'
End
IF (@backupsize>=1099511627776)
Begin
Select @Size =cast(cast(@backupsize/1099511627776 as decimal(20,2)) as varchar(10)) +' TB'
End

Return @size

End