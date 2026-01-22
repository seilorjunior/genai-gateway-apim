# Quick Start: Google Gemini with Azure APIM

This is a quick reference for deploying and using Google Gemini through Azure API Management.

## Prerequisites
- Azure subscription
- Azure Developer CLI (`azd`)
- Google Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

## Deploy in 3 Steps

### 1. Get Your Gemini API Key
Visit https://aistudio.google.com/app/apikey and generate an API key.

### 2. Configure and Deploy
```bash
# Login to Azure
azd auth login

# Enable Gemini and set your API key
azd env set ENABLE_GEMINI true
azd env set GEMINI_API_KEY "your-api-key-here"

# Deploy everything
azd up
```

### 3. Get Your APIM Endpoint
After deployment:
```bash
azd env get-values
```

Look for:
- `APIM_ENDPOINT` - Your APIM gateway URL
- `SUBSCRIPTION_KEY` - Your APIM subscription key
- `GEMINI_API_SUFFIX` - The Gemini API path (e.g., `gemini-api/gemini`)

## Make Your First Request

```bash
curl -X POST "https://<APIM_ENDPOINT>/gemini-api/gemini/chat/completions" \
  -H "Content-Type: application/json" \
  -H "api-key: <SUBSCRIPTION_KEY>" \
  -d '{
    "model": "gemini-2.0-flash",
    "messages": [
      {"role": "user", "content": "Hello, Gemini!"}
    ]
  }'
```

## What You Get

✅ **Unified Gateway** - Access Azure OpenAI and Google Gemini through one endpoint  
✅ **Security** - API keys hidden from clients  
✅ **Rate Limiting** - Automatic traffic management  
✅ **Monitoring** - All requests logged to Application Insights  
✅ **OpenAI Compatible** - Use existing OpenAI SDKs  

## Available Models

- `gemini-2.0-flash` - Fast and efficient
- `gemini-1.5-pro` - Advanced reasoning
- `gemini-1.5-flash` - Balanced performance

## Next Steps

- See [GEMINI_GUIDE.md](./GEMINI_GUIDE.md) for detailed documentation
- Check [DOC.md](./DOC.md) for architecture details
- Read [README.md](./README.md) for the full setup guide

## Switching Between Providers

**Azure OpenAI:**
```
POST https://<APIM>/myAPI/openai/deployments/conversation-model/chat/completions
```

**Google Gemini:**
```
POST https://<APIM>/gemini-api/gemini/chat/completions
```

Both use the same APIM subscription key for authentication!

## Disable Gemini

```bash
azd env set ENABLE_GEMINI false
azd up
```

## Support

- Issues: Open an issue in this repository
- Microsoft Learn: https://learn.microsoft.com/azure/api-management/openai-compatible-google-gemini-api
- Google AI: https://ai.google.dev/gemini-api/docs/openai
