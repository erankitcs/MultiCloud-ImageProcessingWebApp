resource "aws_api_gateway_rest_api" "imagelenseapi" {
  name        = "imagelenseApi"
  description = "Image Analyser API for web application."
}

resource "aws_api_gateway_resource" "imagelenseapi_res" {
   rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
   parent_id   = aws_api_gateway_rest_api.imagelenseapi.root_resource_id
   path_part   = "presigneds3url"
}

resource "aws_api_gateway_method" "presigneds3url_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.imagelenseapi_res.id
  rest_api_id   = aws_api_gateway_rest_api.imagelenseapi.id
  request_parameters = {
    "method.request.querystring.filename" = true,
    "method.request.querystring.filetype" = true

  }
}

resource "aws_api_gateway_method" "presigneds3url_option" {
  rest_api_id   = aws_api_gateway_rest_api.imagelenseapi.id
  resource_id   = aws_api_gateway_resource.imagelenseapi_res.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "presigneds3url_lambda" {
   rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
   resource_id = aws_api_gateway_resource.imagelenseapi_res.id
   http_method = aws_api_gateway_method.presigneds3url_get.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.presigneds3url.invoke_arn
}

resource "aws_api_gateway_integration" "presigneds3url_option" {
  rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
  resource_id = aws_api_gateway_resource.imagelenseapi_res.id
  http_method = aws_api_gateway_method.presigneds3url_option.http_method
  type = "MOCK"
}

resource "aws_api_gateway_method_response" "presigneds3url_option" {
  depends_on = [aws_api_gateway_method.presigneds3url_option]
  rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
  resource_id = aws_api_gateway_resource.imagelenseapi_res.id
  http_method = aws_api_gateway_method.presigneds3url_option.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "presigneds3url_option" {
  depends_on = [aws_api_gateway_integration.presigneds3url_option, aws_api_gateway_method_response.presigneds3url_option]
  rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
  resource_id = aws_api_gateway_resource.imagelenseapi_res.id
  http_method = aws_api_gateway_method.presigneds3url_option.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'", # replace with hostname of frontend (CloudFront)
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET, POST'" # remove or add HTTP methods as needed
  }
}


resource "aws_api_gateway_deployment" "dev" {
   depends_on = [
     aws_api_gateway_integration.presigneds3url_lambda,
   ]
   rest_api_id = aws_api_gateway_rest_api.imagelenseapi.id
   stage_name  = "dev"
}