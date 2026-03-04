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
  public interface IFamilyMemberRepository
  {
    #region web-apartment
    // Thành viên trong căn hộ
    Task<CommonDataPage> GetFamilyMemberPage(FamilyMemberRequestModel query);
    Task<FamilyMemberChangeHostInfo> GetFamilyMemberChangHost(string CustId, int? ApartmentId, Guid? apartOid);
    Task<BaseValidate> SetFamilyMemberChangHost(FamilyMemberChangeHostInfo info);
    Task<FamilyMemberInfo> GetFamilyMemberInfo(string CustId, int? ApartmentId, Guid? apartOid);
    Task<FamilyMemberInfo> GetFamilyMemberByPhone(string filter, string ApartmentId, Guid? apartOid = null);// search thành viên dựa vào sđt
    Task<FamilyMemberInfo> SetFamilyMemberDraft(FamilyMemberInfo info); // thay đổi thông tin khi draft
    Task<FamilyMemberInfo> SetMergeMemberDraft(FamilyMemberInfo info); // draft thông tin gộp thành viên
    Task<BaseValidate> SetFamilyMemberInfo(FamilyMemberInfo info);
    Task<BaseValidate> DelFamilyMember(string CustId, int? apartmentId, Guid? Oid, Guid? apartOid);
    Task<IEnumerable<MemberItem>> GetFamilyMemberAsync(long apartmentId, Guid? apartOid = null);
    Task<BaseValidate> SetFamilyMemberAuth(HomMemberBase customer);

    Task<BaseValidate> LeaveMembersBulk(string userId, int apartmentId, string custIdsCsv, string actionDate, string note);

    Task<BaseValidate> SetMergeMemberInfo(string userId, MergeMemberInfo request);

    Task<CommonDataPage> GetMemberHistoryPage(MemberHistoryRequestModel query);

    Task<MergeMemberInfo> GetMergeMemberInfo(GetMergeMemberInfoRequest query);

    #endregion

    Task<List<CommonValue>> GetApartmentMemberForDropdownList(int apartmentId, Guid? custId, string filter, Guid? apartOid = null);
  }
}
