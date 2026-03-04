namespace UNI.Resident.Model.Feedback;

public class FeedbackProcessGet : FeedbackProcess
{
    public int ProcessId { get; set; }
    public string ProcessDate { get; set; }
    public string EmployeeName { get; set; }
    public string StatusName { get; set; }
}