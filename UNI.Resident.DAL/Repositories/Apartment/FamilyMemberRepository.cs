using Dapper;
using DapperParameters;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces.Apartment;
using UNI.Resident.Model;
using UNI.Resident.Model.Apartment;
using UNI.Resident.Model.Notification;
using UNI.Resident.Model.Resident;
using static UNI.Common.CommonBase.UniBaseRepository;

namespace UNI.Resident.DAL.Repositories.Apartment
{
    public class FamilyMemberRepository : UniBaseRepository, IFamilyMemberRepository
    {
        protected ILogger<FamilyMemberRepository> _logger;

        public FamilyMemberRepository(IConfiguration configuration,
            ILogger<FamilyMemberRepository> logger,
            IHostingEnvironment environment, IUniCommonBaseRepository common) : base(common)
        {
            _logger = logger;
        }
        #region web-apartment

        public async Task<CommonDataPage> GetFamilyMemberPage(FamilyMemberRequestModel query)
        {
            const string storedProcedure = "sp_res_family_member_page";
            return await GetDataListPageAsync(storedProcedure, query, new
            {
                ApartmentId = query.ApartmentId,
                Oid = query.Oid,
                MemberType = query.MemberType ?? "Current"
            });
        }

        public async Task<CommonDataPage> GetMemberHistoryPage(MemberHistoryRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_member_history_page";
            return await GetDataListPageAsync(storedProcedure, query, new
            {
                ApartmentId = query.ApartmentId,
                Oid = query.Oid
            });
        }
        public async Task<FamilyMemberChangeHostInfo> GetFamilyMemberChangHost(string CustId, int? ApartmentId, Guid? apartOid)
        {
            const string storedProcedure = "sp_res_apartment_change_host_field";
            return await GetFieldsAsync<FamilyMemberChangeHostInfo>(storedProcedure, new { CustId, ApartmentId, apartOid });
        }

        public async Task<BaseValidate> SetFamilyMemberChangHost(FamilyMemberChangeHostInfo info)
        {
            const string storedProcedure = "sp_res_apartment_change_host_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new { info.Id });
        }
        public async Task<FamilyMemberInfo> GetFamilyMemberInfo(string CustId, int? ApartmentId, Guid? apartOid)
        {
            const string storedProcedure = "sp_res_apartment_family_member_field";
            return await GetFieldsAsync<FamilyMemberInfo>(storedProcedure, new
            {
                CustId,
                ApartmentId = ApartmentId,
                Oid = apartOid
            });
        }
        public async Task<FamilyMemberInfo> GetFamilyMemberByPhone(string filter, string ApartmentId, Guid? apartOid = null)
        {
            const string storedProcedure = "sp_res_apartment_family_member_phone_field";
            return await GetFieldsAsync<FamilyMemberInfo>(storedProcedure, new { filter, ApartmentId, apartOid });
        }

        public async Task<FamilyMemberInfo> SetFamilyMemberDraft(FamilyMemberInfo info)
        {
            const string storedProcedure = "sp_res_apartment_family_member_field_draft";
            return await SetInfoAsync<FamilyMemberInfo>(storedProcedure, info, param =>
            {
                param.Add("@ApartmentId", info.GetValueByFieldName("ApartmentId"));
                param.Add("@apartOid", info.apartOid);
                return param;
            });
        }

        public async Task<FamilyMemberInfo> SetMergeMemberDraft(FamilyMemberInfo info)
        {
            const string storedProcedure = "sp_res_apartment_merge_member_field_draft";
            return await SetInfoAsync<FamilyMemberInfo>(storedProcedure, info, param =>
            {
                param.Add("@ApartmentId", info.GetValueByFieldName("ApartmentId"));
                param.Add("@apartOid", info.apartOid);
                // Thêm custId từ các field có thể có: custId, CustId, custIds, CustIds
                var custId = info.GetValueByFieldName("custId");
                if (custId != null)
                {
                    param.Add("@custId", custId);
                }
                return param;
            });
        }

