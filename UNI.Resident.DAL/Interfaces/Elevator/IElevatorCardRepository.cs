using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Model.APPM.Notifications;
using UNI.Model.Firestore;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;
using UNI.Utils;

namespace UNI.Resident.DAL.Interfaces.Elevator
{
    public interface IElevatorCardRepository
    {
        #region elevator-reg
        Task<ElevatorCardInfo> GetElevatorCardsDraft(ElevatorCardInfo cardCode);
        Task<CommonViewInfo> GetElevatorCardFilter();
        Task<CommonDataPage> GetElevatorCardPage(FilterElevatorDevice filter);
        Task<BaseValidate> SetElevatorCardInfo(CommonViewIdInfo info);
        Task<BaseValidate> DelElevatorCardInfo(IEnumerable<Guid> oids); 
        Task<CommonViewIdInfo> GetElevatorCardInfo(string id, string projectCd);
        Task<CommonViewIdInfo> SetElevatorCardDraft(CommonViewIdInfo info);
        Task<List<CommonValue>> GetElevatorCards(string cardId, string filter);
        Task<ElevatorCardInfo> GetElevatorCardsInfo(string cardId);
        #endregion elevator-reg
    }
}
