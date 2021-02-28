## Multi Cloud Image Processing Web Application

In this project, we would be creating a multi cloud image processing web application.

### Cloud Providers
1. AWS
2. Azure
3. GCP

### AWS 
We would be using AWS for image storage and  stitching togather web application interaction with other services.
- AWS S3 for Image Storage and Lambda Code Artificats.
- AWS Lambda for eventing the image processing application and providing secure access to S3 bucket.
- AWS API Gateway will be publishing the API for Web Application.

### Azure
We would be using Azure for image analysis.
- Azure Conginitive Service ( Computer Vision API) will be used for image processing.

### GCP
GCP would be used for realtime database.
- GCP Firestore for realtime database.

### Architecure
![Screenshot](MultiCloud-ImageLense.png)

### Screen
![Screenshot](MultiCloud-ImageLense-screen.PNG)

### Improvements
1. User SingUp and SignIn.
2. Authenticate API Gateway.
3. Expose Image to user via Cloud Front with Authentication.
4. Blue/Green Deployment for Lambda Function.
5. Elastic Beanstalk for NodeJs Front End Application.