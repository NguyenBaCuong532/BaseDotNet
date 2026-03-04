using Microsoft.Extensions.DependencyInjection;
using System;
using UNI.Common.CommonBase;

namespace UNI.Resident.DAL.Commons
{
    public interface IResidentCommonBaseRepository : IUniCommonBaseRepository
    {
        public string ProjectCode { get; }
    }

    public class ResidentCommonBaseRepository : UniCommonBaseRepository, IResidentCommonBaseRepository
    {
        public ResidentCommonBaseRepository(IServiceProvider serviceProvider, string connectionString = null, string commonFilterStored = null, bool isAcceptLanguage = false) : base(serviceProvider, connectionString, commonFilterStored, isAcceptLanguage)
        {
            var httpContextAccessor = serviceProvider.GetService<Microsoft.AspNetCore.Http.IHttpContextAccessor>();
            var projectCode = httpContextAccessor?.HttpContext?.Request?.Headers["ProjectCode"];
            _projectCode = string.IsNullOrEmpty(projectCode) ? "" : projectCode.ToString();
        }

        public string _projectCode { get; set; }
        public string ProjectCode => _projectCode;
    }
}