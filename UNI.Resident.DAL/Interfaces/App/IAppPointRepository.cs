using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.App
{
    public interface IAppPointRepository
    {
        #region app-point-reg
        Task<PagePayment> GetPagePaymentAsync(FilterBasePayment filter);
        Task<HomPaymentGet> GetPaymentDetailAsync(long receiveId);
        Task<HomTransferInfo> GetTransferInfoAsync(long receiveId);
        #endregion app-point-reg
    }
}
