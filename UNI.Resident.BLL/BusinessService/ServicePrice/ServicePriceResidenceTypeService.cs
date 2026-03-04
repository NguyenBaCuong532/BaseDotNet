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
    /// Các loại hình căn hộ
    /// </summary>
    public class ServicePriceResidenceTypeService : UniBaseService, IServicePriceResidenceTypeService
    {
        private readonly IServicePriceResidenceTypeRepository _repository;

        public ServicePriceResidenceTypeService(IServicePriceResidenceTypeRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<List<CommonValue>> GetServicePriceResidenceTypeNameValue(string filter)
            => _repository.GetServicePriceResidenceTypeNameValue(filter);
    }
}