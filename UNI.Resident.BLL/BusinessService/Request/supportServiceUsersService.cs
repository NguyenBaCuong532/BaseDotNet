using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Request;
using UNI.Resident.DAL.Interfaces.Request;
using UNI.Resident.Model.Request;

namespace UNI.Resident.BLL.BusinessService.Request
{
    /// <summary>
    /// Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ
    /// </summary>
    public class SupportServiceUsersService : UniBaseService, ISupportServiceUsersService
    {
        private readonly ISupportServiceUsersRepository _repository;

        public SupportServiceUsersService(ISupportServiceUsersRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetsupportServiceUsersFilter()
            => _repository.GetsupportServiceUsersFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetsupportServiceUsersPage(SupportServiceUsersFilter filter)
            => _repository.GetsupportServiceUsersPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetsupportServiceUsersFields(Guid? oid = null, viewBaseInfo inputData = null)
            => _repository.GetsupportServiceUsersFields(oid, inputData);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetsupportServiceUsers(CommonViewInfo inputData)
            => _repository.SetsupportServiceUsers(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetsupportServiceUsersDelete(List<Guid> arrOid)
            => _repository.SetsupportServiceUsersDelete(arrOid);
    }
}
