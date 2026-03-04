using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Minio;
using Minio.DataModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UNI.Model;
using UNI.Resident.BLL.BusinessInterfaces.Api;

namespace UNI.Resident.BLL.BusinessService.Api
{
    public class ApiMinIoStorageService : IApiStorageService
    {
        private readonly MinioClient _client;

        //ổ cứng ảo, có thể phân chia theo ứng dụng, sản phẩm
        private readonly string _defaultBucketName;

        //thư mục gốc, có thể phân chia thư mục gốc theo ứng dụng hoặc chức năng
        private readonly string _defaultPrefixFolder;
        private readonly ILogger<ApiMinIoStorageService> _logger;

        private readonly string _proxyEndpoint;

        private readonly int _defaultExpire = 60 * 60 * 24; //24 hours

        private const string HeaderFileName = "x-file-name";
        private const string HeaderFileNameEncode = "x-file-name-encode";
        private const string EncodeBase64 = "base64";

        public ApiMinIoStorageService(ILogger<ApiMinIoStorageService> logger, StorageConfig configuration)
        {
            _logger = logger;
            var endpoint = configuration?.Endpoint ?? "127.0.0.1:9000";
            var accessKey = configuration?.AccessKey ?? "p1ZmKVJFb5LmblzV7qHh";
            var secretKey = configuration?.SecretKey ?? "bgADpnd9DwZjDa6tVXBQHcpG2c1j1l8yU1T6xLMn";
            _defaultBucketName = configuration?.BucketName ?? "bizzone-yamaha-dev";
            _defaultPrefixFolder = configuration?.PrefixFolder ?? "";
            _proxyEndpoint = configuration?.ProxyEndpoint ?? "http://localhost:3185/Storage/GetFile";

            _client = new MinioClient()
                .WithEndpoint(endpoint)
                .WithSSL(configuration?.UseSsl ?? false)
                .WithCredentials(accessKey, secretKey)
                .Build();
        }

        public string GetScheme => "minio://";

        //check object is exists
        private async Task<bool> IsExists(string objectName)
        {
            try
            {
                var isExists =
                    await _client.StatObjectAsync(new StatObjectArgs()
                        .WithBucket(_defaultBucketName)
                        .WithObject(objectName));
                _logger.LogInformation("Object {ObjectName} is exists", isExists);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }


        private string GetObjectName(string path, string fileName)
        {
            return _defaultPrefixFolder + (string.IsNullOrEmpty(path) ? "" : $"/{path}") + $"/{fileName}";
        }

        public async Task<UploadResponse> UploadFile(IFormFile file, string path = null)
        {
            try
            {
                var fileName = file.FileName;
                var validateFileName = ValidateFileName(fileName);
                if (validateFileName != null)
                {
                    throw new Exception(validateFileName);
                }

                //trim file name and remove multiple spaces to single space
                var normalFileName = RemoveDuplicateSpaces(fileName.Trim(), "_");
                //encode file name to base64 string
                var fileNameBase64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(normalFileName));

                fileName = RemoveNonAscii(normalFileName);
                var newOid = Guid.NewGuid().ToString();
                var objectName = GetObjectName(path, newOid + "_" + fileName);

                var args = new PutObjectArgs()
                    .WithBucket(_defaultBucketName)
                    .WithObject(objectName)
                    .WithContentType(file.ContentType)
                    .WithObjectSize(file.Length)
                    .WithHeaders(new Dictionary<string, string>()
                    {
                        { HeaderFileName, fileNameBase64 },
                        { HeaderFileNameEncode, EncodeBase64 }
                    })
                    .WithStreamData(file.OpenReadStream());
                var response = await _client.PutObjectAsync(args);

                var url = await GetDownloadUrl(objectName, _defaultBucketName);
                return new UploadResponse()
                {
                    Bucket = _defaultBucketName,
                    ObjectName = response.ObjectName,
                    FilePath = GetScheme + _defaultBucketName + "/" + response.ObjectName,

                    FileName = normalFileName,
                    Size = response.Size,
                    ContentType = file.ContentType,

                    Url = url,
                    UrlExpiration = _defaultExpire
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when upload file: {FileName}", file.FileName);
                throw;
            }
        }

        public async Task<UploadResponse> UploadFile(Stream stream, string fileName = null, string path = null)
        {
            //Chưa xử lý phần này. Đã xong ở FireBase
            throw new Exception("Error: fileStream null or filename null");
        }

        public async Task<string> GetPreSignedUploadUrl(UploadRequest request)
        {
            try
            {
                var args = new PresignedPutObjectArgs()
                    .WithBucket(_defaultBucketName)
                    .WithObject(GetObjectName(request.Path, request.Name))
                    .WithExpiry(_defaultExpire);

                var response = await _client.PresignedPutObjectAsync(args).ConfigureAwait(false);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when GetPreSignedUrl: {FileName}", request.Name);
                return "";
            }
        }

        public Task<string> GetDownloadUrl(string objectName, string bucketName = null)
        {
            try
            {
                var args = new PresignedGetObjectArgs()
                    .WithBucket(string.IsNullOrEmpty(bucketName) ? _defaultBucketName : bucketName)
                    .WithObject(objectName)
                    .WithExpiry(_defaultExpire); //24 hours
                return _client.PresignedGetObjectAsync(args);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception when get link for {ObjName}", objectName);
                return Task.FromResult("");
            }
        }

        public async Task<FileStorageInfo> GetInfo(string objectName, string bucketName = null)
        {
            try
            {
                var objectStat =
                    await _client.StatObjectAsync(new StatObjectArgs()
                        .WithBucket(_defaultBucketName)
                        .WithObject(objectName));
                _logger.LogInformation("Object {ObjectName} is exists", objectStat);

                objectStat.MetaData.TryGetValue(HeaderFileName, out var xFileName);
                objectStat.MetaData.TryGetValue(HeaderFileNameEncode, out var xFileNameEncode);


                if (string.IsNullOrEmpty(xFileName))
                {
                    xFileName = objectStat.ObjectName;
                }
                else if (xFileNameEncode == EncodeBase64)
                {
                    xFileName = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(xFileName));
                }

                return new FileStorageInfo()
                {
                    ObjectName = objectStat.ObjectName,
                    Size = objectStat.Size,
                    LastModified = objectStat.LastModified,
                    ETag = objectStat.ETag,
                    ContentType = objectStat.ContentType,
                    FileName = xFileName
                };
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Exception when get info for {ObjectName}", objectName);
                return null;
            }
        }

