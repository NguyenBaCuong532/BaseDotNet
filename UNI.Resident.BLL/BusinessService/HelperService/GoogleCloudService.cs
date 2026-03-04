using Google.Cloud.PubSub.V1;
using System;

namespace UNI.Resident.BLL.HelperService
{
    public class GoogleCloudService
    {
        public async System.Threading.Tasks.Task<int> GCMessageAsync(string message)
        {
            try
            {
                //PublisherServiceApiClient publisher = PublisherServiceApiClient.Create();
                string projectId = "sunshine-16a50";

                TopicName topicName = new TopicName(projectId, "sms");

                PublisherClient publisher = await PublisherClient.CreateAsync(topicName);
                // PublishAsync() has various overloads. Here we're using the string overload.
                string messageId = await publisher.PublishAsync(message);

                return 1;
            }
            catch (Exception ex)
            {
                return 0;
            }
        }
    }
}
