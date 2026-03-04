
CREATE PROCEDURE [dbo].[sp_res_noble_apartment_list]
				@phone NVARCHAR(50)
AS
	BEGIN
		SELECT   a.ApartmentId, a.RoomCode
			FROM MAS_Apartments a
			LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid 
			JOIN UserInfo m ON a.UserLogin = m.LoginName 
			JOIN MAS_Customers c ON m.CustId = c.CustId 
			WHERE m.phone = @phone			
	END