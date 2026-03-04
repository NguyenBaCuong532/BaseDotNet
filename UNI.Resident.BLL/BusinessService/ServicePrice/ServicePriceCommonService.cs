using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.ServicePrice;
using UNI.Resident.DAL.Interfaces.ServicePrice;

namespace UNI.Resident.BLL.BusinessService.ServicePrice
{
    /// <summary>
    /// Cấu hình giá dịch vụ chung
    /// </summary>
    public class ServicePriceCommonService : UniBaseService, IServicePriceCommonService
    {
        private readonly IServicePriceCommonRepository _repository;

        public ServicePriceCommonService(IServicePriceCommonRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao cho danh sách dữ liệu phần trang dạng lưới
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetServicePriceCommonFilter()
            => _repository.GetServicePriceCommonFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị dạng lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetServicePriceCommonPage(FilterBase filter)
            => _repository.GetServicePriceCommonPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetServicePriceCommonFields(Guid? oid)
            => _repository.GetServicePriceCommonFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceCommon(CommonViewInfo inputData)
            => _repository.SetServicePriceCommon(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetServicePriceCommonDelete(List<Guid> arrOid)
            => _repository.SetServicePriceCommonDelete(arrOid);
    }
}