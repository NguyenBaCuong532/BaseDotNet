using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Resident;
using UNI.Resident.Model.SHome;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces
{
    public interface ISHomeRepository
    {
        #region app-apartment-reg
        Task SetApartmentReg(BaseCtrlClient clt, HomApartmentReg reg);
        List<HomBuilding> GetBuildings(string projectCd);
        List<HomFloor> GetFloorList(string buildingCd);
        List<HomRoom> GetRooms(string buildingCd, string floorNo);
        HomApartmentPageHome GetApartmentPageHome(string userId, string language);
        homApartmentPage GetApartmentList(string userId);
        Task SetApartmentMain(string userId, HomApartmentStatus main);
        homApartmentCartPage GetApartmentCart(string userId);
        homApartmentCartDetail GetApartmentCartDetail(string userId, string language, string roomCd);
        PageRequestFix GetPageRequest(FilterBaseApartment filter);
        PageFamilyMember GetPageFamilyMember(string userId, int? ApartmentId);
        PageFamilyCard GetPageFamilyCard(string userId, int? ApartmentId);
        List<HomServiceVehicleGet> GetPageServiceVehicles(string userId, int? ApartmentId);
        PagePayment GetPagePayment(FilterBasePayment filter);
        HomPaymentGet GetPaymentDetail(string userId, long receiveId);
        HomTransferInfo GetTransferInfo(string userId, long receiveId);

        #endregion app-apartment-reg

        #region web-apartment
      
        List<HomApartmentRelation> GetApartmentRations(string userId);
        Task<HomApartmentMemberGet> SetMemberProfile(string userId, HomMemberProfileSet face);
        Task<BaseValidate> DeleteFamilyMember(string userId, string custId, int apartmentId);
        HomApartmentMemberGet GetFamilyMember(string userId, string custId, int apartmentId);
        
        Task<BaseValidate> SetFamilyMemberAuth(BaseCtrlClient clt, HomMemberBase customer);
        Task SetFamilyMemberReject(BaseCtrlClient clt, HomMemberBase customer);
       
        #endregion web-apartment

        #region web-card-reg
        //Task<int> SetCardBase(CardBase card);
        HomCardService GetCardDetail(string cardCd);
        Task<BaseValidate> SetCardServiceVehicle(string userId, HomServiceVehicleSet vehicle);
        Task<long> SetCardRegister(string userId, HomCardRegSet cardSet);
        Task<BaseValidate> SetCardLost(string userId, HomCardBase card);
        List<HomCardType> GetCardTypes();
        
        #endregion card-reg

        #region web-vehicle
        List<HomVehicleType> GetVehicleTypes();
        
        #endregion web-vehicle

        #region web-request-reg
        List<HomRequestCategoryGet> GetRequestCategoryList(string userId, int categoryType, string language);
        Task SetRequest(string userId, HomRequestSet request);
        Task SetRequestVoted(string userId, HomRequestVote request);
        Task SetRequestConfirm(string userId, HomRequestBase confirm);
        HomRequest GetRequest(string userId, long requestId);
        Task<HomRequestProcessGet> SetRequestProcess(string userId, HomRequestProcess process);
        HomRequestFixGet GetRequestFix(string userId, string fixId);
        #endregion web-request-reg

        #region web-free-service
        
        #endregion web-free-service
        List<CommonValue> GetBaseStatus(string userId, string baseKey);        
        PageHome GetPageHome(string userId);
       
        List<ProjectApp> GetProjects(string userId);
       
        #region elevator-reg
        
        Task SetAccessFloor(BaseCtrlClient ctrlClient, HomAccessFloor floor);
        HomAccessGet GetAccessFloors(string userId, int mode);
        #endregion elevator-reg

        Wallet GetWallet(string userId);
        ResponseList<List<WalPointTran>> GetPointTransHistoryList(FilterBase filter);
        WalPointTran GetPointTransDetail(string userId, string transNo);
    }
}
