using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using MimeKit;
using Minio;
using Minio.DataModel;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text;
using System.Threading.Tasks;
//using Renci.SshNet.Messages.Transport;
//using UNI.BzzCloud.BLL.BusinessInterfaces.Api;
using UNI.Common.HelperService;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Api;

namespace UNI.Resident.BLL.BusinessService.Api
{
    public class ApiFireBaseStorageService : IApiStorageService
    {
        private readonly ILogger<ApiFireBaseStorageService> _logger;

        //thư mục gốc, có thể phân chia thư mục gốc theo ứng dụng hoặc chức năng
        private readonly string _defaultPrefixFolder;

        //ổ cứng ảo, có thể phân chia theo ứng dụng, sản phẩm
        private readonly string _defaultBucketName;

        public ApiFireBaseStorageService(ILogger<ApiFireBaseStorageService> logger, StorageConfig configuration)
        {
            _logger = logger;
            _defaultPrefixFolder = configuration.PrefixFolder ?? "Bizzone";
            _defaultBucketName = configuration.BucketName ?? "sunshine-app-production.appspot.com";
        }

        public string GetScheme => "firebase://";

        //check object is exists
        private Task<bool> IsExists(string objectName)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public async Task<UploadResponse> UploadFile(IFormFile file, string path = null)
        {
            try
            {
                var fileName = string.IsNullOrEmpty(file.FileName) ? DateTime.Now.Ticks.ToString() : file.FileName;
                var objectName = _defaultPrefixFolder + (string.IsNullOrEmpty(path) ? "" : $"/{path}") + "/" + DateTime.Now.Ticks + "_" + fileName;

                var fileUrl =
                    await FireBaseServices.UploadFileCdn(file.OpenReadStream(), objectName, app: _defaultPrefixFolder);

                return new UploadResponse()
                {
                    Bucket = _defaultBucketName,
                    ObjectName = objectName,
                    FilePath = fileUrl,
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when upload file: {FileName}", file.FileName);
                return null;
            }
        }

        public async Task<UploadResponse> UploadFile(Stream stream, string fileName, string path = null)
        {
            try
            {
                if (stream == null)
                    throw new Exception("Error: fileStream null or filename null");

                fileName = string.IsNullOrEmpty(fileName) ? DateTime.Now.Ticks.ToString() : fileName;
                var objectName = _defaultPrefixFolder + (string.IsNullOrEmpty(path) ? "" : $"/{path}") + "/" + DateTime.Now.Ticks + "_" + fileName;

                var fileUrl = await FireBaseServices.UploadFileCdn(stream, objectName, app: _defaultPrefixFolder);

                return new UploadResponse()
                {
                    Bucket = _defaultBucketName,
                    ObjectName = objectName,
                    FilePath = fileUrl,
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when upload file: {FileName}", fileName);
                return null;
            }
        }

        public Task<string> GetPreSignedUploadUrl(UploadRequest request)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public Task<string> GetDownloadUrl(string objectName, string bucketName = null)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public Task<FileStorageInfo> GetInfo(string objectName, string bucketName = null)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public Task Remove(List<string> files)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public void RemoveFolder(string folder)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public Task<IList<Item>> List(string folder, bool? recursive)
        {
            //TODO: Implement this method
            throw new NotImplementedException();
        }

        public void MapRelativePathToAbsolutePath(object obj)
        {
            
        }
    }
}