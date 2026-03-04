using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.SHome;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface ISHomeService
    {
        #region app-apartment-reg
        Task SetApartmentReg(BaseCtrlClient clt, HomApartmentReg reg);
        List<ProjectApp> GetProjects(string userId);
        List<HomBuilding> GetBuildings(string projectCd);
        List<HomFloor> GetFloorList(string buildingCd);
        List<HomRoom> GetRooms(string buildingCd, string floorNo);
        HomApartmentPageHome GetApartmentPageHome(string userId, string language);
        homApartmentPage GetApartmentList(string userId);
        Task SetApartmentMain(string userId, HomApartmentStatus main);
        homApartmentCartPage GetApartmentCarts(string userId);
        homApartmentCartDetail GetApartmentCartDetail(string userId, string language, string roomCd);
        PageFamilyMember GetPageFamilyMember(string userId, int? ApartmentId);
        Task<HomApartmentMemberGet> SetMemberProfile(string userId, HomMemberProfileSet profile);
        HomApartmentMemberGet GetFamilyMember(string userId, string custId, int apartmentId);
        Task<BaseValidate> DeleteFamilyMember(string userId, string custId, int apartmentId);
        PageFamilyCard GetPageFamilyCard(string userId, int? ApartmentId);
        HomCardService GetCardDetail(string cardCd);
        PageRequestFix GetPageRequest(FilterBaseApartment filter);
        PagePayment GetPagePayment(FilterBasePayment filter);
        HomPaymentGet GetPaymentDetail(string userId, long receiveId);
        PageHome GetPageHome(string userId);
        HomTransferInfo GetTransferInfo(string userId, long receiveId);

        #endregion app-apartment-reg

        #region web-apartment
        List<HomApartmentRelation> GetApartmentRations(string userId);
        Task<BaseValidate> SetFamilyMemberAuth(BaseCtrlClient clt, HomMemberBase customer);
        Task SetFamilyMemberReject(BaseCtrlClient clt, HomMemberBase customer);
        #endregion web-apartment

        #region web-card-reg
        IEnumerable<HomCardType> GetCardTypes();
        Task<long> SetCardRegister(string userId, HomCardRegSet cardSet);
        Task<BaseValidate> SetCardLost(string userId, HomCardBase card);

        #endregion web-card-reg
        
        #region web-vehicle-reg
        IEnumerable<HomVehicleType> GetVehicleTypes();
        Task<BaseValidate> SetCardServiceVehicle(string userId, HomServiceVehicleSet vehicle);
        #endregion web-vehicle-reg

        #region web-request-reg
       
        List<HomRequestCategoryGet> GetRequestCategoryList(string userId, int categoryType, string language);
        Task SetRequest(string userId, HomRequestSet request);
        Task SetRequestVoted(string userId, HomRequestVote request);
        Task SetRequestConfirm(string userId, HomRequestBase confirm);
        HomRequest GetRequest(string userId, long requestId);
        Task<HomRequestProcessGet> SetRequestProcess(string userId, HomRequestProcess process);
       
        #endregion web-request-reg

        #region web-s-service-reg

        List<CommonValue> GetBaseStatus(string userId, string baseKey);
        #endregion web-s-service-reg

        #region elevator-reg
        
        Task SetAccessFloor(BaseCtrlClient ctrlClient, HomAccessFloor floor);
        HomAccessGet GetAccessFloors(string userId, int mode);

        #endregion elevator-reg

        Wallet GetWallet(string userId);
        ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter);
        WalPointTran GetPointTransDetail(string userId, string transNo);

    }
}
