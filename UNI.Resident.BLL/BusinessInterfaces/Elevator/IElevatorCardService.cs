using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Common;
using UNI.Model;
using UNI.Resident.Model;
using UNI.Resident.Model.Common;
using UNI.Resident.Model.Elevator;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessInterfaces.Elevator
{
    /// <summary>
    /// SHome Service
    /// </summary>
    /// Author: duongpx
    /// CreatedDate: 27/07/2017 2:01 PM
    public interface IElevatorCardService
    {

        #region elevator-reg
        Task<ElevatorCardInfo> GetElevatorCardsDraft(ElevatorCardInfo draft);
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
