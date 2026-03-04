using System;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Apartment
{
    public interface IHouseholdService
    {
        #region web-Household
        // Hộ khẩu
        Task<CommonViewInfo> GetHouseholdFilter(string userId);
        Task<CommonDataPage> GetHouseholdPageByApartment(HouseholdRequestModel query);// Căn hộ/Hộ khẩu
        Task<CommonDataPage> GetHouseholdPage(HouseholdRequestModel1 query);// QL Hộ khẩu
        Task<HouseholdInfo> GetHouseholdInfo(string CustId, int? ApartmentId, Guid? apartOid, Guid? Oid);
        Task<BaseValidate> SetHouseholdInfo(HouseholdInfo info);

        #endregion
    }
}
