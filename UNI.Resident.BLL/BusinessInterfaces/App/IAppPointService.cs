using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.App
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IAppPointService
    {
        #region app-point-reg
        Task<PagePayment> GetPagePaymentAsync(FilterBasePayment filter);
        Task<HomPaymentGet> GetPaymentDetailAsync(long receiveId);
        Task<HomTransferInfo> GetTransferInfoAsync(long receiveId);
        #endregion app-point-reg

    }
}
