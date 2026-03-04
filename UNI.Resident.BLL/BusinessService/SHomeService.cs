using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.SHome;

namespace UNI.Resident.BLL.BusinessService
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// 16/11/2016 1:57 PM
    /// <seealso cref="ISHomeRepository" />
    public class SHomeService : ISHomeService
    {
        private readonly ISHomeRepository _homeRepository;
        protected readonly ILogger _logger;
        public SHomeService(
            ISHomeRepository homeRepository,
            ILoggerFactory logger)
        {
            if (homeRepository != null)
                _homeRepository = homeRepository;
            _logger = logger.CreateLogger(GetType().Name);
        }
        #region app-apartment-reg
        public List<ProjectApp> GetProjects(string userId)
        {
            return _homeRepository.GetProjects(userId);
        }
        public Task SetApartmentReg(BaseCtrlClient clt, HomApartmentReg reg)
        {
            return _homeRepository.SetApartmentReg(clt, reg);
        }
        public HomApartmentPageHome GetApartmentPageHome(string userId, string language)
        {
            return _homeRepository.GetApartmentPageHome(userId, language);
        }
        public homApartmentPage GetApartmentList(string userId)
        {
            return _homeRepository.GetApartmentList(userId);
        }
        public Task SetApartmentMain(string userId, HomApartmentStatus main)
        {
            return _homeRepository.SetApartmentMain(userId, main);
        }
        public homApartmentCartPage GetApartmentCarts(string userId)
        {
            return _homeRepository.GetApartmentCart(userId);
        }
        public homApartmentCartDetail GetApartmentCartDetail(string userId, string language, string roomCd)
        {
            return _homeRepository.GetApartmentCartDetail(userId, language, roomCd);
        }
        public PageRequestFix GetPageRequest(FilterBaseApartment filter)
        {
            return _homeRepository.GetPageRequest(filter);
        }
        public PageFamilyMember GetPageFamilyMember(string userId, int? ApartmentId)
        {
            return _homeRepository.GetPageFamilyMember(userId, ApartmentId);
        }
        public PageFamilyCard GetPageFamilyCard(string userId, int? ApartmentId)
        {
            return _homeRepository.GetPageFamilyCard(userId, ApartmentId);
        }
        public PagePayment GetPagePayment(FilterBasePayment filter)
        {
            return _homeRepository.GetPagePayment(filter);
        }
        public HomPaymentGet GetPaymentDetail(string userId, long receiveId)
        {
            return _homeRepository.GetPaymentDetail(userId, receiveId);
        }
        public HomTransferInfo GetTransferInfo(string userId, long receiveId)
        {
            return _homeRepository.GetTransferInfo(userId, receiveId);
        }
        #endregion app-apartment-reg

        #region web-apartment
        
        public List<HomApartmentRelation> GetApartmentRations(string userId)
        {
            return _homeRepository.GetApartmentRations(userId);
        }
        public Task<HomApartmentMemberGet> SetMemberProfile(string userId, HomMemberProfileSet face)
        {
            return _homeRepository.SetMemberProfile(userId, face);
        }
        public Task<BaseValidate> SetFamilyMemberAuth(BaseCtrlClient clt, HomMemberBase customer)
        {
            return _homeRepository.SetFamilyMemberAuth(clt, customer);
        }
        public Task SetFamilyMemberReject(BaseCtrlClient clt, HomMemberBase customer)
        {
            return _homeRepository.SetFamilyMemberReject(clt, customer);
        }
        public HomApartmentMemberGet GetFamilyMember(string userId, string custId, int apartmentId)
        {
            return _homeRepository.GetFamilyMember(userId, custId, apartmentId);
        }
        public Task<BaseValidate> DeleteFamilyMember(string userId, string custId, int apartmentId)
        {
            return _homeRepository.DeleteFamilyMember(userId, custId, apartmentId);
        }
        
        #endregion web-apartment

        #region web-card-reg

        public HomCardService GetCardDetail(string cardCd)
        {
            return _homeRepository.GetCardDetail(cardCd);
        }
        
        public Task<BaseValidate> SetCardServiceVehicle(string userId, HomServiceVehicleSet vehicle)
        {
            return _homeRepository.SetCardServiceVehicle(userId, vehicle);
        }
        

        public Task<long> SetCardRegister(string userId, HomCardRegSet cardSet)
        {
            return _homeRepository.SetCardRegister(userId, cardSet);
        }
        public Task<BaseValidate> SetCardLost(string userId, HomCardBase card)
        {
            return _homeRepository.SetCardLost(userId, card);
        }
        
        #endregion web-card-reg

        #region web-request-reg
       
        public List<HomRequestCategoryGet> GetRequestCategoryList(string userId, int categoryType, string language)
        {
            return _homeRepository.GetRequestCategoryList(userId, categoryType, language);
        }
        
        public Task SetRequest(string userId, HomRequestSet request)
        {
            return _homeRepository.SetRequest(userId, request);
        }
        public Task SetRequestVoted(string userId, HomRequestVote request)
        {
            return _homeRepository.SetRequestVoted(userId, request);
        }
        public Task SetRequestConfirm(string userId, HomRequestBase confirm)
        {
            return _homeRepository.SetRequestConfirm(userId, confirm);
        }
        public HomRequest GetRequest(string userId, long requestId)
        {
            return _homeRepository.GetRequest(userId, requestId);
        }
        
        public Task<HomRequestProcessGet> SetRequestProcess(string userId, HomRequestProcess chat)
        {
            return _homeRepository.SetRequestProcess(userId, chat);
        }
        
        #endregion web-request-reg

        #region web-vehicle-reg
        public IEnumerable<HomVehicleType> GetVehicleTypes()
        {
            return _homeRepository.GetVehicleTypes();
        }


        #endregion web-vehicle-reg

       
        public IEnumerable<HomCardType> GetCardTypes()
        {
            return _homeRepository.GetCardTypes();
        }

        public List<CommonValue> GetBaseStatus(string userId, string baseKey)
        {
            return _homeRepository.GetBaseStatus(userId, baseKey);
        }

        public PageHome GetPageHome(string userId)
        {
            return _homeRepository.GetPageHome(userId);
        }

        public List<HomBuilding> GetBuildings(string projectCd)
        {
            return _homeRepository.GetBuildings(projectCd);
        }
        public List<HomFloor> GetFloorList(string buildingCd)
        {
            return _homeRepository.GetFloorList(buildingCd);
        }
        public List<HomRoom> GetRooms(string buildingCd, string floorNo)
        {
            return _homeRepository.GetRooms(buildingCd, floorNo);
        }
        
        #region elevator-reg
        
        public Task SetAccessFloor(BaseCtrlClient clt, HomAccessFloor floor)
        {
            return _homeRepository.SetAccessFloor(clt, floor);
        }
        public HomAccessGet GetAccessFloors(string userId, int mode)
        {
            return _homeRepository.GetAccessFloors(userId, mode);
        }
        #endregion elevator-reg

        public Wallet GetWallet(string userId)
        {
            return _homeRepository.GetWallet(userId);
        }
        public ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter)
        {
            return _homeRepository.GetPointTransHistoryList(filter);
        }
        public WalPointTran GetPointTransDetail(string userId, string transNo)
        {
            return _homeRepository.GetPointTransDetail(userId, transNo);
        }
    }
}
