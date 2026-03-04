using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.Model.Card;

namespace UNI.Resident.BLL.BusinessInterfaces.Card
{
    public interface ICardBaseService
    {
        Task<CommonDataPage> GetCardBasePage(FilterBase filter, long startNum, long endNum, bool status);
        Task<BaseValidate> SetBaseClassify(CardClassificationInfo info);
        Task<CardClassificationInfo> GetClassifyInfo(Guid? id);
        Task<BaseValidate> DeleteCardBase(string id);
        // import ds thẻ trong QL kho thẻ
        Task<BaseValidate<Stream>> GetCardBaseImportTemp();
        Task<ImportListPage> SetCardBaseImportAsync(CardImportSet cards);
        Task<List<CommonValue>> GetCardBaseList(string projectCd, Guid? oid, string filter);
        CommonViewInfo GetCardBaseFilter(string userId);
    }
}
