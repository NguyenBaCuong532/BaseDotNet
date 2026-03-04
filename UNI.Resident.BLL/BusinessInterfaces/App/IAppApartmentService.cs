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
    public interface IAppApartmentService
    {
        #region app-apartment-reg
        Task SetApartmentRegAsync(string userId, HomApartmentReg reg);
        Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language);
        Task<homApartmentPage> GetApartmentListAsync(string userId);
        Task SetApartmentMainAsync(HomApartmentStatus main);
        Task<homApartmentCartPage> GetApartmentCartsAsync(string userId);
        Task<homApartmentCartDetail> GetApartmentCartDetailAsync(string language, string roomCd);
        Task<PageFamilyMember> GetPageFamilyMemberAsync(int? ApartmentId);
        Task<HomApartmentMemberGet> SetMemberProfileAsync(HomMemberProfileSet profile);
        Task<HomApartmentMemberGet> GetFamilyMemberAsync(string custId, int apartmentId);
        Task<BaseValidate> DeleteFamilyMemberAsync(string custId, int apartmentId);
        Task<List<HomApartmentRelation>> GetApartmentRationsAsync(string userId);
        Task<BaseValidate> SetFamilyMemberAuthAsync(HomMemberBase customer);
        Task SetFamilyMemberRejectAsync(HomMemberBase customer);
        #endregion web-apartment

    }
}
