using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.DAL.Commons;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Request;

namespace UNI.Resident.DAL.Repositories.Request
{
    /// <summary>
    /// Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ
    /// </summary>
    public class SupportServiceUsersRepository : ResidentBaseRepository, ISupportServiceUsersRepository
    {
        public SupportServiceUsersRepository(IResidentCommonBaseRepository common) : base(common)
        {

        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetsupportServiceUsersFilter()
            => this.GetTableFilter("config_sp_res_support_service_users_filter");

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetsupportServiceUsersPage(SupportServiceUsersFilter filter)
            => base.GetDataListPageAsync("sp_res_support_service_users_page",
                filter,
                objParams: new
                {
                    service_type_oid = filter.ServiceTypeOid
                });


        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetsupportServiceUsersFields(Guid? oid = null, viewBaseInfo inputData = null)
        {
            object objParam = inputData != null ? inputData.ConvertToParam() : new { oid };
            return base.GetFieldsAsync<viewBaseInfo>("sp_res_support_service_users_field", dynamicParam: null, objParam);
        }

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetsupportServiceUsers(CommonViewInfo inputData)
            => this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_support_service_users_set", inputData.ConvertToParam());

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public async Task<BaseValidate> SetsupportServiceUsersDelete(List<Guid> arrOid)
            => await this.GetFirstOrDefaultAsync<BaseValidate>("sp_res_support_service_users_del", new { ArrOid = string.Join(",", arrOid) });
    }
}
