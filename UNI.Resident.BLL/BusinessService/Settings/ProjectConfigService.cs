using Aspose.Pdf.Operators;
using DocumentFormat.OpenXml.EMMA;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Minio.DataModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UNI.Common.CommonBase;
using UNI.Model;
using UNI.Model.Api;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Resident.BLL.BusinessInterfaces.Settings;
using UNI.Resident.DAL.Interfaces;
using UNI.Resident.DAL.Interfaces.Settings;
using UNI.Resident.Model.Project;
using UNI.Resident.Model.Resident;

namespace UNI.Resident.BLL.BusinessService.Settings
{
    /// <summary>
    /// Cấu hình chung cho dự án
    /// </summary>
    public class ProjectConfigService : UniBaseService, IProjectConfigService
    {
        private readonly IProjectConfigRepository _repository;
        private readonly IMetaService _metaService;
        private readonly IMetaRepository _metaRepository;
        private readonly IApiStorageService _storageService;
        private readonly IHostingEnvironment _environment;

        public ProjectConfigService(IProjectConfigRepository repository,
            IApiStorageService storageService, IMetaService metaService,
            IMetaRepository metaRepository, IHostingEnvironment environment)
        {
            _repository = repository;
            _storageService = storageService;
            _metaService = metaService;
            _metaRepository = metaRepository;
            _environment = environment;
        }

        /// <summary>
        /// Control tìm kiếm nâng cao danh sách phân trang
        /// </summary>
        /// <returns></returns>
        public Task<CommonViewInfo> GetProjectConfigFilter()
            => _repository.GetProjectConfigFilter();

        /// <summary>
        /// Danh sách dữ liệu phân trang hiển thị ở lưới
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public Task<CommonDataPage> GetProjectConfigPage(FilterBase filter)
            => _repository.GetProjectConfigPage(filter);

        /// <summary>
        /// Thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<viewBaseInfo> GetProjectConfigFields(Guid? oid)
            => _repository.GetProjectConfigFields(oid);

        /// <summary>
        /// Lưu thông tin Thêm/Sửa bản ghi
        /// </summary>
        /// <param name="inputData"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetProjectConfig(CommonViewInfo inputData)
            => _repository.SetProjectConfig(inputData);

        /// <summary>
        /// Xóa bản ghi
        /// </summary>
        /// <param name="oid"></param>
        /// <returns></returns>
        public Task<BaseValidate> SetProjectConfigDelete(List<Guid> arrOid)
            => _repository.SetProjectConfigDelete(arrOid);

        /// <summary>
        /// Upload lại file mẫu gốc và thay đổi giá trị cấu hình mặc định
        /// </summary>
        /// <returns></returns>
        public async Task<BaseValidate> SetProjectConfigDefaultValue(ProjectConfigSetDefaultValueInput input)
        {
            try
            {
                //Nếu truyền vào giá trị thì update luôn giá trị k cần thực hiện upload lại (cho mẫu thông báo, hoặc link file đã upload...)
                if (!string.IsNullOrEmpty(input.ConfigCode) && !string.IsNullOrEmpty(input.ConfigValue))
                {
                    var resSetDefault = await _repository.SetProjectConfigDefaultValue(input.ConfigCode, input.ConfigValue);
                    return resSetDefault;
                }

                var folderTemplate = Path.Combine(_environment.ContentRootPath, FolderResServiceReport.FOLDER_TEMPLATE);
                var lsConfigFilePath = new Dictionary<string, string>
                {
                    { "file_mau_thong_bao_nhac_no", Path.Combine(folderTemplate, ResServiceReport.BILL_TEMPLATE_NEW) },
                    { "file_mau_thong_bao_phi",  Path.Combine(folderTemplate, ResServiceReport.BILL_TEMPLATE_NEW) },
                    { "file_mau_thong_bao_cat_dich_vu",  Path.Combine(folderTemplate, ResServiceReport.RECEIVE_MONEY_TEMPLATE) }
                };

                foreach (var item in lsConfigFilePath)
                {
                    try
                    {
                        var fileStream = File.OpenRead(item.Value);
                        var fileInfo = new FileInfo(item.Value);
                        var resUpload = await _storageService.UploadFile(fileStream, fileInfo.Name);

                        if (resUpload == null)
                            return new BaseValidate { messages = $"{item.Key}: Không thành công" };

                        var info = new MediaFile
                        {
                            formFile = new FormFile(Stream.Null, 0, fileInfo.Length, "file", fileInfo.Name)
                        };
                        var resSetMetaUpload = await _metaRepository.SetMetaUpload(info, resUpload);
                        if (resSetMetaUpload != null && resSetMetaUpload.valid)
                        {
                            var data = await _metaService.GetMetaDetail(resSetMetaUpload.id, null);
                            var fileStorageInfo = data.FirstOrDefault();
                            var resSetDefault = await _repository.SetProjectConfigDefaultValue(item.Key, fileStorageInfo.groupFileId.ToString());
                            if (!resSetDefault.valid)
                            {
                                resSetDefault.messages = $"{item.Key}: Không thành công{Environment.NewLine}{resSetDefault.messages}";
                                return resSetDefault;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        return new BaseValidate { messages = $"{item.Key}: {ex.Message}" };
                    }
                }

                return new BaseValidate { valid = true };
            }
            catch (Exception ex)
            {
                return new BaseValidate { messages = ex.Message };
            }
        }

        public Task<BaseValidate<string>> GetProjectConfigValue(string configCode)
            => _repository.GetProjectConfigValue(configCode, null);
    }
}