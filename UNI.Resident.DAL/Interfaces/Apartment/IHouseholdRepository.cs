using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.DAL.Interfaces.Apartment
{
    public interface IHouseholdRepository
    {
        #region web-apartment
        Task<CommonViewInfo> GetHouseholdFilter(string userId);
        Task<CommonDataPage> GetHouseholdPageByApartment(HouseholdRequestModel query);// căn hộ/Hộ khẩu
        Task<CommonDataPage> GetHouseholdPage(HouseholdRequestModel1 query);// QL Hộ khẩu
        Task<HouseholdInfo> GetHouseholdInfo(string CustId, int? ApartmentId, Guid? apartOid, Guid? Oid);
        Task<BaseValidate> SetHouseholdInfo(HouseholdInfo info);
        
        #endregion
    }
}
