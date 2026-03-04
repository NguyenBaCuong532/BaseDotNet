using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Headers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;
using UNI.Resident.BLL.BusinessInterfaces;
using System;
using System.Linq;
using UNI.Common;
using UNI.Model;
using UNI.Model.Audit;

namespace UNI.Resident.API.Filters
{
    public class AuditFilterAttribute : ActionFilterAttribute
    {
        private readonly IAuditService _auditService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public AuditFilterAttribute(IHttpContextAccessor httpContextAccessor, IAuditService auditService)
        {
            _httpContextAccessor = httpContextAccessor;
            _auditService = auditService;
        }
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var objaudit = new AuditModelApp();
            try
            {
                // Getting Action Name 
                var controllerName = ((ControllerBase)filterContext.Controller)
                    .ControllerContext.ActionDescriptor.ControllerName;
                var actionName = ((ControllerBase)filterContext.Controller)
                    .ControllerContext.ActionDescriptor.ActionName;
                var actionDescriptorRouteValues = ((ControllerBase)filterContext.Controller)
                    .ControllerContext.ActionDescriptor.RouteValues;
                var userId = ((ControllerBase)filterContext.Controller).User.Claims.Where(c => c.Type == "sub").Select(c1 => c1.Value).FirstOrDefault();
                var clientId = ((ControllerBase)filterContext.Controller).User.Claims.Where(c => c.Type == "client_id").Select(c1 => c1.Value).FirstOrDefault();
                var request = filterContext.HttpContext.Request;
                objaudit.ApiName = Constants.ApiName_Home;
                if (!string.IsNullOrEmpty(userId))
                {
                    objaudit.UserId = userId;
                }
                else
                {
                    objaudit.UserId = "";
                }
                if (!string.IsNullOrEmpty(clientId))
                {
                    objaudit.ClientId = clientId;
                }
                else
                {
                    objaudit.UserId = "";
                }
                objaudit.SessionId = filterContext.HttpContext.Session.Id; // Application SessionID // User IPAddress 
                if (_httpContextAccessor.HttpContext != null)
                {
                    objaudit.IpAddress = Convert.ToString(_httpContextAccessor.HttpContext.Connection.RemoteIpAddress);
                }
                objaudit.PageAccessed = Convert.ToString(filterContext.HttpContext.Request.Path); // URL User Requested 
                objaudit.ControllerName = controllerName; // ControllerName 
                objaudit.ActionName = actionName;
                RequestHeaders header = request.GetTypedHeaders();
                Uri uriReferer = header.Referer;
                if (uriReferer != null)
                {
                    objaudit.UrlReferrer = header.Referer.AbsoluteUri;
                }
                var data = "";
                if (!string.IsNullOrEmpty(filterContext.HttpContext.Request.QueryString.Value))
                {
                    data = filterContext.HttpContext.Request.QueryString.Value;
                }
                else
                {
                    var inputdata = filterContext.ActionArguments.FirstOrDefault();
                    var dataStr = JsonConvert.SerializeObject(inputdata);
                    data = dataStr;
                }
                objaudit.Data = data;
                objaudit.Method = filterContext.HttpContext.Request.Method;
                objaudit.Description = "SUCCESS";
                //_auditService.InsertAuditServiceLogs(objaudit);
            }
            catch (Exception ex)
            {
                objaudit.Description = "EXCEPTION-" + ex.ToString();
                _auditService.InsertAuditServiceLogs(objaudit);
            }

        }
    }
}
