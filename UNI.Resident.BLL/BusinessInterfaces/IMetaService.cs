using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Face;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    /// <summary>
    /// IFileService
    /// <author>hoanpv</author>
    /// <date>2024-09-30</date>
    /// </summary>
    public interface IMetaService
    {
        //Task<CommonViewInfo> GetMetaFilter();
        //Task<CommonListPage> GetMetaPage(FilterBase filter, string source_type, int? meta_type1, string baseUrl);
        //Task<BaseValidate> SetMetaInfo(CommonViewOidInfo file);
        //CommonViewOidInfo GetMetaInfo(Guid? Oid, Guid? parentOid, string source_type);
        Task<BaseValidate> DelMetaInfo(string oid);
        //List<nbMediaItem> GetMetaTrees(string source_type, Guid? parentOid, string filter);
        //Task<List<nbMediaItemTree>> GetMetaTreeNode(string source_type, Guid? parentOid, string filter);
        Task<BaseValidate> SetMetaUpload(MediaFile info);
        Task<List<FileStorageInfo>> GetMetaDetail(Guid? oid, Guid? parentOid);
        //Task<BaseValidate> SetFaceUpload(MediaFile info);
        //Task<FaceFindResponse<hrmUserFace>> SetFaceFindAsync(IFormFile file);
        //Task<List<FileStorageInfo>> GetMetaFiles(string recordKey, Guid? groupFileId);
        //Task<List<FileStorageInfo>> GetMetaProfiles(Guid? oid, Guid? groupFileId);
        //Task<AttachmentResponse> SetMetaProfile(hrmCustMetaInfo attach);

        ///// <summary>
        ///// Hàm lấy ra file template báo cáo, template import, theo version mới nhất và theo tổ chức <br />
        ///// step1. Truy cập vào db để lấy ra thông tin file template custom <br />
        ///// step2. Nếu có lưu thông tin file custom thì dùng <see cref="SSG.HRM.BLL.BusinessServiceInterfaces.Api.IApiStorageService" /> download về local <br />
        ///// step3. Nếu không lưu custom thì thực hiện đọc từ local file trên đường dẫn đã được cấu hình (giống như code cũ)
        ///// </summary>
        ///// <param name="path">Đường dẫn file ở localserver</param>
        ///// <param name="autoCreate">Tự động upload file ở local lên storage service và tạo 1 bản ghi version mới xuống DB</param>
        ///// <returns></returns>
        //Task<byte[]> ReadAllBytesAsync(string path);

    }
}