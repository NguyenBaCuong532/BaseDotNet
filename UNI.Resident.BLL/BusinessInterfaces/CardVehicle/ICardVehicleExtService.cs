using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.CardVehicle
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface ICardVehicleExtService
    {
        
        #region web-card-reg
        
        Task SetCardLocked(string userId, HomCardLock card);
        Task<BaseValidate> DeleteCard(string userId, string cardCd);
        #endregion web-card-reg


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
        Task<BaseValidateForHrm> SetVehicleRegisterRes(string userId, homVehicleRegSetApp vehicle);
        Task<BaseValidate> LockVehicleRes(string userId, HomAppVehicleLock vehicle);

        #endregion
    }
}
