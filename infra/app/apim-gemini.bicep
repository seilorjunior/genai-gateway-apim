param name string

@description('Resource name to uniquely identify the Gemini API within the API Management service instance')
@minLength(1)
param apiName string

@description('Azure Application Insights Name')
param applicationInsightsName string

@description('Google Gemini API Key')
@secure()
param geminiApiKey string

@description('Gemini API base URL')
param geminiBaseUrl string = 'https://generativelanguage.googleapis.com/v1beta/openai'

param productName string = 'APIM-AI_APIS'

var subscriptionId = az.subscription().subscriptionId
var apiSuffix = '${apiName}/gemini'

resource apimService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: name
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' existing = if (!empty(applicationInsightsName)) {
  name: 'app-insights-logger'
  parent: apimService
}

// Creating a backend for Gemini
resource geminiBackend 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimService
  name: 'gemini-backend'
  properties: {
    url: geminiBaseUrl
    protocol: 'http'
    description: 'Google Gemini OpenAI-compatible API backend'
  }
}

// Create named value for Gemini API key (secure)
resource geminiApiKeyValue 'Microsoft.ApiManagement/service/namedValues@2023-09-01-preview' = {
  parent: apimService
  name: 'gemini-api-key'
  properties: {
    displayName: 'gemini-api-key'
    secret: true
    value: geminiApiKey
  }
}

// Create an API in the API Management service for Gemini
resource geminiApi 'Microsoft.ApiManagement/service/apis@2020-06-01-preview' = {
  parent: apimService
  name: apiName
  properties: {
    displayName: 'Google Gemini OpenAI Compatible API'
    apiType: 'http'
    path: apiSuffix
    format: 'openapi+json-link'
    value: 'https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference/preview/2024-03-01-preview/inference.json'
    subscriptionKeyParameterNames: {
      header: 'api-key'
    }
  }
  resource apimDiagnostics 'diagnostics@2023-05-01-preview' = {
    name: 'applicationinsights'
    properties: {
      loggerId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ApiManagement/service/${apimService.name}/loggers/${apimLogger.name}'
      metrics: true
    }
  }
}

// Policy for Gemini API - uses Bearer token authentication instead of managed identity
var geminiPolicyXml = loadTextContent('./apim-gemini-policy.xml')

resource geminiApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2020-06-01-preview' = {
  parent: geminiApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: geminiPolicyXml
  }
}

// Get existing product
resource product 'Microsoft.ApiManagement/service/products@2020-06-01-preview' existing = {
  parent: apimService
  name: productName
}

// Create PRODUCT-API association - add Gemini API to the product
resource productGeminiApi 'Microsoft.ApiManagement/service/products/apis@2020-06-01-preview' = {
  parent: product
  name: geminiApi.name
}

output apiSuffix string = apiSuffix
output backendName string = geminiBackend.name
