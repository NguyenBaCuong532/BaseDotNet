using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;

namespace UNI.Resident.DAL.Interfaces.App
{
    public interface IAppApartmentRepository
    {
        #region app-apartment-reg
        Task SetApartmentRegAsync(string userId, HomApartmentReg reg);
        Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language);
        Task<homApartmentPage> GetApartmentListAsync(string userId);
        Task SetApartmentMainAsync(HomApartmentStatus main);
        Task<homApartmentCartPage> GetApartmentCartAsync(string userId);
        Task<homApartmentCartDetail> GetApartmentCartDetailAsync(string language, string roomCd);
        Task<PageFamilyMember> GetPageFamilyMemberAsync(int? ApartmentId);
        #endregion app-apartment-reg

        #region web-apartment
        //Task<HomApartmentPage> GetApartmentPageAsync(FilterBaseApartments filter);
        //Task<HomApartmentInfo> GetApartmentInfoAsync(long apartmentId);
        Task<List<HomApartmentRelation>> GetApartmentRationsAsync(string userId);
        //Task<BaseValidate> SetFamilyMemberAsync(HomApartmentMemberSet customer);
        Task<HomApartmentMemberGet> SetMemberProfileAsync(HomMemberProfileSet face);
        Task<BaseValidate> DeleteFamilyMemberAsync(string custId, int apartmentId);
        Task<HomApartmentMemberGet> GetFamilyMemberAsync(string custId, int apartmentId);
        Task<BaseValidate> SetFamilyMemberAuthAsync(HomMemberBase customer);
        Task SetFamilyMemberRejectAsync(HomMemberBase customer);
        #endregion web-apartment
    }
}
