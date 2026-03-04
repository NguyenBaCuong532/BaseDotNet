using Microsoft.Extensions.Logging;
using UNI.Resident.BLL.BusinessInterfaces;
using UNI.Resident.DAL.Interfaces;
using UNI.Model.Audit;

namespace UNI.Resident.BLL.BusinessService
{
    public class AuditService : IAuditService
    {
        private readonly ILogger<AuditService> _logger;
        private readonly IAuditRepository _auditRepository;
        public AuditService(ILogger<AuditService> logger, IAuditRepository auditRepository)
        {
            this._logger = logger;
            _auditRepository = auditRepository;
        }
        public void InsertAuditLogs(AuditModel objauditmodel)
        {
            _auditRepository.InsertAuditLogs(objauditmodel);
        }

        public void InsertAuditAppLogs(AuditModelApp objauditmodel)
        {
            _auditRepository.InsertAuditAppLogs(objauditmodel);
        }
        public void InsertAuditServiceLogs(AuditModelApp objauditmodel)
        {
            _auditRepository.InsertAuditServiceLogs(objauditmodel);
        }

        public AuditPage GetAuditPage(AuditFilter filter)
        {
            return _auditRepository.GetAuditPage(filter);
        }
    }
}
