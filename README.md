# Azure API Management (APIM) - Azure Open AI & Google Gemini Sample

This sample project demonstrates how to use Azure API Management with Azure OpenAI and optionally Google Gemini to create a simple chatbot. The project showcases how to integrate multiple AI providers through a unified API gateway.

## Quick Start

### Prerequisites

- Install [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- Install [Node.js](https://nodejs.org/en/download/)

### 1. Deploying the project

Run the following command to login to `azd`:

```bash
azd auth login
```

Deploy the project to Azure by running the following command:

```bash
azd up
```

You'll be asked to select:
- An environment name. For example, `apim-genai`. This value serves as a prefix for naming resources in your deployment.
- An Azure subscription.
- An Azure location.
- An `apimLocation`. Enter a value of `koreacentral`. The new API Management SKUv2 tier is used in this demo which is supported in the [following regions](https://learn.microsoft.com/azure/api-management/v2-service-tiers-overview#supported-regions).

### 1.1 (Optional) Enable Google Gemini Integration

To enable Google Gemini API alongside Azure OpenAI:

1. **Get your Gemini API Key:**
   - Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Create or sign in to your account
   - Generate an API key

2. **Set environment variables before running `azd up`:**
   ```bash
   azd env set ENABLE_GEMINI true
   azd env set GEMINI_API_KEY "your-gemini-api-key-here"
   ```

3. **Deploy with Gemini enabled:**
   ```bash
   azd up
   ```

The Gemini API will be available at: `https://<your-apim>.azure-api.net/gemini-api/gemini/`

**Note:** Google Gemini uses OpenAI-compatible endpoints, allowing you to use the same client SDKs with minimal changes. See the [Microsoft Learn article](https://learn.microsoft.com/en-us/azure/api-management/openai-compatible-google-gemini-api) for more details.

### Inspect environment variables

After running the `azd up` command, an environment file will be generated for you at `src/.env`. Here's some of the key information added to the `.env` file.

```bash
APIM_ENDPOINT="<Your APIM Endpoint>"
API_SUFFIX="<Your API Suffix>"
API_VERSION="<Your API Version>"
DEPLOYMENT_ID="<Your Deployment Name>"
SUBSCRIPTION_KEY="<Your Subscription Key>"
```

**Finding values using the Azure portal:**

If you'd like to find the values in the `.env` yourself, follow these steps:
    
|Value  |Instruction  |
|---------|---------|
| APIM_ENDPOINT | Navigate to portal.azure.com -> Select rg -> Select APIM instance -> Go to Overview -> Copy Gateway URL |
| API_SUFFIX | Navigate to portal.azure.com -> Select rg -> Select APIM instance -> Navigate to APIs/APIs -> open myAPI -> Go to settings -> Copy API URL suffix |
| API_VERSION | Navigate to <https://learn.microsoft.com/azure/ai-services/openai/reference#completions>, Copy most recent Supported versions = 2024-02-01 |
| DEPLOYMENT_ID | Navigate to portal.azure.com -> Select rg -> Select 1st OpenAI instance -> Go to Resource Management/Mode deployments -> Click on Manage Deployments to open Azure AI Studio -> Copy Deployment name |
|SUBSCRIPTION_KEY     | Navigate to portal.azure.com -> Select rg -> select APIM instance -> Go to APIs/Subscriptions -> Click show/hide keys on first row (Built-in all-access) -> copy Primary key        |





## 2. Run the project locally

Once the Azure services have been deployed, you can run the app by running the below commands:

```bash
cd src
npm install
npm start
```

This will start the app on `http://localhost:3000` and the API is available at `http:localhost:1337`.

## 3. Deprovision the project

Once you're done, you can remove all deployed resources using the following command:

```bash
azd down --purge
```

The preceding command removes all provisoned resources. The `--purge` hard deletes all resources.

> NOTE: Some resources on Azure are only soft deleted for performance reasons and can be retrieved. By using `--purge` resources are hard deleted and cannot be retrieved.


## What's in this repo

|What  |Description  | Link |
|---------|---------|--|
|Frontend     | a frontend consisting of a `index.html` and `app.js` | [Link](./src/web/)        |
|Backend     | A backend written in Node.js and Express framework | [Link](./src/api/)        |
|Bicep     | Bicep files containing the needed information to deploy resources and configure them as needed        | [Link](./infra) |

## Demo

![App running](./apim.png)

## Documentation

The documentation for this project is available in the [DOC.md](./DOC.md) file.
