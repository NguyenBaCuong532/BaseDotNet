using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Advertisement;
using UNI.Resident.DAL.Interfaces.Advertisement;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.BLL.BusinessService.Advertisement
{
    public class AdvertisementService : IAdvertisementService
    {
        private readonly IAdvertisementRepository _advertisementRepository;

        public AdvertisementService(IAdvertisementRepository advertisementRepository)
        {
            _advertisementRepository = advertisementRepository ?? throw new ArgumentNullException(nameof(advertisementRepository));
        }

        // CMS Pattern APIs
        public async Task<CommonViewInfo> GetFilter(string filterName)
        {
            return await _advertisementRepository.GetFilter(filterName);
        }

        public async Task<List<AdvertisementInfo>> GetPage(AdvertisementFilter filter)
        {
            return await _advertisementRepository.GetPage(filter);
        }

        public async Task<AdvertisementInfo> GetInfo(Guid id)
        {
            return await _advertisementRepository.GetInfo(id);
        }

        public async Task<BaseValidate> SetInfo(AdvertisementCreateDto dto, string userId)
        {
            if (!Guid.TryParse(userId, out var userGuid))
            {
                return new BaseValidate { valid = false, messages = "Invalid user ID format" };
            }

            var validation = ValidateAdvertisementDto(dto);
            if (!validation.valid)
            {
                return validation;
            }

            return await _advertisementRepository.SetInfo(dto, userGuid);
        }

        public async Task<BaseValidate> SetInfo(AdvertisementUpdateDto dto, string userId)
        {
            if (!Guid.TryParse(userId, out var userGuid))
            {
                return new BaseValidate { valid = false, messages = "Invalid user ID format" };
            }

            var validation = ValidateAdvertisementDto(dto);
            if (!validation.valid)
            {
                return validation;
            }

            // Check if advertisement exists
            var existingAd = await _advertisementRepository.GetInfo(dto.Id);
            if (existingAd == null)
            {
                return new BaseValidate { valid = false, messages = "Advertisement not found" };
            }

            return await _advertisementRepository.SetInfo(dto, userGuid);
        }

        public async Task<BaseValidate> DelInfo(Guid id, string userId)
        {
            if (!Guid.TryParse(userId, out var userGuid))
            {
                return new BaseValidate { valid = false, messages = "Invalid user ID format" };
            }

            // Check if advertisement exists
            var existingAd = await _advertisementRepository.GetInfo(id);
            if (existingAd == null)
            {
                return new BaseValidate { valid = false, messages = "Advertisement not found" };
            }

            return await _advertisementRepository.DelInfo(id, userGuid);
        }

        // Additional methods for statistics
        public async Task<List<AdvertisementStatsDto>> GetAdvertisementStats(DateTime? fromDate, DateTime? toDate)
        {
            return await _advertisementRepository.GetAdvertisementStats(fromDate, toDate);
        }

        private BaseValidate ValidateAdvertisementDto(AdvertisementCreateDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
            {
                return new BaseValidate { valid = false, messages = "Title is required" };
            }

            if (string.IsNullOrWhiteSpace(dto.ImageUrl))
            {
                return new BaseValidate { valid = false, messages = "Image URL is required" };
            }

            if (dto.StartDate >= dto.EndDate)
            {
                return new BaseValidate { valid = false, messages = "Start date must be before end date" };
            }

            if (dto.StartDate < DateTime.Now.Date)
            {
                return new BaseValidate { valid = false, messages = "Start date cannot be in the past" };
            }

            return new BaseValidate { valid = true };
        }
    }
}