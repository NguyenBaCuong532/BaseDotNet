using UNI.Resident.BLL.BusinessInterfaces.Apartment;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Utils;

namespace UNI.Resident.BLL.BusinessService.Apartment
{
    public class FamilyMemberService : IFamilyMemberService
    {
        private readonly IFamilyMemberRepository _apartmentRepository;
        public FamilyMemberService(
            IFamilyMemberRepository apartmentRepository)
        {
            if (apartmentRepository != null)
                _apartmentRepository = apartmentRepository;
        }

        public async Task<CommonDataPage> GetFamilyMemberPage(FamilyMemberRequestModel query)
        {
            return await _apartmentRepository.GetFamilyMemberPage(query);
        }

        public Task<CommonDataPage> GetMemberHistoryPage(MemberHistoryRequestModel query)
        {
            return _apartmentRepository.GetMemberHistoryPage(query);
        }
        public Task<FamilyMemberChangeHostInfo> GetFamilyMemberChangHost(string CustId, int? ApartmentId, Guid? apartOid)
        {
            return _apartmentRepository.GetFamilyMemberChangHost(CustId, ApartmentId, apartOid);
        }

        public Task<BaseValidate> SetFamilyMemberChangHost(FamilyMemberChangeHostInfo info)
        {
            return _apartmentRepository.SetFamilyMemberChangHost(info);
        }
        public Task<FamilyMemberInfo> GetFamilyMemberInfo(string CustId, int? ApartmentId, Guid? apartOid)
        {
            return _apartmentRepository.GetFamilyMemberInfo(CustId, ApartmentId, apartOid);
        }
        public Task<FamilyMemberInfo> GetFamilyMemberByPhone(string filter, string ApartmentId, Guid? apartOid = null)
        {
            return _apartmentRepository.GetFamilyMemberByPhone(filter, ApartmentId, apartOid);
        }

        public Task<FamilyMemberInfo> SetFamilyMemberDraft(FamilyMemberInfo info)
        {
            return _apartmentRepository.SetFamilyMemberDraft(info);
        }
        public Task<FamilyMemberInfo> SetMergeMemberDraft(FamilyMemberInfo info)
        {
            return _apartmentRepository.SetMergeMemberDraft(info);
        }
        public Task<BaseValidate> SetFamilyMemberInfo(FamilyMemberInfo info)
        {
            return _apartmentRepository.SetFamilyMemberInfo(info);
        }
        public async Task<BaseValidate> DelFamilyMember(string CustId, int? apartmentId, Guid? Oid, Guid? apartOid)
        {
            return await _apartmentRepository.DelFamilyMember(CustId, apartmentId, Oid, apartOid);
        }
        public Task<IEnumerable<MemberItem>> GetFamilyMember(long apartmentId, Guid? apartOid = null)
        {
            return _apartmentRepository.GetFamilyMemberAsync(apartmentId, apartOid);
        }
        public Task<BaseValidate> SetFamilyMemberAuth(HomMemberBase customer)
        {
            return _apartmentRepository.SetFamilyMemberAuth(customer);
        }
        public Task<BaseValidate> LeaveMembersBulk(string userId, int apartmentId, string[] custIds, string actionDate, string note)
        {
            var csv = custIds != null ? string.Join(",", custIds) : string.Empty;
            return _apartmentRepository.LeaveMembersBulk(userId, apartmentId, csv, actionDate, note);
        }
        public Task<BaseValidate> SetMergeMemberInfo(string userId, MergeMemberInfo request)
        {
            return _apartmentRepository.SetMergeMemberInfo(userId, request);
        }

        public Task<MergeMemberInfo> GetMergeMemberInfo(GetMergeMemberInfoRequest query)
        {
            return _apartmentRepository.GetMergeMemberInfo(query);
        }
        // Hộ khẩu

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<List<CommonValue>> GetApartmentMemberForDropdownList(int apartmentId, Guid? custId, string filter, Guid? apartOid = null)
            => _apartmentRepository.GetApartmentMemberForDropdownList(apartmentId, custId, filter, apartOid);
    }
}
