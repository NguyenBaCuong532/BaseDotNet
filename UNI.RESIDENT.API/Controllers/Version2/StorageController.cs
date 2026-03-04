using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using RestSharp.Extensions;
using UNI.Resident.BLL.BusinessInterfaces.Api;
using UNI.Model;
using UNI.Model.Api;

namespace UNI.Resident.API.Controllers.Version2
{
    /// <summary>
    /// API thực hiện các thao tác với Storage Service
    /// </summary>
    [ApiController]
    [Route("Storage")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class StorageController : UniController
    {
        private readonly ILogger<StorageController> _logger;
        private readonly IApiStorageService _storageService;

        /// <summary>
        /// Hàm khởi tạo logger và service
        /// </summary>
        /// <param name="logger"></param>
        /// <param name="storageService"></param>
        public StorageController(ILogger<StorageController> logger, IApiStorageService storageService)
        {
            _logger = logger;
            _storageService = storageService;
        }

        /// <summary>
        /// API thực hiện stream file từ Storage Service
        /// </summary>
        /// <param name="path">path/id của file</param>
        /// <param name="action">nhận các giá trị
        /// - "url" trả về link url để download
        /// - "default" hoặc empty trả về file để download
        /// - "info" trả về thông tin file
        /// </param>
        /// 
        [HttpGet]
        [Route("GetFile")]
        public async Task<IActionResult> GetFile(string path, string action = "default")
        {
            if (path == null) return new BadRequestObjectResult("path not found");
            if (path.StartsWith("http"))
            {
                return action == "url" ? Ok(path) : Redirect(path);
            }

            if (path.StartsWith("minio://") == false)
                return new BadRequestObjectResult("Scheme not supported");

            //path format: "minio://bucket-name/path/to/file";
            //parse path to bucket and object name
            var uri = new Uri(path);
            var bucketName = uri.Host;
            var objectName = uri.AbsolutePath.TrimStart('/').UrlDecode();

            if (string.IsNullOrEmpty(objectName)) return new BadRequestObjectResult("object name not found");

            var result = await _storageService.GetDownloadUrl(objectName: objectName, bucketName: bucketName);
            if (result == null)
            {
                return new NotFoundObjectResult("File not found");
            }

            switch (action)
            {
                case "url":
                    return Ok(result);
                case "info":
                {
                    var fileInfo = await _storageService.GetInfo(objectName, bucketName);
                    if (fileInfo == null) return new NotFoundObjectResult("File not found");
                    fileInfo.Url = result;
                    fileInfo.FilePath = path;
                    return Ok(GetResponse(ApiResult.Success, fileInfo));
                }
                default:
                    return Redirect(result);
            }
        }

        /// <summary>
        /// Upload file trực tiếp qua API Service 
        /// </summary>
        /// <remarks>
        /// Dùng upload file dung lượng thấp, demo, không khuyến khích sử dụng,
        /// Phụ thuộc vào bộ nhớ tạm của API Service, dễ gây quá tải server nếu lưu lượng truy cập cao
        /// </remarks>
        /// <param name="file">File upload</param>
        /// <param name="path">Đường dẫn thư mục lưu trữ</param>
        [HttpPost]
        [Route("UploadFile")]
        public async Task<BaseResponse<UploadResponse>> UploadFile(IFormFile file, string path)
        {
            try
            {
                var result = await _storageService.UploadFile(file, path).ConfigureAwait(false);
                if (result == null)
                {
                    return GetResponse<UploadResponse>(ApiResult.Fail, null, "Upload file failed");
                }

                return GetResponse(ApiResult.Success, result);
            }
            catch (Exception e)
            {
                return GetResponse<UploadResponse>(ApiResult.Fail, null, e.Message);
            }
        }

        ///  <summary>
        ///  API thực hiện lấy đường dẫn để upload file trực tiếp lên Storage Service
        ///  </summary>
        ///  <remarks>
        ///  Khi có được url để đăng tải tệp tin dung lượng thấp, bạn thực hiện gửi request với [method PUT](https://codepen.io/trungtai1805/pen/gOQvovy) và body chứa binary data của tệp tin.
        /// 
        ///  Đối với tệp tin dung lượng lớn bạn có thể sử dụng [Flow.JS](https://github.com/flowjs) 
        ///  Example [Angular Flow](https://stackblitz.com/edit/ngx-flow-example-5ndizb?file=src%2Fapp%2Fapp.component.html)
        ///  </remarks>  
        ///  <param name="request">UploadRequest Model</param>
        [HttpPost]
        [Route("CreateUploadUrl")]
        public async Task<ObjectResult> CreateUploadUrl(UploadRequest request)
        {
            var result = await _storageService.GetPreSignedUploadUrl(request);
            if (string.IsNullOrEmpty(result))
            {
                return new NotFoundObjectResult("Get Pre-signed URLs failed");
            }

            return Ok(result);
        }

        /// <summary>
        /// API thực hiện xóa file trên Storage Service
        /// </summary>
        /// <param name="files">Danh sách file cần xóa</param>
        /// <returns>True if delete success, false if delete failed</returns>
        /// <response code="200">Return true if delete success</response>
        [HttpPost]
        [Route("RemoveFiles")]
        public async Task<ObjectResult> RemoveFiles(List<string> files)
        {
            try
            {
                await _storageService.Remove(files);
                return Ok(true);
            }
            catch (Exception e)
            {
                return Problem(e.Message);
            }
        }

        /// <summary>
        /// API thực hiện xóa folder trên Storage Service
        /// </summary>
        /// <param name="folder">Đường dẫn thư mục cần xoá</param>
        /// <returns>True if delete success, false if delete failed</returns>
        /// <response code="200">Return true if delete success</response>
        [HttpPost]
        [Route("RemoveFolder")]
        public ObjectResult RemoveFolder(string folder)
        {
            try
            {
                _storageService.RemoveFolder(folder);
                return Ok(true);
            }
            catch (Exception e)
            {
                return Problem(e.Message);
            }
        }

        /// <summary>
        /// Api list file trong folder
        /// </summary>
        /// <param name="folder">Đường dẫn thư mục</param>
        /// <param name="recursive"></param>
        /// <returns>List file trong folder</returns>
        /// <response code="200">Return list file</response>
        [HttpGet]
        [Route("ListFiles")]
        public async Task<ObjectResult> ListFiles(string folder, bool? recursive)
        {
            try
            {
                var result = await _storageService.List(folder, recursive);
                return Ok(result);
            }
            catch (Exception e)
            {
                return Problem(e.Message);
            }
        }
    }
}