using Microsoft.AspNetCore.Http;
using Minio.DataModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using UNI.Model;

namespace UNI.Resident.BLL.BusinessInterfaces.Api
{
    public interface IApiStorageService
    {
        string GetScheme { get; }

        /// <summary>
        /// Upload file trực tiếp qua API Service 
        /// </summary>
        /// <remarks>
        /// Dùng upload file dung lượng thấp, demo, không khuyến khích sử dụng,
        /// Phụ thuộc vào bộ nhớ tạm của API Service, dễ gây quá tải server nếu lưu lượng truy cập cao
        /// </remarks>
        /// <param name="file"></param>
        /// <param name="path"></param>
        /// <returns></returns>
        Task<UploadResponse> UploadFile(IFormFile file, string path = null);

        Task<UploadResponse> UploadFile(Stream stream, string fileName, string path = null);

        ///  <summary>
        ///  Lấy đường dẫn để upload file trực tiếp lên Storage Service
        ///  </summary>
        ///  <remarks>
        ///  Khi có được url để đăng tải tệp tin dung lượng thấp, bạn thực hiện gửi request với [method PUT](https://codepen.io/trungtai1805/pen/gOQvovy) và body chứa binary data của tệp tin.
        /// 
        ///  Đối với tệp tin dung lượng lớn bạn có thể sử dụng [Flow.JS](https://github.com/flowjs) 
        ///  Example [Angular Flow](https://stackblitz.com/edit/ngx-flow-example-5ndizb?file=src%2Fapp%2Fapp.component.html)
        ///  </remarks>
        /// <param name="request"></param>
        /// <returns></returns>
        Task<string> GetPreSignedUploadUrl(UploadRequest request);

        /// <summary>
        /// Lấy link  download file, link có thời hạn nhất định
        /// </summary>
        /// <param name="objectName">Đường dẫn đến file lấy link</param>
        /// <param name="bucketName">Bucket</param>
        /// 
        Task<string> GetDownloadUrl(string objectName, string bucketName = null);

        /// <summary>
        /// Lấy thông tin file trên Storage Service
        /// </summary>
        /// <param name="objectName"></param>
        /// <param name="bucketName"></param>
        /// <returns></returns>
        Task<FileStorageInfo> GetInfo(string objectName, string bucketName = null);

        /// <summary>
        /// Xóa file trên Storage Service
        /// </summary>
        /// <param name="files"></param>
        /// <returns></returns>
        Task Remove(List<string> files);

        /// <summary>
        /// Xóa folder trên Storage Service
        /// </summary>
        /// <param name="folder"></param>
        void RemoveFolder(string folder);

        /// <summary>
        /// List file trong folder
        /// </summary>
        /// <param name="folder"></param>
        /// <param name="recursive"></param>
        /// <returns></returns>
        Task<IList<Item>> List(string folder, bool? recursive);
        
        void MapRelativePathToAbsolutePath(object obj);
    }
}