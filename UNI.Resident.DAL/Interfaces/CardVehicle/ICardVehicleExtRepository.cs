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

namespace UNI.Resident.DAL.Interfaces.CardVehicle
{
    public interface ICardVehicleExtRepository
    {
        
        #region web-card-reg
        
        Task SetCardLocked(string userId, HomCardLock card);
        Task<BaseValidate> DeleteCard(string userId, string cardCd);
        #endregion card-reg

        #region card vehicle

        Task<BaseValidateForHrm> SetCardVehicle(string userId, CommonViewInfo info);
        Task<BaseValidateForHrm> SetEmployeeVehicleRes(string userId, HomCardVehicleForSet vehicleSet);
        Task<List<CommonValue>> GetCardVehicle(string userId, string CustId);
        Task<BaseValidate> SetVehicleRegCancel(string userId, HomVehicleRegCancel regSet);
        Task SetVehicleApprove(HomVehicleApprove vehicle);
        Task<BaseValidate> SetVehicleLockRes(string userId, HomVehicleLock vehicle);
        Task<ImportListPage> SetCardsAcceptRes(string userId, homeCardsImportSet cards);
        Task<ImportListPage> SetCardVehicleAcceptRes(string userId, homCardVehicleImportSet cards);
        Task SetCustomerResident(string userId, homCustomerInfo cust);
        #endregion

        #region app
        Task<BaseValidateForHrm> SetVehicleRegisterRes(string userId, homVehicleRegSetApp vehicle);
        Task<BaseValidate> LockVehicleRes(string userId, HomAppVehicleLock vehicle);
        #endregion

    }
}
