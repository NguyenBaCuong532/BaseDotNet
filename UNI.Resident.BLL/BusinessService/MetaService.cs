using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Model.Face;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.DAL.Interfaces;

namespace UNI.Resident.BLL.BusinessService
{
    /// <summary>
    /// IProjectService
    /// <author>hoanpv</author>
    /// <date>2024/09/30</date>
    /// </summary>
    public class MetaService : IMetaService
    {
        private readonly IMetaRepository _metaRepository;
        private readonly IApiStorageService _storageService;
        //private readonly IApiFaceRecognitionService _faceService;
        private readonly ILogger<MetaService> _logger;

        public MetaService(IMetaRepository fileRepository,
            //IApiFaceRecognitionService faceService,
            IApiStorageService storageService,
            ILogger<MetaService> logger = null
        )
        {
            _metaRepository = fileRepository;
            _storageService = storageService;
            //_faceService = faceService;
            _logger = logger;
        }

        //public Task<CommonViewInfo> GetMetaFilter()
        //{
        //    return _metaRepository.GetMetaFilter();
        //}
        //public Task<CommonDataPage> GetMetaPage(FilterBase filter, string source_type, int? meta_type, string baseUrl)
        //{
        //    return _metaRepository.GetMetaPage(filter, source_type, meta_type, baseUrl);
        //}
        //public Task<BaseValidate> SetMetaInfo(CommonViewOidInfo File)
        //{
        //    return _metaRepository.SetMetaInfo(File);
        //}
        //public CommonViewOidInfo GetMetaInfo(Guid? Oid, Guid? parentOid, string source_type)
        //{
        //    return _metaRepository.GetMetaInfo(Oid, parentOid, source_type);
        //}
        public Task<BaseValidate> DelMetaInfo(string oids)
        {
            return _metaRepository.DelMetaInfo(oids);
        }

        //public List<nbMediaItem> GetMetaTrees(string source_type, Guid? parentOid, string filter)
        //{
        //    return _metaRepository.GetMetaTrees(source_type, parentOid, filter);
        //}
        //public Task<List<nbMediaItemTree>> GetMetaTreeNode(string source_type, Guid? parentOid, string filter)
        //{
        //    return _metaRepository.GetMetaTreeNode(source_type, parentOid, filter);
        //}
        public async Task<BaseValidate> SetMetaUpload(MediaFile info)
        {
            var file1 = await _storageService.UploadFile(info.formFile, info.source_type);
            return await _metaRepository.SetMetaUpload(info, file1);
        }

        public Task<List<FileStorageInfo>> GetMetaDetail(Guid? oid, Guid? parentOid)
        {
            return _metaRepository.GetMetaDetail(oid, parentOid);
        }

        //public async Task<BaseValidate> SetFaceUpload(MediaFile info)
        //{
        //    var file1 = await _storageService.UploadFile(info.formFile, info.source_type);
        //    var rs = await _metaRepository.SetMetaUpload(info, file1);
        //    var reg = new FaceRegRequest<hrmUserFace>
        //    {
        //        Id = rs.id,
        //        Img =
        //            $"data:{info.formFile.ContentType};{Utils.ConvertStreamToBase64(info.formFile.OpenReadStream())}",
        //        Payload = await _metaRepository.GetFaceProfile()
        //    };
        //    await _faceService.SetFaceRegister(reg);
        //    return rs;
        //}

        //public async Task<FaceFindResponse<hrmUserFace>> SetFaceFindAsync(IFormFile file)
        //{
        //    var face = new FaceFindRequest
        //    {
        //        Img =
        //            $"data:{file.ContentType};{Utils.ConvertStreamToBase64(file.OpenReadStream())}"
        //    };
        //    return await _faceService.SetFaceFind(face);
        //}

        //public Task<List<FileStorageInfo>> GetMetaFiles(string recordKey, Guid? groupFileId)
        //{
        //    return _metaRepository.GetMetaFiles(recordKey, groupFileId);
        //}

        //public Task<List<FileStorageInfo>> GetMetaProfiles(Guid? oid, Guid? groupFileId)
        //{
        //    return _metaRepository.GetMetaProfiles(oid, groupFileId);
        //}

        //public async Task<AttachmentResponse> SetMetaProfile(hrmCustMetaInfo info)
        //{
        //    var file1 = await _storageService.UploadFile(info.formFile, "profile");
        //    return await _metaRepository.SetMetaProfile(info, file1);
        //}

        //#region File Version
        //public Task<CommonViewInfo> GetMetaActiveFilter()
        //    => _metaRepository.GetMetaActiveFilter();

        //public Task<List<MetaActiveDicItemTree>> GetMetaActiveTreePage(Guid? oid)
        //    => _metaRepository.GetMetaActiveTreePage(oid);

        //public Task<MetaActivePage> GetMetaActivePage(Guid oid)
        //    => _metaRepository.GetMetaActivePage(oid);

        //public Task<List<object>> GetMetaTemplateConfigListForDropdown(Guid? parentOid, bool rootLevel = false)
        //    => _metaRepository.GetMetaTemplateConfigListForDropdown(parentOid, rootLevel);

        //public Task<CommonViewInfo> GetMetaActiveInfo(Guid? tempId, CommonViewInfo info = null)
        //    => _metaRepository.GetMetaActiveInfo(tempId, info);

        //public async Task<BaseValidate> SetMetaActiveInfo(CommonViewInfo info)
        //{
        //    var tempPath = info.GetValueByFieldName("temp_path");
        //    if (string.IsNullOrWhiteSpace(tempPath))
        //        return new BaseValidate { messages = "Vui lòng điền đường dẫn file mẫu" };
        //    if (!File.Exists(tempPath))
        //        return new BaseValidate { messages = "Đường dẫn không đúng hoặc file không tồn tại" };

        //    var fileExtension = Path.GetExtension(tempPath);

        //    return await _metaRepository.SetMetaActiveInfo(info, fileExtension);
        //}

        //public Task<BaseValidate> DelMetaActive(Guid tempId)
        //    => _metaRepository.DelMetaActive(tempId);

        //public async Task<BaseValidate<MetaActiveDownload>> MetaActiveDownload(Guid tempId)
        //{
        //    try
        //    {
        //        var reResultData = await _metaRepository.MetaActiveDownload(tempId);
        //        if (reResultData == null)
        //            throw new Exception("Không tìm thấy dữ liệu");

        //        var fileBytes = await ReadAllBytesAsync(reResultData.temp_driver_folder);
        //        return new BaseValidate<MetaActiveDownload>
        //        {
        //            valid = true,
        //            Data = new MetaActiveDownload
        //            {
        //                FileBytes = fileBytes,
        //                FileName = $"{(!string.IsNullOrWhiteSpace(reResultData.temp_file_name) ? reResultData.temp_file_name : DateTime.Now.ToString("yyyy.MM.dd_HH.mm.ss.fffff"))}.{reResultData.temp_file_type}"
        //            }
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        return new BaseValidate<MetaActiveDownload>
        //        {
        //            messages = ex.Message,
        //        };
        //    }
        //}


    }
}