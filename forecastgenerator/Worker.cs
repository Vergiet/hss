using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using System.Text.Json;
using ForecastGenerator.Data;

namespace ForecastGenerator
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IHostApplicationLifetime _hostApplicationLifetime;



        public Worker(IHostApplicationLifetime hostApplicationLifetime, ILogger<Worker> logger)
        {
            _hostApplicationLifetime = hostApplicationLifetime;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var connectionString = "Endpoint=sb://aks-event-hub.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=W0ip33R6uMIw2NjTUGkxHgjKYWR1FmZPkk8xCSB4f1g=";
            var eventHubName = "eventhub01";

            await using (var producer = new EventHubProducerClient(connectionString, eventHubName))
            {

                var ForecastService = new WeatherForecastService();
                var forecasts = await ForecastService.GetForecastAsync(DateTime.Now);


                using EventDataBatch eventBatch = await producer.CreateBatchAsync();

                foreach (var forecast in forecasts)
                {
                    /*
                    Message msg = new Message
                    {
                        date = DateTime.Now,
                        text = Guid.NewGuid().ToString(),
                    };
                    */
                    var message = JsonSerializer.Serialize(forecast);
                    // var message = string.Format("{0} > Sending message: {1}", DateTime.Now, Guid.NewGuid().ToString());
                    eventBatch.TryAdd(new EventData(Encoding.ASCII.GetBytes(message)));
                    _logger.LogInformation(message);
                };

                await producer.SendAsync(eventBatch);
                //Thread.Sleep(200);
                await Task.Delay(200, stoppingToken);

            };

            _hostApplicationLifetime.StopApplication();

            /*

            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                await Task.Delay(1000, stoppingToken);
            }
            */
        }
    }
}
