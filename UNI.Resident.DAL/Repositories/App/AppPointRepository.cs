using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="IAppPointRepository" />
    public class AppPointRepository : UniBaseRepository, IAppPointRepository
    {
        private readonly IFirebaseRepository _notifyRepository;
        private readonly INotifyRepository _appRepository;
        private readonly IHostingEnvironment _environment;
        private readonly ILogger<AppPointRepository> _logger;
        private readonly FlexcellUtils flexcellUtils;

        public AppPointRepository(IUniCommonBaseRepository common, IFirebaseRepository notifyRepository, INotifyRepository appRepository, IHostingEnvironment environment, ILogger<AppPointRepository> logger)
            : base(common)
        {
            _notifyRepository = notifyRepository;
            _appRepository = appRepository;
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
        }
        #region app-apartment-reg
        public async Task<PagePayment> GetPagePaymentAsync(FilterBasePayment filter)
        {
            const string storedProcedure = "sp_Hom_App_Payment_ByUserId";
            return await GetMultipleAsync<PagePayment>(storedProcedure, new {
                userId = filter.userId,
                ApartmentId = filter.ApartmentId,
                payType = filter.payType,
                month = filter.Month,
                year = filter.Year,
                Offset = filter.offSet,
                PageSize = filter.pageSize
            }, async reader =>
            {
                var shopPage = new PagePayment();
                var paylist = (await reader.ReadAsync<HomReceivable>()).ToList();
                // Đọc output param nếu cần, hoặc truyền lại từ filter nếu store trả về
                shopPage.Payments = new ResponseList<List<HomReceivable>>(paylist, 0, 0); // Sửa lại nếu cần lấy Total, TotalFiltered
                return shopPage;
            });
        }
        public async Task<HomPaymentGet> GetPaymentDetailAsync(long receiveId)
        {
            const string storedProcedure = "sp_Hom_App_Payment_Get";
            return await GetMultipleAsync<HomPaymentGet>(storedProcedure, new { receiveId }, async reader =>
            {
                var pay = await reader.ReadFirstOrDefaultAsync<HomPaymentGet>();
                if (pay != null)
                {
                    pay.apartmentFee = await reader.ReadFirstOrDefaultAsync<HomPaymentApartmentFee>();
                    pay.ServiceVehicle = (await reader.ReadAsync<HomPaymentServiceVehicle>()).ToList();
                    pay.ServiceLiving = (await reader.ReadAsync<HomPaymentServiceLiving>()).ToList();
                    pay.ServiceExtend = (await reader.ReadAsync<HomPaymentServiceExtend>()).ToList();
                    if (pay.ServiceLiving != null)
                    {
                        var callist = (await reader.ReadAsync<HomServiceLivingCalSheet>()).ToList();
                        foreach (var sl in pay.ServiceLiving)
                        {
                            sl.calSheets = callist.Where(c => c.TrackingId == sl.TrackingId).ToList();
                        }
                    }
                }
                return pay;
            });
        }
        public async Task<HomTransferInfo> GetTransferInfoAsync(long receiveId)
        {
            const string storedProcedure = "sp_Hom_App_Payment_Transfer";
            return await GetMultipleAsync<HomTransferInfo>(storedProcedure, new { receiveId }, async reader =>
            {
                var pay = await reader.ReadFirstOrDefaultAsync<HomTransferInfo>();
                return pay;
            });
        }
        #endregion app-apartment-reg
    }
}
