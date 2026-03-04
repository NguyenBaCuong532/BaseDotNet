using Google.Apis.Drive.v3;
using UNI.Common;
using UNI.Common.HelperService;
using System;

namespace UNI.Resident.BLL.BusinessService
{
    public class GoogleDriverHomeBillService : GoogleDriverBaseService
    {
        #region private-service-doc 
        public ggDriverFileDownload UploadBilFile(DriveService driveService, ggDriverFileStream homestream)
        {
            string documentName = String.Empty;
            string folderProject = String.Empty;
            string folderYYYY = String.Empty;
            string folderMM = String.Empty;
            if (homestream.documentType == 1)
            {
                documentName = "Hóa đơn";
            }
            else if (homestream.documentType == 2)
            {
                documentName = "Phiếu thu";
            }

            documentName = CheckExistedFolderAndCreate(driveService, documentName, FolderServiceGoogledriver.FORLER_GOOGLEDRIVER, FolderServiceGoogledriver.TEAMDRIVERID);
            folderProject = CheckExistedFolderAndCreate(driveService, homestream.folderName, documentName, FolderServiceGoogledriver.TEAMDRIVERID);
            folderYYYY = CheckExistedFolderAndCreate(driveService, homestream.dDate.ToString("yyyy"), folderProject, FolderServiceGoogledriver.TEAMDRIVERID);
            folderMM = CheckExistedFolderAndCreate(driveService, homestream.dDate.ToString("MM"), folderYYYY, FolderServiceGoogledriver.TEAMDRIVERID);
            //var file = UploadFromStream(driveService, homestream.stream, homestream.fileName, homestream.mimeType, folderMM);
            var bucket = "sunshine-app-production.appspot.com";
            var file = FireBaseServices.UploadFile(homestream.stream, homestream.fileName, app: folderMM, bucket: bucket).Result;
            var urlfile = file.MediaLink.Replace("https://storage.googleapis.com/download/storage/v1/b/sunshine-app-production.appspot.com/o/", "https://cdn.sunshineapp.vn/");

            return new ggDriverFileDownload { fileId = file.Id, fileName = file.Name, WebViewLink = urlfile, WebContentLink = urlfile };
        }
        #endregion private-service-doc
    }
}
