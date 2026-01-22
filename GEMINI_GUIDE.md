# Google Gemini Integration Guide

This guide provides step-by-step instructions for integrating Google Gemini API with Azure API Management using OpenAI-compatible endpoints.

## Overview

This integration allows you to:
- Use Google Gemini models through Azure API Management
- Apply the same security, monitoring, and rate limiting policies as Azure OpenAI
- Switch between Azure OpenAI and Google Gemini with minimal code changes
- Manage multiple AI providers through a single gateway

## Prerequisites

1. An Azure subscription
2. Azure API Management instance (deployed via this project)
3. Google Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

## Deployment Steps

### Step 1: Get Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key (keep it secure!)

### Step 2: Configure Environment Variables

Before deploying with `azd up`, set the following environment variables:

```bash
# Enable Gemini integration
azd env set ENABLE_GEMINI true

# Set your Gemini API key (replace with your actual key)
azd env set GEMINI_API_KEY "YOUR_GEMINI_API_KEY_HERE"
```

### Step 3: Deploy the Infrastructure

Deploy the project with Gemini support:

```bash
azd up
```

This will:
- Create or update your Azure API Management instance
- Add a Gemini backend pointing to `https://generativelanguage.googleapis.com/v1beta/openai`
- Store your Gemini API key securely as a named value in APIM
- Apply the Gemini policy for authentication and rate limiting
- Add the Gemini API to your existing product

### Step 4: Verify the Deployment

After deployment, check the outputs:

```bash
azd env get-values
```

Look for:
- `GEMINI_ENABLED=true`
- `GEMINI_API_SUFFIX` (e.g., `gemini-api/gemini`)

## Using the Gemini API

### Endpoint Structure

Your Gemini API will be available at:

```
https://<your-apim-instance>.azure-api.net/gemini-api/gemini/
```

### Example: Chat Completions

#### Using cURL

```bash
curl -X POST "https://<your-apim>.azure-api.net/gemini-api/gemini/chat/completions" \
  -H "Content-Type: application/json" \
  -H "api-key: <your-apim-subscription-key>" \
  -d '{
    "model": "gemini-2.0-flash",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant"},
      {"role": "user", "content": "What is the capital of France?"}
    ],
    "max_tokens": 100
  }'
```

#### Using Python (OpenAI SDK)

```python
from openai import OpenAI

# Configure client to use APIM endpoint
client = OpenAI(
    base_url="https://<your-apim>.azure-api.net/gemini-api/gemini/v1",
    api_key="<your-apim-subscription-key>"
)

response = client.chat.completions.create(
    model="gemini-2.0-flash",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Hello, Gemini!"}
    ]
)

print(response.choices[0].message.content)
```

#### Using JavaScript/Node.js

```javascript
const fetch = require('node-fetch');

async function callGemini() {
  const response = await fetch(
    'https://<your-apim>.azure-api.net/gemini-api/gemini/chat/completions',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': '<your-apim-subscription-key>'
      },
      body: JSON.stringify({
        model: 'gemini-2.0-flash',
        messages: [
          { role: 'system', content: 'You are a helpful assistant' },
          { role: 'user', content: 'Hello, Gemini!' }
        ],
        max_tokens: 100
      })
    }
  );
  
  const data = await response.json();
  console.log(data.choices[0].message.content);
}

callGemini();
```

## Available Gemini Models

Common Gemini models accessible through the OpenAI-compatible endpoint:

- `gemini-2.0-flash` - Fast and efficient for most tasks
- `gemini-1.5-pro` - Advanced reasoning and longer context
- `gemini-1.5-flash` - Balanced performance and speed

Check [Google AI documentation](https://ai.google.dev/models/gemini) for the latest model availability.

## Architecture Details

### How Authentication Works

**Azure OpenAI** (Managed Identity):
```
Client → APIM → Get Managed Identity Token → Azure OpenAI
```

**Google Gemini** (API Key):
```
Client → APIM → Add Bearer Token (API Key) → Google Gemini
```

### Policy Differences

The Gemini policy differs from Azure OpenAI:

1. **No Managed Identity**: Uses stored API key instead
2. **Bearer Token**: API key sent as `Authorization: Bearer <key>`
3. **Different Backend**: Points to Google's endpoint
4. **Same Client Experience**: Clients use the same APIM subscription key

### What APIM Provides

- **Security**: API key hidden from clients
- **Rate Limiting**: 60 requests per minute per subscription (configurable)
- **Monitoring**: All requests logged to Application Insights
- **Token Metrics**: Track usage across providers
- **Circuit Breaker**: Automatic failover (if configured with multiple backends)

## Configuration Files

The Gemini integration consists of these files:

1. **infra/app/apim-gemini.bicep** - Backend and API configuration
2. **infra/app/apim-gemini-policy.xml** - Authentication and rate limiting policy
3. **infra/main.bicep** - Main deployment with Gemini module
4. **infra/main.parameters.json** - Environment variable mapping

## Troubleshooting

### Issue: "Gemini API Key not set"

**Solution**: Ensure you've set the environment variable:
```bash
azd env set GEMINI_API_KEY "your-key-here"
```

### Issue: "401 Unauthorized"

**Possible causes**:
- Invalid Gemini API key
- API key not properly stored in APIM named values
- Subscription key incorrect

**Solution**: 
1. Verify your Gemini API key at Google AI Studio
2. Check APIM named values in Azure Portal
3. Verify your APIM subscription key

### Issue: "429 Too Many Requests"

**Cause**: Rate limit exceeded (default: 60 requests/minute)

**Solution**: Either wait or modify the rate limit in `apim-gemini-policy.xml`:
```xml
<rate-limit-by-key calls="120" renewal-period="60" ... />
```

### Issue: Model not supported

**Cause**: Trying to use a model not available in Gemini's OpenAI compatibility layer

**Solution**: Check [Google's documentation](https://ai.google.dev/gemini-api/docs/openai) for supported models

## Monitoring and Observability

All Gemini requests are logged to Application Insights with:
- Request/response times
- Token usage metrics
- Error rates
- Client IP addresses
- Subscription IDs

View metrics in Azure Portal:
1. Go to your Resource Group
2. Select Application Insights resource
3. Navigate to "Logs" or "Metrics"
4. Query for `geminidemometrics` namespace

## Cost Considerations

- **APIM Costs**: StandardV2 tier (~$0.13/hour + per-call charges)
- **Gemini API Costs**: Based on [Google's pricing](https://ai.google.dev/pricing)
- **Application Insights**: Based on data ingestion volume

## Disabling Gemini

To disable Gemini after deployment:

```bash
azd env set ENABLE_GEMINI false
azd up
```

This will remove the Gemini backend and API from your APIM instance.

## References

- [Microsoft Learn: Import OpenAI-Compatible Google Gemini API](https://learn.microsoft.com/en-us/azure/api-management/openai-compatible-google-gemini-api)
- [Google AI: Gemini OpenAI Compatibility](https://ai.google.dev/gemini-api/docs/openai)
- [Azure APIM: Language Model API Import](https://learn.microsoft.com/en-us/azure/api-management/openai-compatible-llm-api)
- [Azure Samples: AI Gateway](https://github.com/Azure-Samples/AI-Gateway)

## Support

For issues specific to:
- **Azure APIM**: Open an issue in this repository
- **Gemini API**: Refer to [Google AI Studio Support](https://ai.google.dev/docs)
- **OpenAI Compatibility**: Check [Google's compatibility guide](https://ai.google.dev/gemini-api/docs/openai)
