'use strict'
const request = require('request');
const AWS = require('aws-sdk');
const s3 = new AWS.S3({signatureVersion: 'v4'});
const ssm = new AWS.SSM();

let subscriptionKeyPS = process.env['COMPUTER_VISION_SUBSCRIPTION_KEY_PS']
let endpoint = process.env['COMPUTER_VISION_ENDPOINT'] + '/vision/v2.1/analyze'
let topic = process.env['TOPIC_ARN']

const congnitive_params = {
    'visualFeatures': 'Categories,Description,Color,Brands',
    'details': 'Celebrities,Landmarks',
    'language': 'en'
}


const handler = (event, context, callback) => {
   context.callbackWaitsForEmptyEventLoop = false;
   console.log(event)
   const key = event.Records[0].s3.object.key;
   const bucket = event.Records[0].s3.bucket.name;
   const imageUrl = `https://s3.amazonaws.com/${bucket}/${key}`;
   const imageKey = decodeURIComponent(key);
   const uniqueImageKey = imageKey.split('/')[0];
   var params = {Bucket: bucket, Key: key, Expires: 60};
   console.log('Image Details: ', params)
   var url = s3.getSignedUrl('getObject', params);
   console.log('The URL is', url); // expires in 60 seconds
   // Make the request.
   const ps_params = {
    Name: subscriptionKeyPS, 
    WithDecryption: true
  };
  ssm.getParameter(ps_params, function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else   {   
    console.log(data);           // successful response
    var subscriptionKey = data.Parameter.Value
    // Calling Azure Cognitive Service.
    const options = {
    uri: endpoint,
    qs: congnitive_params,
    body: '{"url": ' + '"' + url + '"}',
    headers: {
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key' : subscriptionKey
     }
    }
     request.post(options, (error, response, body) => {
      console.error('error:', error)
      console.log('statusCode:', response && response.statusCode)
      console.log('Original Data',JSON.stringify(JSON.parse(body), null, 2))
      var image_data = JSON.parse(body);
      image_data['imageId']= uniqueImageKey;
      image_data['imageUrl']= imageUrl;
      image_data = JSON.stringify(image_data, null, 2);
      // Create publish parameters
      var sns_params = {
           Message: image_data, /* required */
           TopicArn: topic  
        };
       // Create promise and SNS service object
      var publishDataPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(sns_params).promise();
      // Handle promise's fulfilled/rejected states
      publishDataPromise.then(
          function(data) {
            console.log(`Message ${sns_params.Message} sent to the topic ${sns_params.TopicArn}`);
            console.log("MessageID is " + data.MessageId);
          }).catch(
            function(err) {
            console.error(err, err.stack);
          });
     });
  }
});

};

module.exports = {
  handler
};