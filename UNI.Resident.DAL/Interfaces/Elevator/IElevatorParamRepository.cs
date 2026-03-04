using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;

namespace UNI.Resident.DAL.Interfaces.Elevator
{
    public interface IElevatorParamRepository
    {
        #region elevator-reg
        
        Task<CommonDataPage> GetCardRolePage(FilterBase flt);
        Task<CommonViewInfo> GetCardRoleInfo(string id);
        Task<BaseValidate> SetCardRoleInfo(CommonViewInfo info);
        Task<BaseValidate> DelCardRole(string id);
        Task<List<CommonValue>> GetCardRoles(string userId);

        Task<CommonDataPage> GetBankShaftPage(FilterInputBuilding filter);
        Task<CommonViewInfo> GetBankShaftInfo(string buildingCd, string id);
        Task<BaseValidate> SetBankShaftInfo(CommonViewInfo info);
        Task<BaseValidate> DelBankShaft(string buildingCd, string id);
        Task<List<CommonValue>> GetBankShafts(string projectCd);
        Task<List<CommonValue>> GetFloorTypeList(string areaCd);
        #endregion elevator-reg
    }
}
