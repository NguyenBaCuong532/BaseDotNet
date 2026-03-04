using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Confluent.Kafka;
using Confluent.Kafka.Admin;
using FluentEmail.Core;
using FluentEmail.Core.Models;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RestSharp.Authenticators;
using UNI.Model;
using UNI.Model.Api;
using UNI.Model.APPM;
using UNI.Utils;

namespace UNI.BzzCommon.DAL.Repositories.Api;

public abstract class ApiKafkaRepository : HttpClientBase
{
    protected string mailUserName;
    protected string mailUrl;
    protected string mailApiKey;
    protected string mailDomain;
    protected string mailFromAddress;
    protected string mailFromName;

    protected readonly string smsUrl;
    protected readonly string smsApiKey;

    protected readonly ILogger logger;

    protected readonly IProducer<string, string> kafkaProducer;
    protected readonly IAdminClient kafkaAdminClient;

    //a contructor with a parameter of type IConfiguration
    protected ApiKafkaRepository(IConfiguration configuration, ILogger<ApiKafkaRepository> logger)
    {
        this.logger = logger;
        
        // Init Kafka Producer
        Enum.TryParse(configuration["Kafka:ProducerSettings:SecurityProtocol"] ?? "SaslSsl", true,
            out SecurityProtocol securityProtocol);
        Enum.TryParse(configuration["Kafka:ProducerSettings:SaslMechanism"] ?? "Plain", true,
            out SaslMechanism saslMechanism);
        var config = new ProducerConfig
        {
            BootstrapServers = configuration["Kafka:ProducerSettings:BootstrapServers"],
            SecurityProtocol = SecurityProtocol.Plaintext,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = configuration["Kafka:ProducerSettings:SaslUsername"],
            SaslPassword = configuration["Kafka:ProducerSettings:SaslPassword"]
        };
        kafkaProducer = new ProducerBuilder<string, string>(config)
            .SetKeySerializer(Serializers.Utf8)
            .SetValueSerializer(Serializers.Utf8)
            .SetLogHandler((_, log) => { logger.LogInformation("Producer log: {Log}", log.Message); })
            .SetErrorHandler((_, e) =>
            {
                //Agent.Tracer.CaptureError(e.Reason, e.Reason);
                logger.LogError("Error: {Reason}", e.Reason);
            })
            .Build();

        kafkaAdminClient = new AdminClientBuilder(new AdminClientConfig
        {
            BootstrapServers = configuration["Kafka:ProducerSettings:BootstrapServers"],
            SecurityProtocol = SecurityProtocol.Plaintext,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = configuration["Kafka:ProducerSettings:SaslUsername"],
            SaslPassword = configuration["Kafka:ProducerSettings:SaslPassword"]
        }).Build();
    }

   

    public Task<BaseResponse<string>> SendToKafka(string topic, string message)
    {
        return kafkaProducer.ProduceAsync(topic, new Message<string, string>
        {
            Key = Guid.NewGuid().ToString(),
            Value = message
        }).ContinueWith(task =>
        {
            if (task.IsFaulted)
            {
                var error = task.Exception?.InnerException?.Message;
                logger.LogError("Error: {Reason}", error);
                //Agent.Tracer.CaptureException(task.Exception?.InnerException);
                return new BaseResponse<string>(ApiResult.Error, error: error);
            }

            var result = task.Result.Status;
            if (result != PersistenceStatus.NotPersisted)
            {
                logger.LogInformation($"Delivered message to: {task.Result.TopicPartitionOffset}");
                return new BaseResponse<string>(ApiResult.Success);
            }

            logger.LogError("Error: {Reason}", result);
            //Agent.Tracer.CaptureException(new Exception(result.ToString()));
            return new BaseResponse<string>(ApiResult.Error, error: result.ToString());
        });
    }

    public async Task CreateTopic(string topicName, int numPartitions = 1, short replicationFactor = 1)
    {
        try
        {
            await kafkaAdminClient.CreateTopicsAsync(new[]
            {
                new TopicSpecification
                {
                    Name = topicName,
                    NumPartitions = numPartitions,
                    ReplicationFactor = replicationFactor
                }
            });

            Console.WriteLine($"Topic '{topicName}' created successfully.");
        }
        catch (CreateTopicsException e)
        {
            Console.WriteLine($"An error occurred creating topic {e.Results[0].Topic}: {e.Results[0].Error.Reason}");
            //Agent.Tracer.CaptureException(e);
        }
    }
    // check if the topic exists
    public bool TopicExists(string topicName)
    {
        try
        {
            var metadata = kafkaAdminClient.GetMetadata(TimeSpan.FromSeconds(10));
            return metadata.Topics.Any(t => t.Topic == topicName);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return false;
        }
        
    }
}