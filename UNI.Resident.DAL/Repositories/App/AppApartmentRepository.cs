using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.App;
using UNI.Resident.DAL.Interfaces.Notify;
using UNI.Resident.Model;
using UNI.Utils;

namespace UNI.Resident.DAL.Repositories.App
{
    /// <summary>
    /// Home Repository
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:07 PM
    /// <seealso cref="ISHomeRepository" />
    public class AppApartmentRepository : UniBaseRepository, IAppApartmentRepository
    {
        protected ILogger<AppApartmentRepository> _logger;
        private IHostingEnvironment _environment;
        private FlexcellUtils flexcellUtils;
        private readonly IFirebaseRepository _notifyRepository;
        private readonly INotifyRepository _appRepository;

        public AppApartmentRepository(IUniCommonBaseRepository common,
            IConfiguration configuration,
            ILogger<AppApartmentRepository> logger,
            IFirebaseRepository notifyRepository,
            INotifyRepository appRepository,
            IHostingEnvironment environment) : base(common)
        {
            _notifyRepository = notifyRepository;
            _appRepository = appRepository;
            _environment = environment;
            _logger = logger;
            flexcellUtils = new FlexcellUtils();
        }
        #region app-apartment-reg
        public async Task SetApartmentRegAsync(string userId, HomApartmentReg reg)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Reg";
            var result = await GetMultipleAsync<BaseValidate>(storedProcedure, new { userId, reg.roomCode, reg.contractNo, reg.relationId, reg.id }, async reader =>
            {
                var valid = await reader.ReadFirstOrDefaultAsync<BaseValidate>();
                if (valid != null && valid.notiQue)
                {
                    var notiTake = await reader.ReadFirstOrDefaultAsync<AppNotifyTake>();
                    if (notiTake != null)
                    {
                        notiTake.appUsers = (await reader.ReadAsync<PushNotifyUser>()).ToList();
                        await _appRepository.TakeNotification(notiTake);
                    }
                }
                return valid;
            });
        }
        public async Task<HomApartmentPageHome> GetApartmentPageHomeAsync(string language)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Home";
            return await GetMultipleAsync<HomApartmentPageHome>(storedProcedure, new { language }, async reader =>
            {
                var data = await reader.ReadFirstOrDefaultAsync<HomApartmentPageHome>();
                if (data != null)
                {
                    data.Profile = await reader.ReadFirstOrDefaultAsync<HomFamilyProfile>();
                    data.registed = await reader.ReadFirstOrDefaultAsync<HomApartmentRegGet>();
                }
                return data;
            });
        }
        public async Task<homApartmentPage> GetApartmentListAsync(string userId)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Page";
            var apartments = await GetListAsync<homApartmentShort>(storedProcedure, new { userId });
            return new homApartmentPage { apartments = apartments };
        }
        public async Task SetApartmentMainAsync(HomApartmentStatus main)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Main_Set";
            await SetAsync(storedProcedure, new { main.ApartmentId });
        }
        public async Task<homApartmentCartPage> GetApartmentCartAsync(string userId)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Cart_List";
            var apartments = await GetListAsync<homApartmentCart>(storedProcedure, new { userId });
            return new homApartmentCartPage { apartments = apartments };
        }
        public async Task<homApartmentCartDetail> GetApartmentCartDetailAsync(string language, string roomCd)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Cart_Get";
            return await GetMultipleAsync<homApartmentCartDetail>(storedProcedure, new { roomCd, language }, async reader =>
            {
                var data = await reader.ReadFirstOrDefaultAsync<homApartmentCartDetail>();
                if (data != null)
                {
                    data.contract = await reader.ReadFirstOrDefaultAsync<homContractShort>();
                    data.payments = (await reader.ReadAsync<SchedulePay>()).ToList();
                }
                return data;
            });
        }
        public async Task<HomApartmentMemberGet> SetMemberProfileAsync(HomMemberProfileSet face)
        {
            const string storedProcedure = "sp_Hom_App_Apartment_Member_Set";
            return await GetFirstOrDefaultAsync<HomApartmentMemberGet>(storedProcedure, new
            {
                //userId,
                face.CustId,
                face.FaceId,
                face.AvatarUrl,
                face.FullName,
                face.Phone,
                face.Email,
                face.Address,
                face.Sex,
                face.Birthday,
                face.FaceRecogUrl1,
                face.FaceRecogUrl2,
                face.FaceRecogUrl3,
                face.FaceRecogUrl4,
                face.FaceRecogUrl5,
                ApartmentId = 0,
                face.RelationId
            });
        }
        public async Task<PageFamilyMember> GetPageFamilyMemberAsync(int? ApartmentId)
        {
            const string storedProcedure = "sp_Hom_App_FamilyMember_ByUserId";
            var members = await GetListAsync<HomApartmentMemberGet>(storedProcedure, new { ApartmentId });
            return new PageFamilyMember { Members = members };
        }
        //public async Task<HomApartmentPage> GetApartmentPageAsync(FilterBaseApartments filter)
        //{
        //    const string storedProcedure = "sp_Hom_Apartment_Page";
        //    return await GetMultipleAsync<HomApartmentPage>(storedProcedure, filter, async reader =>
        //    {
        //        var data = await reader.ReadFirstOrDefaultAsync<HomApartmentPage>();
        //        if (data != null)
        //        {
        //            data.apartments = (await reader.ReadAsync<homApartmentShort>()).ToList();
        //        }
        //        return data;
        //    });
        //}
        //public async Task<HomApartmentInfo> GetApartmentInfoAsync(long apartmentId)
        //{
        //    const string storedProcedure = "sp_Hou_Apartment_Fields";
        //    return await GetFirstOrDefaultAsync<HomApartmentInfo>(storedProcedure, new { apartmentId });
        //}
        public async Task<List<HomApartmentRelation>> GetApartmentRationsAsync(string userId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Relation_List";
            return await GetListAsync<HomApartmentRelation>(storedProcedure, new { userId });
        }
        //public async Task<BaseValidate> SetFamilyMemberAsync(HomApartmentMemberSet customer)
        //{
        //    const string storedProcedure = "sp_Hom_Apartment_Member_Set";
        //    return await GetFirstOrDefaultAsync<BaseValidate>(storedProcedure, customer);
        //}
        public async Task<BaseValidate> SetFamilyMemberAuthAsync(HomMemberBase customer)
        {
            const string storedProcedure = "sp_res_apartment_home_member_approve";
            return await GetMultipleAsync<BaseValidate>(storedProcedure, new { customer.apartmentId, customer.custId, memberUserId = customer.userId }
             , async reader =>
            {
                var valid = await reader.ReadFirstOrDefaultAsync<BaseValidate>();
                if (valid != null && valid.notiQue)
                {
                    var notiTake = await reader.ReadFirstOrDefaultAsync<AppNotifyTake>();
                    if (notiTake != null)
                    {
                        notiTake.appUsers = (await reader.ReadAsync<PushNotifyUser>()).ToList();
                        await _appRepository.TakeNotification(notiTake);
                    }
                }
                return valid;
            });
        }
        public async Task SetFamilyMemberRejectAsync(HomMemberBase customer)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_Reject";
            await SetAsync(storedProcedure, new { customer.apartmentId, customer.custId, memberUserId = customer.userId });
        }
        public async Task<HomApartmentMemberGet> GetFamilyMemberAsync(string custId, int apartmentId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_ByCustId";
            return await GetFirstOrDefaultAsync<HomApartmentMemberGet>(storedProcedure, new { custId, apartmentId });
        }
        public async Task<BaseValidate> DeleteFamilyMemberAsync(string custId, int apartmentId)
        {
            const string storedProcedure = "sp_Hom_Apartment_Member_Del";
            return await DeleteAsync(storedProcedure, new { custId, apartmentId });
        }
        #endregion
    }
}
