using UNI.Model;
using UNI.Model.Core;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using System.Data;

namespace UNI.Resident.DAL.Interfaces.Settings
{

    public interface IMetaImportRepository
    {
        Task<CommonDataPage> GetImportPageAsync(FilterBase flt, string import_type);
        Task<BaseValidate> DelImport(Guid impId);
    }
}
