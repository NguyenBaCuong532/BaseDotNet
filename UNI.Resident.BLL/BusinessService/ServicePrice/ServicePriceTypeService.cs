using Microsoft.AspNetCore.Mvc;
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
    /// Cấu hình giá dịch vụ - Loại giá dịch vụ: sinh hoạt, kinh doanh..
    /// </summary>
    public class ServicePriceTypeService : UniBaseService, IServicePriceTypeService
    {
        private readonly IServicePriceTypeRepository _repository;

        public ServicePriceTypeService(IServicePriceTypeRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Danh sách cho Dropdown Control
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<List<CommonValue>> GetServicePriceTypeForDropdownList(string filter)
            => _repository.GetServicePriceTypeForDropdownList(filter);
    }
}