using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces.Advertisement;
using UNI.Resident.Model.Advertisement;

namespace UNI.Resident.API.Controllers.Version2.Advertisement
{
    /// <summary>
    /// Advertisement Management Controller for CMS - Provides CRUD operations for advertisement management
    /// Following CMS Pattern: GetFilter, GetPage, GetInfo, SetInfo, DelInfo
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]/[action]")]
    [Authorize]
    public class AdvertisementController : UniController
    {
        private readonly IAdvertisementService _advertisementService;
        private readonly IAdvertisementAnalyticsService _analyticsService;

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="advertisementService"></param>
        /// <param name="analyticsService"></param>
        public AdvertisementController(
            IAdvertisementService advertisementService,
            IAdvertisementAnalyticsService analyticsService)
        {
            _advertisementService = advertisementService;
            _analyticsService = analyticsService;
        }

        #region Advertisement CMS APIs

        /// <summary>
        /// Get filter configuration for Advertisement management
        /// </summary>
        /// <param name="filterName">Filter name (e.g., "advertisement")</param>
        /// <returns>Filter configuration</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetFilter([FromQuery] string filterName = "advertisement")
        {
            try
            {
                var filter = await _advertisementService.GetFilter(filterName);
                return GetResponse(ApiResult.Success, filter);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<CommonViewInfo>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get paginated list of advertisements with filtering
        /// </summary>
        /// <param name="filter">Filter parameters</param>
        /// <returns>List of advertisements</returns>
        [HttpPost]
        public async Task<BaseResponse<List<AdvertisementInfo>>> GetPage([FromBody] AdvertisementFilter filter)
        {
            try
            {
                var advertisements = await _advertisementService.GetPage(filter);
                return GetResponse(ApiResult.Success, advertisements);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<List<AdvertisementInfo>>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get advertisement details by ID
        /// </summary>
        /// <param name="id">Advertisement ID</param>
        /// <returns>Advertisement details</returns>
        [HttpGet("{id}")]
        public async Task<BaseResponse<AdvertisementInfo>> GetInfo(Guid id)
        {
            try
            {
                var advertisement = await _advertisementService.GetInfo(id);
                if (advertisement == null)
                {
                    return GetErrorResponse<AdvertisementInfo>(ApiResult.NotFound,2, "Advertisement not found");
                }

                return GetResponse(ApiResult.Success, advertisement);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<AdvertisementInfo>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Create or update advertisement
        /// </summary>
        /// <param name="dto">Advertisement data (AdvertisementCreateDto for new, AdvertisementUpdateDto for update)</param>
        /// <returns>Validation result</returns>
        [HttpPost]
        public async Task<BaseResponse<BaseValidate>> SetInfo([FromBody] object dto)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Unauthorized,2, "User not authenticated");
                }

                BaseValidate result;

                // Check if this is an update (has Id property) or create (no Id)
                if (dto is AdvertisementUpdateDto updateDto && updateDto.Id != Guid.Empty)
                {
                    result = await _advertisementService.SetInfo(updateDto, userId);
                }
                else if (dto is AdvertisementCreateDto createDto)
                {
                    result = await _advertisementService.SetInfo(createDto, userId);
                }
                else
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Invalid, 2, "Invalid advertisement data");
                }

                if (result.valid)
                {
                    return GetResponse(ApiResult.Success, result);
                }
                else
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, result.messages);
                }
            }
            catch (Exception ex)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Delete advertisement (soft delete)
        /// </summary>
        /// <param name="id">Advertisement ID</param>
        /// <returns>Validation result</returns>
        [HttpDelete("{id}")]
        public async Task<BaseResponse<BaseValidate>> DelInfo(Guid id)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Unauthorized, 2, "User not authenticated");
                }

                var result = await _advertisementService.DelInfo(id, userId);

                if (result.valid)
                {
                    return GetResponse(ApiResult.Success, result);
                }
                else
                {
                    return GetErrorResponse<BaseValidate>(ApiResult.Invalid, 2, result.messages);
                }
            }
            catch (Exception ex)
            {
                return GetErrorResponse<BaseValidate>(ApiResult.Error, 2, ex.Message);
            }
        }

        #endregion

        #region Advertisement Analytics CMS APIs

        /// <summary>
        /// Get filter configuration for Advertisement Analytics
        /// </summary>
        /// <param name="filterName">Filter name (e.g., "advertisement_analytics")</param>
        /// <returns>Filter configuration</returns>
        [HttpGet]
        public async Task<BaseResponse<CommonViewInfo>> GetAnalyticsFilter([FromQuery] string filterName = "advertisement_analytics")
        {
            try
            {
                var filter = await _analyticsService.GetFilter(filterName);
                return GetResponse(ApiResult.Success, filter);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<CommonViewInfo>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get paginated list of advertisement analytics with filtering
        /// </summary>
        /// <param name="filter">Filter parameters</param>
        /// <returns>List of analytics</returns>
        [HttpPost]
        public async Task<BaseResponse<List<AdvertisementAnalytics>>> GetAnalyticsPage([FromBody] AdvertisementAnalyticsFilter filter)
        {
            try
            {
                var analytics = await _analyticsService.GetPage(filter);
                return GetResponse(ApiResult.Success, analytics);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<List<AdvertisementAnalytics>>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get analytics details by ID
        /// </summary>
        /// <param name="id">Analytics ID</param>
        /// <returns>Analytics details</returns>
        [HttpGet("{id}")]
        public async Task<BaseResponse<AdvertisementAnalytics>> GetAnalyticsInfo(Guid id)
        {
            try
            {
                var analytics = await _analyticsService.GetInfo(id);
                if (analytics == null)
                {
                    return GetErrorResponse<AdvertisementAnalytics>(ApiResult.NotFound, 2, "Analytics record not found");
                }

                return GetResponse(ApiResult.Success, analytics);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<AdvertisementAnalytics>(ApiResult.Error, 2, ex.Message);
            }
        }

        #endregion

        #region Additional Analytics Reports

        /// <summary>
        /// Get advertisement statistics
        /// </summary>
        /// <param name="fromDate">Start date (optional)</param>
        /// <param name="toDate">End date (optional)</param>
        /// <returns>Advertisement statistics</returns>
        [HttpGet]
        public async Task<BaseResponse<List<AdvertisementStatsDto>>> GetStats([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            try
            {
                var result = await _advertisementService.GetAdvertisementStats(fromDate, toDate);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<List<AdvertisementStatsDto>>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get analytics breakdown by action (View/Click)
        /// </summary>
        /// <param name="advertisementId">Advertisement ID</param>
        /// <param name="fromDate">Start date (optional)</param>
        /// <param name="toDate">End date (optional)</param>
        /// <returns>Analytics breakdown by action</returns>
        [HttpGet("{advertisementId}")]
        public async Task<BaseResponse<Dictionary<string, int>>> GetAnalyticsByAction(Guid advertisementId, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            try
            {
                var result = await _analyticsService.GetAnalyticsByAction(advertisementId, fromDate, toDate);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<Dictionary<string, int>>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get analytics breakdown by device type
        /// </summary>
        /// <param name="advertisementId">Advertisement ID</param>
        /// <param name="fromDate">Start date (optional)</param>
        /// <param name="toDate">End date (optional)</param>
        /// <returns>Analytics breakdown by device type</returns>
        [HttpGet("{advertisementId}")]
        public async Task<BaseResponse<Dictionary<string, int>>> GetAnalyticsByDevice(Guid advertisementId, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            try
            {
                var result = await _analyticsService.GetAnalyticsByDeviceType(advertisementId, fromDate, toDate);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<Dictionary<string, int>>(ApiResult.Error,2, ex.Message);
            }
        }

        /// <summary>
        /// Get analytics breakdown by platform
        /// </summary>
        /// <param name="advertisementId">Advertisement ID</param>
        /// <param name="fromDate">Start date (optional)</param>
        /// <param name="toDate">End date (optional)</param>
        /// <returns>Analytics breakdown by platform</returns>
        [HttpGet("{advertisementId}")]
        public async Task<BaseResponse<Dictionary<string, int>>> GetAnalyticsByPlatform(Guid advertisementId, [FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            try
            {
                var result = await _analyticsService.GetAnalyticsByPlatform(advertisementId, fromDate, toDate);
                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<Dictionary<string, int>>(ApiResult.Error, 2, ex.Message);
            }
        }

        /// <summary>
        /// Get daily analytics for an advertisement
        /// </summary>
        /// <param name="advertisementId">Advertisement ID</param>
        /// <param name="fromDate">Start date</param>
        /// <param name="toDate">End date</param>
        /// <returns>Daily analytics data</returns>
        [HttpGet("{advertisementId}")]
        public async Task<BaseResponse<List<AdvertisementAnalytics>>> GetDailyAnalytics(Guid advertisementId, [FromQuery] DateTime fromDate, [FromQuery] DateTime toDate)
        {
            try
            {
                var result = await _analyticsService.GetDailyAnalytics(advertisementId, fromDate, toDate);
                return GetResponse(ApiResult.Success, result);
            }
            catch (ArgumentException ex)
            {
                return GetErrorResponse<List<AdvertisementAnalytics>>(ApiResult.Invalid, 2, ex.Message);
            }
            catch (Exception ex)
            {
                return GetErrorResponse<List<AdvertisementAnalytics>>(ApiResult.Error, 2, ex.Message);
            }
        }

        #endregion

        /// <summary>
        /// Get user ID from JWT claims
        /// </summary>
        /// <returns>User ID string</returns>
        private string GetUserId()
        {
            // Get user ID from JWT token claims
            // This implementation may vary based on your authentication setup
            return User?.Identity?.Name ?? User?.FindFirst("sub")?.Value;
        }
    }
}