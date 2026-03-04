using UNI.Model.Audit;

namespace UNI.Resident.DAL.Interfaces
{

    public interface IAuditRepository
    {
        void InsertAuditLogs(AuditModel objauditmodel);
        void InsertAuditAppLogs(AuditModelApp objauditmodel);
        void InsertAuditServiceLogs(AuditModelApp objauditmodel);
        AuditPage GetAuditPage(AuditFilter filter);
    }
}
