using UNI.Model;
using UNI.Model.Core;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using System.IO;

namespace UNI.Resident.BLL.BusinessInterfaces.Settings
{
    /// <summary>
    /// IWorktimeService
    /// </summary>
    public interface IMetaImportService
    {
        Task<CommonDataPage> GetImportPageAsync(FilterBase flt, string import_type);
        Task<BaseValidate> DelImport(Guid impId);
        Task<byte[]> GetFileTemplateAsync(string fileName);
    }
}