        public async Task<BaseValidate> SetFamilyMemberInfo(FamilyMemberInfo info)
        {
            const string storedProcedure = "sp_res_family_member_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info, new
            {
                Oid = info.Id,
                apartOid = info.apartOid,
                ApartmentId = info.ApartmentId
            });
        }
        public async Task<BaseValidate> DelFamilyMember(string CustId, int? apartmentId, Guid? Oid, Guid? apartOid)
        {
            const string storedProcedure = "sp_res_apartment_family_member_del";
            return await DeleteAsync(storedProcedure, new
            {
                CustId,
                apartmentId = apartmentId,
                Oid = Oid,
                apartOid = apartOid
            });
        }
        public async Task<CommonViewInfo> GetHouseholdFilter(string userId)
        {
            const string storedProcedure = "sp_res_apartment_household_filter";
            return await GetFieldsAsync<CommonViewInfo>(storedProcedure, new { userId });
        }
        public async Task<BaseValidate> LeaveMembersBulk(string userId, int apartmentId, string custIdsCsv, string actionDate, string note)
        {
            const string storedProcedure = "sp_res_apartment_members_leave_set";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { UserId = userId, ApartmentId = apartmentId, CustIds = custIdsCsv, ActionDate = actionDate, Note = note });
        }
        public async Task<CommonDataPage> GetHouseholdPageByApartment(HouseholdRequestModel query)
        {
            const string storedProcedure = "sp_res_apartment_household_page_byid";
            return await GetDataListPageAsync(storedProcedure, query, new { query.ApartmentId });
        }
        public async Task<CommonDataPage> GetHouseholdPage(HouseholdRequestModel1 query)
        {
            const string storedProcedure = "sp_res_household_page";
            return await GetDataListPageAsync(storedProcedure, query, new { query.projectCd, query.buildingCd });
        }
        public async Task<HouseholdInfo> GetHouseholdInfo(string CustId)
        {
            const string storedProcedure = "sp_res_apartment_household_field";
            return await GetFieldsAsync<HouseholdInfo>(storedProcedure, new { CustId });
        }

        public async Task<BaseValidate> SetHouseholdInfo(HouseholdInfo info)
        {
            const string storedProcedure = "sp_res_apartment_household_set";
            return await SetInfoAsync<BaseValidate>(storedProcedure, info);
            //return await SetInfoAsync<BaseValidate>(storedProcedure, null, new
            //{
            //    info.CustId,
            //    info.UserID,
            //    info.IsResident,
            //    info.ResAdd1,
            //    info.ContactAdd1,
            //    info.PassNo,
            //    info.PassDate,
            //    info.PassPlace,
            //    info.ApartmentId
            //});
        }
        public async Task<BaseValidate> SetFamilyMemberAuth(HomMemberBase customer)
        {
            const string storedProcedure = "sp_res_apartment_home_member_approve";
            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure,
                new { customer.custId, customer.apartmentId, memberUserId = customer.userId });
        }

        public async Task<IEnumerable<MemberItem>> GetFamilyMemberAsync(long apartmentId, Guid? apartOid = null)
        {
            const string storedProcedure = "sp_res_apartment_family_member_list";
            return await GetListAsync<MemberItem>(storedProcedure, new { apartmentId, apartOid });
        }

        public async Task<BaseValidate> SetMergeMemberInfo(string userId, MergeMemberInfo request)
        {
            const string storedProcedure = "sp_res_apartment_family_member_merge_set";

            // Tự động tạo arrObj từ dataList nếu:
            // 1. arrObj không có hoặc rỗng
            // 2. Hoặc tất cả các item trong arrObj đều có result là null
            List<MergeMemberFieldItem> tableData;
            bool shouldCreateFromDataList = request.arrObj == null
                || request.arrObj.Count == 0
                || request.arrObj.All(item => string.IsNullOrEmpty(item.result));

            if (shouldCreateFromDataList)
            {
                // Tự động tạo arrObj từ dataList: ưu tiên result, sau đó name1 (value1=true) hoặc name (value=true)
                tableData = (request.dataList ?? new List<MergeMemberItem>())
                    .Select(item =>
                    {
                        // Tính toán result: ưu tiên result đã có, sau đó name1 (value1=true) hoặc name (value=true)
                        var calculatedResult = !string.IsNullOrEmpty(item.result)
                            ? item.result
                            : (item.value1 == true && !string.IsNullOrEmpty(item.name1))
                                ? item.name1
                                : (item.value == true && !string.IsNullOrEmpty(item.name))
                                    ? item.name
                                    : null;

                        // Chỉ thêm vào arrObj nếu có result
                        if (!string.IsNullOrEmpty(calculatedResult))
                        {
                            return new MergeMemberFieldItem
                            {
                                fieldName = item.fieldName,
                                result = calculatedResult,
                                custId = item.custId ?? request.CustId1 ?? request.CustId // Ưu tiên custId từ item, sau đó CustId1, cuối cùng CustId
                            };
                        }

                        return null;
                    })
                    .Where(item => item != null) // Lọc bỏ các item có result null
                    .ToList();
            }
            else
            {
                // Sử dụng arrObj từ request (đã có sẵn 3 trường: fieldName, result, custId)
                // Lọc bỏ các item có result null (chỉ giữ các item có giá trị)
                tableData = request.arrObj
                    .Where(item => !string.IsNullOrEmpty(item.result))
                    .ToList();
            }

            return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, null,
                parametersHandler: param =>
                {
                    param.AddTable("ArrObj", "MergeMemberField", tableData);
                    param.Add("UserId", userId);
                    param.Add("ApartmentId", request.ApartmentId);
                    param.Add("CustId", request.CustId); // Thành viên bị gộp (memberFirst)
                    param.Add("CustId1", request.CustId1); // Thành viên được gộp (memberSecond)
                    return param;
                });
        }

        public async Task<MergeMemberInfo> GetMergeMemberInfo(GetMergeMemberInfoRequest query)
        {
            const string storedProcedure = "sp_res_apartment_get_two_members";

            var data = new MergeMemberInfo
            {
                ApartmentId = query.ApartmentId
            };

            // Dùng GetMultipleAsync<T> với async reader handler để đọc multiple result sets
            data = await GetMultipleAsync<MergeMemberInfo>(storedProcedure,
                parametersHandler: param =>
                {
                    param.Add("@userId", query.userId ?? CommonBase.CommonInfo.UserId);
                    param.Add("@ApartmentId", query.ApartmentId);
                    param.Add("@CustIds", query.CustIds ?? (string)null);
                    return param;
                },
                async reader =>
                {
                    // Đọc root record (result set 1) - lấy CustId và CustId1 từ đây
                    if (!reader.IsConsumed)
                    {
                        var rootRecord = await reader.ReadFirstOrDefaultAsync<dynamic>();
                        if (rootRecord != null)
                        {
                            // Lấy CustId và CustId1 từ root record (stored procedure trả về CustId1 và CustId2)
                            if (rootRecord.CustId1 != null)
                                data.CustId = rootRecord.CustId1.ToString();
                            if (rootRecord.CustId2 != null)
                                data.CustId1 = rootRecord.CustId2.ToString();
                        }
                    }

                    // Đọc grid config (result set 2) - từ fn_config_list_gets
                    if (!reader.IsConsumed)
                    {
                        var gridConfig = await reader.ReadAsync<viewGridFlex>();
                        data.gridflexs = gridConfig != null ? gridConfig.ToList() : new List<viewGridFlex>();
                    }
                    else
                    {
                        data.gridflexs = new List<viewGridFlex>();
                    }

                    // Đọc data list (result set 3) và gán vào dataList
                    if (!reader.IsConsumed)
                    {
                        var dataList = await reader.ReadAsync<MergeMemberItem>();
                        data.dataList = dataList != null ? dataList.ToList() : new List<MergeMemberItem>();
                    }
                    else
                    {
                        // Đảm bảo dataList luôn là list, không phải null
                        data.dataList = new List<MergeMemberItem>();
                    }

                    // Tạo arrObj từ dataList - chỉ giữ fieldName, result và custId đều null
                    data.arrObj = data.dataList
                        .Select(item => new MergeMemberFieldItem
                            {
                                fieldName = item.fieldName,
                                result = null,
                                custId = null
                            })
                        .ToList();

                    return data;
                });

            return data;
        }

        #endregion

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public async Task<List<CommonValue>> GetApartmentMemberForDropdownList(int apartmentId, Guid? custId, string filter, Guid? apartOid = null)
            => await base.GetListAsync<CommonValue>("sp_res_apartment_member_get_code_name", new { apartmentId, custId, filter, apartOid });
    }
}
