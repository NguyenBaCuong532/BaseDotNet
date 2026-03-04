using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.DAL.Interfaces
{

    public interface IMetaRepository
    {
        //Task<CommonViewInfo> GetMetaFilter();
        Task<CommonDataPage> GetMetaPage(FilterBase filter, string source_type, int? meta_type, string baseUrl);
        Task<CommonViewOidInfo> GetMetaInfo(Guid? oid, Guid? parentOid, string source_type);
        Task<BaseValidate> SetMetaInfo(CommonViewOidInfo info);
        Task<BaseValidate> DelMetaInfo(string Oids);
        //Task<List<nbMediaItem>> GetMetaTrees(string source_type, Guid? parentOid, string filter);
        //Task<List<nbMediaItemTree>> GetMetaTreeNode(string source_type, Guid? parentOid, string filter);
        Task<BaseValidate> SetMetaUpload(MediaFile info, UploadResponse filePath);
        Task<List<CommonValue>> GetFileList(string source_type, int meta_type, Guid sourceOid);
        Task<List<FileStorageInfo>> GetMetaDetail(Guid? oid, Guid? parentOid);
    }
}