using UNI.Model;
using System;
using System.Collections.Generic;
using System.Text;

namespace SSG.Resident.Model.Notification
{
    public class AppSettings
    {
        public BaseUrls BaseUrls { get; set; }
        public Client Client { get; set; }
        public string ProjectId { get; set; }
        public string BrandName { get; set; }
        public string SendName { get; set; }
        public string AdminSafeList { get; set; }
        public bool AnalyticEnabled { get; set; }
        public int MinuteExpired { get; set; }
        public bool InitData { get; set; }
        public string Language { get; set; }
        public AppNotifySetting Notify { get; set; }
        public string LibreOfficeLocation { get; set; }
        public string AppUrl { get; set; }
    }
    public class BaseUrls
    {
        public string Api { get; set; }
        public string Auth { get; set; }
        public string Web { get; set; }
        public string CoreApi { get; set; }
        public string Storage { get; set; }
        public string FrontendUrl { get; set; }
    }
    public class kApiSetting
    {
        public string xApiIpAdress { get; set; }
        public string XApiKey { get; set; }
        public string Host { get; set; }
    }
    public class Client
    {
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
    }
    public class AppNotifySetting
    {
        public string ExternalKey { get; set; }
    }
}
