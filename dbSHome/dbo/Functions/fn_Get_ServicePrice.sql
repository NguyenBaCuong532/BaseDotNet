
CREATE FUNCTION [dbo].[fn_Get_ServicePrice]
(
	@ApartmentId bigint
)
RETURNS float
BEGIN
	-- Declare the return variable here
	DECLARE @CardCd nvarchar(50)
	declare @WaterwayPrice float
	--if @CalculateType = 1
		select @WaterwayPrice = isnull(a.WaterwayArea,0)*isnull(b.Price,0) 
			FROM MAS_Apartments a 
			join MAS_Rooms r on a.RoomCode = r.RoomCode 
			join MAS_Buildings c on r.BuildingCd = c.BuildingCd
			join PAR_ServicePrice b on a.projectCd = b.ProjectCd
			WHERE a.ApartmentId = @ApartmentId 
				AND b.TypeId = 1 
				AND b.ServiceTypeId = 1 
				and b.ServiceId = c.Id
	--else
	--	select @WaterwayPrice = isnull(b.Price,0) FROM PAR_ServicePrice b 
	--		WHERE b.ServiceId = @ServiceId

	

	-- Return the result of the function
	RETURN @WaterwayPrice

END