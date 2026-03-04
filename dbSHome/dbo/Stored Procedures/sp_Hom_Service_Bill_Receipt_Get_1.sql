
CREATE procedure [dbo].[sp_Hom_Service_Bill_Receipt_Get]
	@userId	nvarchar(450),
	@receiptId bigint
as
	begin try
	 SELECT [ReceiptId]
			  ,[ReceiptNo]
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  --,a.[ApartmentId]
			  ,a.ReceiveId
			  ,a.TranferCd
			  ,isnull([Object],c.fullName) as FullName
			 -- ,A.[Address]
			  ,b.RoomCode + '-' + v.ProjectName as Address
			  ,[Contents]
			  ,[Attach]
			  ,[IsDBCR]
			  ,a.[Amount]
			  ,u2.loginName as [CreatorCd]
			  ,[CreateDate]
			  ,b.RoomCode 
			  ,CONCAT(v.projectCd,'-',v.ProjectName)  as projectFolder
		   FROM MAS_Service_ReceiveEntry d
			join [dbo].MAS_Service_Receipts a on d.ReceiveId = a.ReceiveId
			join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 
			join MAS_Rooms r on isnull(r.RoomCodeView,r.RoomCode) = b.RoomCode
			inner join MAS_Projects v on b.projectCd = v.projectCd
			left join MAS_Customers c on a.CustId= c.CustId
			left join Users u2 on a.CreatorCd = u2.UserId 
			where a.ReceiptId = @receiptId
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Bill_Receipt_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Service_Receipts', 'Get', @SessionID, @AddlInfo
	end catch