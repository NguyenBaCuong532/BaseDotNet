using Microsoft.AspNetCore.Http;
using System;
using System.Xml.Serialization;
using UNI.Model;
using UNI.Utils;

namespace UNI.Resident.Model.Notification
{
    /// <summary>
    /// NotifySentImport - Model cho 1 dòng dữ liệu import danh sách gửi thông báo từ Excel
    /// QUAN TRỌNG: Tên property phải là tiếng Anh, khớp với SQL UDTT
    /// </summary>
    public class NotifySentImport
    {
        [XmlElement("STT")]
        [Excel(ExcelCol = "A")]
        public int? STT { get; set; }                   // STT - Số thứ tự

        [XmlElement("FullName")]
        [Excel(ExcelCol = "B")]
        public string FullName { get; set; }             // FullName - Họ tên đầy đủ

        [XmlElement("Phone")]
        [Excel(ExcelCol = "C")]
        public string Phone { get; set; }                // Phone - Số điện thoại

        [XmlElement("Email")]
        [Excel(ExcelCol = "D")]
        public string Email { get; set; }                // Email - Địa chỉ email

        [XmlElement("Room")]
        [Excel(ExcelCol = "E")]
        public string Room { get; set; }                 // Room - Mã căn hộ

        [XmlElement("Errors")]
        [Excel(ExcelCol = "F")]
        public string Errors { get; set; }               // Errors - Lỗi validation
    }

    /// <summary>
    /// NotifySentImportSet - Model cho toàn bộ import data
    /// Kế thừa từ BaseImportSet để có các thuộc tính chung
    /// </summary>
    public class NotifySentImportSet : BaseImportSet<NotifySentImport>
    {
        /// <summary>
        /// n_id - Mã thông báo (NotifyInbox.n_id)
        /// </summary>
        public Guid? n_id { get; set; }
    }

    public class NotifySentImportInput
    {
        public Guid n_id { get; set; }
        public IFormFile file { get; set; }
    }
}

