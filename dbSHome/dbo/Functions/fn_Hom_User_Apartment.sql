

CREATE FUNCTION [dbo].[fn_Hom_User_Apartment]
(
	@userId nvarchar(450)
)
RETURNS 
@apar TABLE 
(
	ApartmentId bigint,
	RelationId	int,
	IsHost		bit,
	custId		nvarchar(100)
)
AS
BEGIN
	;WITH x AS
	(
		-- anchor:
		select top 1 a.ApartmentId
			,u.RelationId
			,case when exists(select 1 from UserInfo u1 where u1.custId = u.CustId and u1.loginName = a.UserLogin) then 1 else 0 end as IsHost
			,u2.custId 
		FROM [MAS_Apartments] a 
			join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
			join UserInfo u2 on u.CustId = u2.custId 
		WHERE u2.userId = @UserId 
			and u.member_st = 1
			and a.IsReceived = 1
		order by isnull(u.main_st,0) desc
		--UNION ALL
		---- recursive:
		--SELECT t.id, t.parent_id
		--FROM x INNER JOIN product_categories AS t
		--ON t.parent_id = x.ID
		--where t.id <> t.parent_id
	)
	insert into @apar(ApartmentId, RelationId, IsHost, custId)
	select ApartmentId, RelationId, IsHost, custId from x

OPTION (MAXRECURSION 32);
	RETURN 
END