        public async Task Remove(List<string> files)
        {
            try
            {
                var absolutePaths = files.Select(file => file).ToList();

                var observable = await _client.RemoveObjectsAsync(new RemoveObjectsArgs()
                    .WithBucket(_defaultBucketName)
                    .WithObjects(absolutePaths)).ConfigureAwait(false);

                observable.Subscribe(
                    objDeleteError =>
                        _logger.LogError("objDeleteError: Key: {ObjKey}, Code: {Code}, Message: {Message}",
                            objDeleteError.Key, objDeleteError.Code, objDeleteError.Message),
                    ex => _logger.LogError(ex, "OnError Exception when remove files: {Files}", files),
                    () => _logger.LogInformation("Removed objects in list from {DefaultBucketName}", _defaultBucketName)
                );
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Exception when remove files: {Files}", files);
                throw;
            }
        }

        public void RemoveFolder(string folder)
        {
            var observable = _client.ListObjectsAsync(new ListObjectsArgs()
                .WithBucket(_defaultBucketName)
                .WithPrefix(folder)
                .WithRecursive(true)
            );
            observable.Subscribe(
                obj =>
                {
                    _logger.LogInformation("OnRemove Object Key: {ObjKey}, ETag: {Etag}, IsDir: {IsDir}",
                        obj.Key, obj.ETag, obj.IsDir);
                    if (!obj.IsDir)
                    {
                        _client.RemoveObjectAsync(new RemoveObjectArgs()
                            .WithBucket(_defaultBucketName)
                            .WithObject(obj.Key));
                    }
                },
                ex => _logger.LogError(ex, "OnError Exception when remove folder: {Folder}", folder),
                () => _logger.LogInformation("Removed folder {Folder} from {DefaultBucketName}",
                    folder, _defaultBucketName)
            );
        }

        public Task<IList<Item>> List(string folder, bool? recursive)
        {
            try
            {
                var observable = _client.ListObjectsAsync(new ListObjectsArgs()
                    .WithBucket(_defaultBucketName)
                    .WithPrefix(folder)
                    .WithRecursive(recursive ?? false)
                );
                var task = observable.ToList().ToTask();
                return task;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }

        public void MapRelativePathToAbsolutePath(object obj)
        {
            var type = obj.GetType();
            foreach (var property in type.GetProperties())
            {
                var attribute =
                    (MapToFullUrlAttribute)Attribute.GetCustomAttribute(property, typeof(MapToFullUrlAttribute));
                if (attribute == null) continue;
                var relativeUrl = (string)property.GetValue(obj);
                var baseUrl = attribute.BaseUrl;
                if (string.IsNullOrEmpty(baseUrl))
                {
                    baseUrl = _proxyEndpoint;
                }

                var fullUrl = $"{baseUrl}?path={relativeUrl}";
                property.SetValue(obj, fullUrl);
            }
        }

        private string ValidateFileName(string fileName)
        {
            if (string.IsNullOrEmpty(fileName)) return "Tên file không được bỏ trống";
            if (fileName.Length > 256) return "Tên file không được quá 256 ký tự";

            var acceptSpecialCharacter = new[] { ' ', '.', '_', '-', '(', ')' };
            return fileName.Any(c => !char.IsLetterOrDigit(c) && !acceptSpecialCharacter.Contains(c) && c < 127)
                ? "Tên file không được chứa ký tự đặc biệt"
                : null;
        }

        string RemoveDuplicateSpaces(string input, string replaceWith = " ")
        {
            // Sử dụng regular expression để thay thế những ký tự space trùng lặp
            string pattern = "\\s+"; // \\s+ sẽ match một hoặc nhiều ký tự space
            string replacement = replaceWith;
            Regex regex = new Regex(pattern);
            string result = regex.Replace(input, replacement);

            return result;
        }

        //Remove non-ASCII characters
        public static string RemoveNonAscii(string text)
        {
            return Regex.Replace(text, @"[^\u0000-\u007F]+", string.Empty);
        }
    }
}