using System.Collections.Generic;
using UNI.Resident.Model.Request;

namespace UNI.Resident.Model.Feedback;

public class FeedbackFull : Feedback
{
    public ICollection<FeedbackProcessGet> Processes { get; set; }
    public ICollection<RequestAttachment> Attachments { get; set; }
}