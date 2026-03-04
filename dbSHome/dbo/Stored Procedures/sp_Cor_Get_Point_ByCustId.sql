




CREATE procedure [dbo].[sp_Cor_Get_Point_ByCustId]
@userId	nvarchar(450),
@custId	nvarchar(50)

as
	begin try
	if not (@custId is null or @custId = '')
	begin
	--1
		SELECT [PointCd]
			  ,[PointType]
			  ,[CustId]
			  ,[CurrPoint] as CurrentPoint
			  ,[LastDt] as LastDate
			  ,'Platinum' as [Priority]
		  FROM MAS_Points p 
		  WHERE CustId = @custId
	  --2
	
	end
	else
	begin
		--1
		SELECT [PointCd]
			  ,[PointType]
			  ,[CustId]
			  ,[CurrPoint] as CurrentPoint
			  ,[LastDt] as LastDate
			  ,'Platinum' as [Priority]
		  FROM MAS_Points p 
		  WHERE exists(select userId from UserInfo where CustId = p.CustId and UserId = @userId)
	  --2

	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Get_Point_ByCustId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' + @custId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch