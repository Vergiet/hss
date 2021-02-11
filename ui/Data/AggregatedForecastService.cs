using System;
using System.Linq;
using System.Threading.Tasks;
using System.Text;
using System.Collections.Generic;
using Azure.Messaging.EventHubs.Consumer;
using System.Text.Json;
using Azure.Messaging.EventHubs.Processor;
using System.Threading;
using Azure.Storage.Blobs;
using Azure.Messaging.EventHubs;

namespace Ui.Data
{
    public class AggregatedForecastService
    {

        public static string stringa;
        static string connectionString = Environment.GetEnvironmentVariable("connectionstring");
        static string eventHubName = Environment.GetEnvironmentVariable("eventhub-name");

        static string blobStorageConnectionString = Environment.GetEnvironmentVariable("blobStorageConnectionString");
        static string blobContainerName = Environment.GetEnvironmentVariable("blobContainerName");

        public static async Task GetForecastAsync()
        {

            string forecast;

            string consumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

            BlobContainerClient storageClient = new BlobContainerClient(blobStorageConnectionString, blobContainerName);

            EventProcessorClient processor = new EventProcessorClient(storageClient, consumerGroup, connectionString, eventHubName);

            // Register handlers for processing events and handling errors
            processor.ProcessEventAsync += ProcessEventHandler;
            processor.ProcessErrorAsync += ProcessErrorHandler;

            // Start the processing
            processor.StartProcessingAsync();

            // Wait for 10 seconds for the events to be processed
            //await Task.Delay(TimeSpan.FromSeconds(10));

            // Stop the processing
            //await processor.StopProcessingAsync();

            // Read from the default consumer group: $Default

            /*

                        var consumer = new EventHubConsumerClient(consumerGroup, connectionString, eventHubName);

                        var cancellationSource = new CancellationTokenSource();
                        cancellationSource.CancelAfter(TimeSpan.FromSeconds(45000));

                        await foreach (PartitionEvent receivedEvent in consumer.ReadEventsAsync(cancellationSource.Token))
                        {
                            // At this point, the loop will wait for events to be available in the Event Hub. When an event
                            // is available, the loop will iterate with the event that was received. Because we did not
                            // specify a maximum wait time, the loop will wait forever unless cancellation is requested using
                            // the cancellation token.

                            //var data = BinaryData.FromBytes();

                            var body = receivedEvent.Data.Body.ToArray();
                            var data = Encoding.UTF8.GetString(body);
                            // forecast = JsonSerializer.Deserialize<AggregatedForecast>(data);
                            forecast = data;
                            await Task.Delay(TimeSpan.FromSeconds(1));
                            return forecast;
                        }

                        return await Task.FromResult("Hello");

                        // Create a blob container client that the event processor will use 
                        //BlobContainerClient storageClient = new BlobContainerClient(blobStorageConnectionString, blobContainerName);

                        // Create an event processor client to process events in the event hub
                        //EventProcessorClient processor = new EventProcessorClient(storageClient, consumerGroup, ehubNamespaceConnectionString, eventHubName);

                        // Register handlers for processing events and handling errors
                        //processor.ProcessEventAsync += ProcessEventHandler;
                        //processor.ProcessErrorAsync += ProcessErrorHandler;

                        // Start the processing
                        //await processor.StartProcessingAsync();

                        // Wait for 10 seconds for the events to be processed
                        //await Task.Delay(TimeSpan.FromSeconds(10));

                        // Stop the processing
                        //await processor.StopProcessingAsync();
                        */
        }

        static async Task ProcessEventHandler(ProcessEventArgs eventArgs)
        {
            // Write the body of the event to the console window
            //Console.WriteLine("\tReceived event: {0}", Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray()));

            stringa = Encoding.UTF8.GetString(eventArgs.Data.Body.ToArray());

            // Update checkpoint in the blob storage so that the app receives only new events the next time it's run
            await eventArgs.UpdateCheckpointAsync(eventArgs.CancellationToken);
        }

        static Task ProcessErrorHandler(ProcessErrorEventArgs eventArgs)
        {
            // Write details about the error to the console window
            Console.WriteLine($"\tPartition '{ eventArgs.PartitionId}': an unhandled exception was encountered. This was not expected to happen.");
            Console.WriteLine(eventArgs.Exception.Message);
            return Task.CompletedTask;
        }

    }

}





/*
public Task<AggregatedForecast[]> GetForecastAsync(DateTime startDate)
    {
        private List<AggregatedForecast> forecasts;
    string connectionString = Environment.GetEnvironmentVariable("connectionstring");
    string eventHubName = Environment.GetEnvironmentVariable("eventhub-name");
    string consumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

    await using (var consumer = new EventHubConsumerClient(consumerGroup, connectionString, eventHubName))
        {
            using var cancellationSource = new CancellationTokenSource();
cancellationSource.CancelAfter(TimeSpan.FromSeconds(450000));

            await foreach (PartitionEvent receivedEvent in consumer.ReadEventsAsync(cancellationSource.Token))
            {
                // At this point, the loop will wait for events to be available in the Event Hub. When an event
                // is available, the loop will iterate with the event that was received. Because we did not
                // specify a maximum wait time, the loop will wait forever unless cancellation is requested using
                // the cancellation token.

                //var data = BinaryData.FromBytes();

                var body = receivedEvent.Data.Body.ToArray();
var data = Encoding.UTF8.GetString(body);

//
var message = string.Format("Read at:{0} Message: {1}", DateTime.Now, data.ToString());
Console.WriteLine(message);
                try
                {
                    var forecast = JsonSerializer.Deserialize<AggregatedForecast>(data);
forecasts.Add(forecast);
                    /*
                    foreach (var forcast in forcasts)
                    {
                    var message2 = string.Format("Read at:{0} Day: {1}, AVG: {2}, MIN: {3}, MAX: {4}, STDEVP: {5}", DateTime.Now,
                    forcast.Day,
                    forcast.AVG, forcast.MIN, forcast.MAX, forcast.STDEVP);
                    Console.WriteLine(message2);
                }
                    */
/*

}
catch
{
Console.WriteLine("cashed");
}


//

}
}
return Task.FromResult(forecasts);
}
}
*/