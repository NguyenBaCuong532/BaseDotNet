using UNI.Model.Audit;

namespace UNI.Resident.BLL.BusinessInterfaces
{
    public interface IAuditService
    {
        void InsertAuditLogs(AuditModel objauditmodel);
        void InsertAuditAppLogs(AuditModelApp objauditmodel);
        void InsertAuditServiceLogs(AuditModelApp objauditmodel);
        AuditPage GetAuditPage(AuditFilter filter);
    }
}
