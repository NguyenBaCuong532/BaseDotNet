CREATE FUNCTION [dbo].[fn_Hom_ServiceFee_Payday_project] 
(
    -- Add the parameters for the function here
    @prjectCd nvarchar(30),
    @endDate datetime
)
RETURNS 
@ReturnTable TABLE 
(
	RoomCode	nvarchar(50),
	ApartmentId bigint,
	Price		decimal(18,0),
	Quantity    float,
	Amount		decimal(18,0)
)
AS
BEGIN
    DECLARE @Price decimal;
    Insert Into @ReturnTable(RoomCode, ApartmentId, Price, Quantity, Amount)
    Select 
        a.RoomCode,
			  a.ApartmentId,
			  Price = b.Price,
				Quantity = CASE
                      WHEN a.IsFree = 0 THEN 1 
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) < DATEPART(YYYY,a.FreeToDt) THEN 0
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) < DATEPART(M,a.FreeToDt) THEN 0
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) > DATEPART(M,a.FreeToDt) THEN 1
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) > DATEPART(YYYY,a.FreeToDt) THEN 1
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) IN('1','3','5','7','8','10','12')
                          THEN ((31*1.0-DATEPART(D,a.FreeToDt)+1)/31)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) IN('4','6','9','11')
                          THEN ((30*1.0-DATEPART(D,a.FreeToDt)+1)/30)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) = '2' AND DATEPART(YYYY,@endDate)%4 = 0
                          THEN ((29*1.0-DATEPART(D,a.FreeToDt)+1)/29)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) = '2' AND DATEPART(YYYY,@endDate)%4 != 0
                          THEN ((28*1.0-DATEPART(D,a.FreeToDt)+1)/28)
                  END,
					Amount = CASE
                      WHEN a.IsFree = 0 THEN 1*a.WaterwayArea*b.Price
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) < DATEPART(YYYY,a.FreeToDt) THEN 0
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) < DATEPART(M,a.FreeToDt) THEN 0
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) > DATEPART(M,a.FreeToDt) THEN 1*a.WaterwayArea*b.Price
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) > DATEPART(YYYY,a.FreeToDt) 
                          THEN 1*a.WaterwayArea*b.Price
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) IN('1','3','5','7','8','10','12')
                          THEN ((31*1.0-DATEPART(D,a.FreeToDt)+1)*a.WaterwayArea*b.Price/31)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) IN('4','6','9','11')
                          THEN ((30*1.0-DATEPART(D,a.FreeToDt)+1)*a.WaterwayArea*b.Price/30)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) = '2' AND DATEPART(YYYY,@endDate)%4 = 0
                          THEN ((29*1.0-DATEPART(D,a.FreeToDt)+1)*a.WaterwayArea*b.Price/29)
                      WHEN a.IsFree = 1 AND DATEPART(YYYY,@endDate) = DATEPART(YYYY,a.FreeToDt) AND DATEPART(M,@endDate) = DATEPART(M,a.FreeToDt) AND DATEPART(M,@endDate) = '2' AND DATEPART(YYYY,@endDate)%4 != 0
                          THEN ((28*1.0-DATEPART(D,a.FreeToDt)+1)*a.WaterwayArea*b.Price/28)
                    END


				 --  Quantity = CASE WHEN a.IsFree = 0 THEN 1
					--				WHEN a.isfree = 1 and a.FreeToDt >= @endDate  THEN 0 --(Triều Dương tính số tiền dịch vụ lẻ tháng)
					--				WHEN a.isfree = 1 AND a.FreeToDt < @endDate 
     --                                    AND a.FreeToDt <= a.lastReceived 
     --                                    AND DATEPART(m,a.freetodt) = DATEPART(m,@endDate) 
     --                                    AND DATEPART(y,a.freetodt) = DATEPART(y,@endDate)
					--					THEN CASE WHEN DATEPART(m,@endDate) IN('1','3','5','7','8','10','12') THEN ((31-DATEPART(D,a.FreeToDt))/31)
					--								 WHEN DATEPART(m,@endDate) IN('4','6','9','11') THEN ((30*1.0-DATEPART(D,a.FreeToDt))/30)
					--								 ELSE
					--									CASE WHEN DATEPART(y,@endDate)%4 = 0 THEN ((29-DATEPART(D,a.FreeToDt))/29) 
					--										ELSE
					--										((28-DATEPART(D,a.FreeToDt))/28)
					--										END
					--							END 
					--				--ELSE 1
									
							
					--		END
					--,Amount = CASE WHEN a.IsFree = 0 THEN a.WaterwayArea*b.Price
					--				WHEN a.IsFree= 1 and a.FreeToDt >= @endDate   
					--					THEN 0 --(Triều Dương tính số tiền dịch vụ lẻ tháng)
					--				WHEN  a.IsFree= 1 AND a.FreeToDt < @endDate 
     --                               AND a.FreeToDt <= a.lastReceived 
     --                               AND DATEPART(m,a.freetodt) = DATEPART(m,@endDate)
     --                               AND DATEPART(y,a.freetodt) = DATEPART(y,@endDate)
					--					THEN 
					--						CASE WHEN DATEPART(m,@endDate) IN('1','3','5','7','8','10','12') THEN ((31-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/31)
					--								 WHEN DATEPART(m,@endDate) IN('4','6','9','11') THEN ((30-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/30)  
					--								 ELSE
					--									CASE WHEN DATEPART(y,@endDate)%4 = 0 THEN ((29-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/29) 
					--										ELSE
					--										(28-DATEPART(D,a.FreeToDt))*(a.WaterwayArea*b.Price/28)
					--										END
					--							END 
					--				--ELSE 1*a.WaterwayArea*b.Price

					--				--CASE
					--				--	WHEN DATEPART(m,@endDate) IN('1','3','5','7','8','10','12') THEN ((31-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/31)
					--				--				 WHEN DATEPART(m,@endDate) IN('4','6','9','11') THEN ((30-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/30) 
					--				--				 ELSE
					--				--					CASE WHEN DATEPART(y,@endDate)%4 = 0 THEN ((29-DATEPART(D,a.FreeToDt))*a.WaterwayArea*b.Price/29) 
					--				--						ELSE
					--				--						(28-DATEPART(D,a.FreeToDt))*(a.WaterwayArea*b.Price/28)
					--				--						END
					--				--			END 
					--		END
				   --Quantity = case when (a.FreeToDt >= @endDate) AND a.IsFree = 1 then 0 
							--		else 
				   --                   case when a.lastReceived > a.FreeToDt THEN 1  -- DATEDIFF(M,a.lastReceived,@endDate) (Triều Dương)
							--				ELSE --DATEDIFF(M,a.FreeToDt,@endDate) + (31-DATEPART(D,a.FreeToDt)+1)*0.31 end) 
							--				   CASE WHEN DATEPART(m,@endDate) IN('1','3','5','7','8','10','12') THEN ((31*1.0-DATEPART(D,a.FreeToDt))/31)
							--						WHEN DATEPART(m,@endDate) IN('4','6','9','11') THEN ((30*1.0-DATEPART(D,a.FreeToDt))/30) 
							--						ELSE
							--									CASE WHEN DATEPART(y,@endDate)%4 = 0 THEN ((29*1.0-DATEPART(D,a.FreeToDt))/29) 
							--										ELSE
							--										((28*1.0-DATEPART(D,a.FreeToDt))/28)
							--										END
							--								   END
							--					END
							--			END,

						
									

				 --Amount =  case when (a.FreeToDt > @endDate) then 0                          (Triều Dương)
				 --				else   
				 --					(case when a.lastReceived > a.FreeToDt then (DATEDIFF(M,a.lastReceived,@endDate)*a.WaterwayArea*b.Price)
					--			   else DATEDIFF(M,a.FreeToDt,@endDate)*a.WaterwayArea*b.Price
     --                      + (31-DATEPART(D,a.FreeToDt))*(a.WaterwayArea*b.Price/30)end) end


				   --Quantity = case when a.FreeToDt > @endDate then 0 
				   --           case when a.FreeToDt < @endDate and DATEDIFF(M,a.FreeToDt,@endDate)= 0 then 1
							--  case when a.FreeToDt < @endDate and DATEDIFF(M,a.FreeToDt,@endDate)= 1 then DATEDIFF(M,a.FreeToDt,@endDate)
							--  case when a.FreeToDt < @endDate and DATEDIFF(M,a.FreeToDt,@endDate) > 1 and a.FreeToDt> a.lastReceived then 
						
    FROM
        MAS_Apartments a
        left join PAR_ServicePrice b on a.projectCd = b.ProjectCd and TypeId = 1 and ServiceTypeId = 1
    where a.projectCd = @prjectCd
				--and  isnull(a.lastReceived,a.FreeToDt) < @endDate

		   --update t
		   --set t.Quantity = case when a.FreeToDt > a.lastReceived and a.FreeToDt > @endDate and a.IsFree = 1 then 0 else t.Quantity end,
		   --    t.Amount = case when a.FreeToDt > a.lastReceived and a.FreeToDt > @endDate then 0 else t.Amount end
		   --from @ReturnTable t inner join MAS_Apartments a on t.ApartmentId = a.ApartmentId
		   --left join PAR_ServicePrice b on a.projectCd = b.ProjectCd and TypeId = 1 and ServiceTypeId = 1

		--RETURN 
	--end
	RETURN
END