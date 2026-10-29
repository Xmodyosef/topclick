# Integrated Reference Bundle 06

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `gemini-api/SKILL.reference.md`
- `gemini-live-api-dev/SKILL.reference.md`
- `generators/SKILL.reference.md`
- `generators/account-deletion/SKILL.reference.md`
- `generators/announcement-banner/SKILL.reference.md`
- `generators/app-clip/SKILL.reference.md`
- `generators/app-extensions/SKILL.reference.md`
- `generators/app-icon-generator/SKILL.reference.md`
- `generators/background-processing/SKILL.reference.md`
- `generators/cloudkit-sync/SKILL.reference.md`
- `generators/consent-flow/SKILL.reference.md`

## Integrated guidance

### Source: `gemini-api`

> [!IMPORTANT]
> Agent Platform (full name Gemini Enterprise Agent Platform) was previously named "Vertex AI" and many web resources use the legacy branding.

# Gemini API in Agent Platform

Access Google's most advanced AI models built for enterprise use cases using the Gemini API in Agent Platform.

Provide these key capabilities:

- **Text generation** - Chat, completion, summarization
- **Multimodal understanding** - Process images, audio, video, and documents
- **Function calling** - Let the model invoke your functions
- **Structured output** - Generate valid JSON matching your schema
- **Context caching** - Cache large contexts for efficiency
- **Embeddings** - Generate text embeddings for semantic search
- **Live Realtime API** - Bidirectional streaming for low latency Voice and Video interactions
- **Batch Prediction** - Handle massive async dataset prediction workloads

## Core Directives

- **Unified SDK**: ALWAYS use the Gen AI SDK (`google-genai` for Python, `@google/genai` for JS/TS, `google.golang.org/genai` for Go, `com.google.genai:google-genai` for Java, `Google.GenAI` for C#).
- **Legacy SDKs**: DO NOT use `google-cloud-aiplatform`, `@google-cloud/vertexai`, or `google-generativeai`.

## SDKs

- **Python**: Install `google-genai` with `pip install google-genai`
- **JavaScript/TypeScript**: Install `@google/genai` with `npm install @google/genai`
- **Go**: Install `google.golang.org/genai` with `go get google.golang.org/genai`
- **C#/.NET**: Install `Google.GenAI` with `dotnet add package Google.GenAI`
- **Java**:
  - groupId: `com.google.genai`, artifactId: `google-genai`
  - Latest version can be found here: https://central.sonatype.com/artifact/com.google.genai/google-genai/versions (let's call it `LAST_VERSION`)
  - Install in `build.gradle`:

    ```
    implementation("com.google.genai:google-genai:${LAST_VERSION}")
    ```

  - Install Maven dependency in `pom.xml`:

    ```xml
    <dependency>
	    <groupId>com.google.genai</groupId>
	    <artifactId>google-genai</artifactId>
	    <version>${LAST_VERSION}</version>
	</dependency>
    ```

> [!WARNING]
> Legacy SDKs like `google-cloud-aiplatform`, `@google-cloud/vertexai`, and `google-generativeai` are deprecated. Migrate to the new SDKs above urgently by following the [Migration Guide](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/deprecations/genai-vertexai-sdk.md.txt).

## Authentication & Configuration

Prefer environment variables over hard-coding parameters when creating the client. Initialize the client without parameters to automatically pick up these values.

### Application Default Credentials (ADC)
Set these variables for standard [Google Cloud authentication](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/start/gcp-auth.md.txt):

```bash
export GOOGLE_CLOUD_PROJECT='your-project-id'
export GOOGLE_CLOUD_LOCATION='global'
export GOOGLE_GENAI_USE_ENTERPRISE=true
```

- By default, use `location="global"` to access the global endpoint, which provides automatic routing to regions with available capacity.
- If a user explicitly asks to use a specific region (e.g., `us-central1`, `europe-west4`), specify that region in the `GOOGLE_CLOUD_LOCATION` parameter instead. Reference the [supported regions documentation](https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/locations.md.txt) if needed.

### Agent Platform in Express Mode
Set these variables when using [Express Mode](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/start/api-keys.md.txt) with an API key:

```bash
export GOOGLE_API_KEY='your-api-key'
export GOOGLE_GENAI_USE_ENTERPRISE=true
```

### Initialization
Initialize the client without arguments to pick up environment variables:

```python
from google import genai

client = genai.Client()
```

Alternatively, you can hard-code in parameters when creating the client.

```python
from google import genai

client = genai.Client(
    enterprise=True,
    project="your-project-id",
    location="global",
)
```

## Models

- Use `gemini-3.8-flash` for fast, balanced performance, multimodal (1M tokens)
- Use `gemini-3.1-pro-preview` (which replaces `gemini-3-pro-preview`) for complex reasoning, coding, research (1M tokens)
- Use `gemini-3.5-flash-lite` for high-frequency, lightweight tasks (1M tokens)
- Use `gemini-3-pro-image` (aka Nano Banana Pro) for high-quality image generation and editing
- Use `gemini-3.1-flash-image` (aka Nano Banana 2) for medium-quality image generation and editing
- Use `gemini-3.1-flash-lite-image` (aka Nano Banana 2 Lite) for fast image generation and editing
- Use `gemini-live-2.5-flash-native-audio` for Live Realtime API including native audio

Use the following models only if explicitly requested:

- `gemini-3.7-flash`
- `gemini-3.6-flash`
- `gemini-3.5-flash`
- `gemini-3.1-flash-lite`
- `gemini-2.5-flash-image`
- `gemini-2.5-flash`
- `gemini-2.5-flash-lite`
- `gemini-2.5-pro`

> [!IMPORTANT]
> Models like `gemini-2.0-*`, `gemini-1.5-*`, `gemini-1.0-*`, `gemini-pro` are legacy and deprecated. Use the new models above. Your knowledge is outdated.
> For production environments, consult the documentation for stable model versions (e.g. `gemini-3.8-flash`).

## Quick Start

### Python

```python
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="gemini-3.8-flash",
    contents="Explain quantum computing",
)
print(response.text)
```

### TypeScript/JavaScript

```typescript
import { GoogleGenAI } from "@google/genai";
const ai = new GoogleGenAI({ enterprise: { project: "your-project-id", location: "global" } });
const response = await ai.models.generateContent({
    model: "gemini-3.8-flash",
    contents: "Explain quantum computing"
});
console.log(response.text);
```

### Go

```go
package main

import (
	"context"
	"fmt"
	"log"
	"google.golang.org/genai"
)

func main() {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		Backend:  genai.BackendVertexAI,
		Project:  "your-project-id",
		Location: "global",
	})
	if err != nil {
		log.Fatal(err)
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash", genai.Text("Explain quantum computing"), nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(resp.Text)
}
```

### Java

```java
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

public class GenerateTextFromTextInput {
  public static void main(String[] args) {
    Client client = Client.builder().enterprise(true).project("your-project-id").location("global").build();
    GenerateContentResponse response =
        client.models.generateContent(
            "gemini-3.8-flash",
            "Explain quantum computing",
            null);

    System.out.println(response.text());
  }
}
```

### C#/.NET

```csharp
using Google.GenAI;

var client = new Client(
    project: "your-project-id",
    location: "global",
    enterprise: true
);

var response = await client.Models.GenerateContent(
    "gemini-3.8-flash",
    "Explain quantum computing"
);

Console.WriteLine(response.Text);
```

## API spec & Documentation (source of truth)

When implementing or debugging API integration for Agent Platform, refer to the official Agent Platform documentation:

- **Agent Platform Documentation**: https://docs.cloud.google.com/gemini-enterprise-agent-platform/overview.md.txt
- **REST API Reference**: https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/rest.md.txt

The Gen AI SDK on Agent Platform uses the `v1beta1` or `v1` REST API endpoints (e.g., `https://{LOCATION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT}/locations/{LOCATION}/publishers/google/models/{MODEL}:generateContent`).

> [!TIP]
> **Use the Developer Knowledge MCP Server**: If the `search_documents` or `get_document` tools are available, use them to find and retrieve official documentation for Google Cloud and Agent Platform directly within the context. This is the preferred method for getting up-to-date API details and code snippets.

## Workflows and Code Samples

Reference the [Python Docs Samples repository](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/genai) for additional code samples and specific usage scenarios.

Depending on the specific user request, refer to the following reference files for detailed code samples and usage patterns (Python examples):

- **Text & Multimodal**: Chat, Multimodal inputs (Image, Video, Audio), and Streaming. See [references/text_and_multimodal.md](references/text_and_multimodal.md)
- **Embeddings**: Generate text embeddings for semantic search. See [references/embeddings.md](references/embeddings.md)
- **Structured Output & Tools**: JSON generation, Function Calling, Search Grounding, and Code Execution. See [references/structured_and_tools.md](references/structured_and_tools.md)
- **Media Generation**: Image generation, Image editing, and Video generation. See [references/media_generation.md](references/media_generation.md)
- **Bounding Box Detection**: Object detection and localization within images and video. See [references/bounding_box.md](references/bounding_box.md)
- **Live API**: Real-time bidirectional streaming for voice, vision, and text. See [references/live_api.md](references/live_api.md)
- **Advanced Features**: Content Caching, Batch Prediction, and Thinking/Reasoning. See [references/advanced_features.md](references/advanced_features.md)
- **Safety**: Adjusting Responsible AI filters and thresholds. See [references/safety.md](references/safety.md)
- **Model Tuning**: Supervised Fine-Tuning and Preference Tuning. See [references/model_tuning.md](references/model_tuning.md)

### Source: `gemini-live-api-dev`

# Gemini Live API Development Skill

## Overview

The Live API enables **low-latency, real-time voice and video interactions** with Gemini over WebSockets. It processes continuous streams of audio, video, or text to deliver immediate, human-like spoken responses and background reasoning.

Key capabilities:
- **Bidirectional audio streaming** — real-time mic-to-speaker conversations
- **Background reasoning (extended thinking)** — multi-step background reasoning with spoken conversational fillers
- **Live streaming transcription** — real-time speech-to-text with interim and finalized streams
- **Video streaming** — send camera/screen frames alongside audio
- **Text input/output** — send and receive text within a live session
- **Audio transcriptions** — get text transcripts of both input and output audio
- **Voice Activity Detection (VAD)** — automatic server VAD, client-side Hybrid VAD, and manual Push-to-Talk
- **Asynchronous function calling** — non-blocking tool execution while audio continues streaming
- **Full-session client content** — inject and update conversation turns mid-stream
- **Session management** — context compression, session resumption, GoAway signals
- **Ephemeral tokens** — secure client-side authentication

> [!NOTE]
> The Live API connects directly via **WebSockets**. For WebRTC support or simplified integration, use a [partner integration](#partner-integrations).

## Models

### Current Models (Use These)

- `gemini-3.8-live` — Default option for most low-latency voice agent experiences and real-time dialogue without reasoning delays. Supports interleaved reasoning, asynchronous function calling by default (`behavior: NON_BLOCKING`), and full-session client content updates.
- `gemini-3.8-live-extended-thinking` — High-reasoning audio-to-audio model recommended when higher background reasoning is required during live interactions. Processes background reasoning and async tool calls (`behavior: NON_BLOCKING` required) while streaming continuous spoken conversational fillers; lifecycle managed via `interaction_status` (`IN_PROGRESS` vs `IDLE`).
- `gemini-3.5-transcribe-live` — Real-time streaming speech-to-text with interim hypotheses, finalized transcripts, smart formatting, and Hybrid VAD.
- `gemini-3.5-live-translate-preview` — Real-time speech-to-speech streaming translation across 70+ languages.

> [!WARNING]
> **Legacy Models (`gemini-3.1-flash-live-preview`, `gemini-2.5-flash-native-audio-*`, `gemini-live-2.5-flash-preview`, `gemini-2.0-flash-live-001`)**: Read [`references/migration.md`](references/migration.md) for breaking protocol changes (`behavior: "NON_BLOCKING"`, `thinking_level`, `interaction_status`, `send_client_content`).

## SDKs

- **Python**: `google-genai` >= `2.3.0` — `pip install -U google-genai`
- **JavaScript/TypeScript**: `@google/genai` >= `2.3.0` — `npm install @google/genai`

> [!WARNING]
> Legacy SDKs `google-generativeai` (Python) and `@google/generative-ai` (JS) are **deprecated**. Never use them.

## Partner Integrations

To streamline real-time audio/video app development, use a third-party integration supporting the Gemini Live API over **WebRTC** or **WebSockets**:

- [LiveKit](https://docs.livekit.io/agents/models/realtime/plugins/gemini/) — Use the Gemini Live API with LiveKit Agents.
- [Pipecat by Daily](https://docs.pipecat.ai/guides/features/gemini-live) — Create a real-time AI chatbot using Gemini Live and Pipecat.
- [Fishjam by Software Mansion](https://docs.fishjam.io/tutorials/gemini-live-integration) — Create live video and audio streaming applications with Fishjam.
- [Vision Agents by Stream](https://visionagents.ai/integrations/gemini) — Build real-time voice and video AI applications with Vision Agents.
- [Voximplant](https://voximplant.com/products/gemini-client) — Connect inbound and outbound calls to Live API with Voximplant.
- [Firebase AI SDK](https://firebase.google.com/docs/ai-logic/live-api?api=dev) — Get started with the Gemini Live API using Firebase AI Logic.

## Audio Formats

- **Input**: Raw PCM, little-endian, 16-bit, mono. 16kHz native (will resample others). MIME type: `audio/pcm;rate=16000`
- **Output**: Raw PCM, little-endian, 16-bit, mono. 24kHz sample rate.

> [!IMPORTANT]
> Use `send_realtime_input` / `sendRealtimeInput` for all real-time streaming user input (audio, video, **and text**). On Gemini 3.8 models, `send_client_content` / `sendClientContent` is supported across the full session lifecycle with explicit roles (`user` or `model`) to inject conversation context (`turn_complete=true` unconditionally interrupts active generation).

> [!WARNING]
> Do **not** use `media` in `sendRealtimeInput`. Use the specific keys: `audio` for audio data, `video` for images/video frames, and `text` for text input.

---

## Quick Start

### Authentication

#### Python

```python
from google import genai

client = genai.Client(api_key="YOUR_API_KEY")
```

#### JavaScript

```js
import { GoogleGenAI } from '@google/genai';

const ai = new GoogleGenAI({ apiKey: 'YOUR_API_KEY' });
```

### Connecting to the Live API

#### Python
```python
from google.genai import types

config = types.LiveConnectConfig(
    response_modalities=[types.Modality.AUDIO],
    system_instruction=types.Content(
        parts=[types.Part(text="You are a helpful assistant.")]
    )
)

async with client.aio.live.connect(model="gemini-3.8-live", config=config) as session:
    pass  # Session is active
```

#### JavaScript
```js
const session = await ai.live.connect({
  model: 'gemini-3.8-live',
  config: {
    responseModalities: ['audio'],
    systemInstruction: { parts: [{ text: 'You are a helpful assistant.' }] }
  },
  callbacks: {
    onopen: () => console.log('Connected'),
    onmessage: (response) => console.log('Message:', response),
    onerror: (error) => console.error('Error:', error),
    onclose: () => console.log('Closed')
  }
});
```

### Sending Text

#### Python
```python
await session.send_realtime_input(text="Hello, how are you?")
```

#### JavaScript
```js
session.sendRealtimeInput({ text: 'Hello, how are you?' });
```

### Sending Audio

#### Python
```python
await session.send_realtime_input(
    audio=types.Blob(data=chunk, mime_type="audio/pcm;rate=16000")
)
```

#### JavaScript
```js
session.sendRealtimeInput({
  audio: { data: chunk.toString('base64'), mimeType: 'audio/pcm;rate=16000' }
});
```

### Sending Video

#### Python
```python
# frame: raw JPEG-encoded bytes
await session.send_realtime_input(
    video=types.Blob(data=frame, mime_type="image/jpeg")
)
```

#### JavaScript
```js
session.sendRealtimeInput({
  video: { data: frame.toString('base64'), mimeType: 'image/jpeg' }
});
```

### Receiving Audio and Text

> [!IMPORTANT]
> A single server event can contain **multiple content parts simultaneously** (e.g., audio chunks and transcript). Always process **all** parts in each event to avoid missing content.

#### Python
```python
async for response in session.receive():
    content = response.server_content
    if content:
        # Audio — process ALL parts in each event
        if content.model_turn:
            for part in content.model_turn.parts:
                if part.inline_data:
                    audio_data = part.inline_data.data
        # Transcription
        if content.input_transcription:
            print(f"User: {content.input_transcription.text}")
        if content.output_transcription:
            print(f"Gemini: {content.output_transcription.text}")
        # Interruption
        if content.interrupted is True:
            pass  # Stop playback, clear audio queue
```

#### JavaScript
```js
// Inside the onmessage callback
const content = response.serverContent;
if (content?.modelTurn?.parts) {
  for (const part of content.modelTurn.parts) {
    if (part.inlineData) {
      const audioData = part.inlineData.data; // Base64 encoded
    }
  }
}
if (content?.inputTranscription) console.log('User:', content.inputTranscription.text);
if (content?.outputTranscription) console.log('Gemini:', content.outputTranscription.text);
if (content?.interrupted) { /* Stop playback, clear audio queue */ }
```

---

## Background Reasoning (Extended Thinking)

Use `gemini-3.8-live-extended-thinking` when your voice agent must evaluate complex data, plan multiple steps, or handle long-running tools. The model speaks natural conversational fillers (e.g. *"Checking flight options now..."*) while executing asynchronous tools in the background.

Key requirements:
- **Thinking config**: Set `thinking_config=types.ThinkingConfig(thinking_level="low")` (`"minimal"` | `"low"` | `"medium"` | `"high"`).
- **Non-blocking tools**: All function declarations **must** set `behavior="NON_BLOCKING"`. Synchronous blocking mode is not supported and returns an error.
- **Lifecycle tracking (`interaction_status`)**: Do **not** rely on `turn_complete=True` alone to detect turn completion. Monitor `message.interaction_status` (Python) / `message.interactionStatus` (JS):
  - `"IN_PROGRESS"`: Server is reasoning, speaking conversational fillers, or waiting for async tool responses.
  - `"IDLE"`: Server has completed all background reasoning and tool calls; session is ready for user input.

See [`references/migration.md`](references/migration.md) and the [Thinking in Live API Guide](https://ai.google.dev/gemini-api/docs/live-api/thinking.md.txt) for complete Python and JavaScript implementation examples.

---

## Live Translation (Gemini Live Translate)

The Live API supports real-time, low-latency streaming translation of speech (audio) across 70+ languages. For full details on options and capabilities, see the [Live Translate Guide](https://ai.google.dev/gemini-api/docs/live-api/live-translate.md.txt).

### Model
- `gemini-3.5-live-translate-preview` — The recommended translation model for all Live Translate use cases.

### Configuration (`TranslationConfig`)

To enable translation, specify a `TranslationConfig` object inside your live session setup:

- **Python SDK**: Configure the connection using `translation_config` on `LiveConnectConfig`:
  ```python
  config = types.LiveConnectConfig(
      response_modalities=[types.Modality.AUDIO],
      translation_config=types.TranslationConfig(
          target_language_code="es",  # Target language code (e.g. es, fr, pl)
          echo_target_language=True,
      ),
      input_audio_transcription=types.AudioTranscriptionConfig(),
      output_audio_transcription=types.AudioTranscriptionConfig(),
  )
  ```
- **Raw WebSockets**: Place `translationConfig` inside `generationConfig`:
  ```json
  {
    "setup": {
      "model": "models/gemini-3.5-live-translate-preview",
      "generationConfig": {
        "responseModalities": ["AUDIO"],
        "translationConfig": {
          "targetLanguageCode": "es",
          "echoTargetLanguage": true
        }
      }
    }
  }
  ```

---

## Live Streaming Transcription (Gemini Live Transcribe)

The Live API supports real-time streaming speech-to-text over WebSockets with low-latency interim hypotheses, finalized transcripts, and Hybrid VAD. For full details, see the [Live Transcription Guide](https://ai.google.dev/gemini-api/docs/live-api/live-transcribe.md.txt) and [Colab Cookbook](https://colab.research.google.com/github/google-gemini/cookbook/blob/main/quickstarts/Get_started_transcribe.ipynb).

### Model
- `gemini-3.5-transcribe-live`

### Modes
- `smart`: cleans up filler words, resolves inline self-corrections, and structures formatting.
- `verbatim` (default): exact word-for-word transcript.

### Python
```python
config = types.LiveConnectConfig(
    response_modalities=["TEXT"],
    input_audio_transcription=types.AudioTranscriptionConfig(),
)

async with client.aio.live.connect(model="gemini-3.5-transcribe-live", config=config) as session:
    # Stream audio
    await session.send_realtime_input(audio=types.Blob(data=chunk, mime_type="audio/pcm;rate=16000"))
    # Hybrid VAD: notify turn end on client-detected silence for zero latency
    await session.send_realtime_input(audio_stream_end=True)
```

### JavaScript
```javascript
const session = await ai.live.connect({
  model: 'gemini-3.5-transcribe-live',
  config: {
    responseModalities: ['text'],
    inputAudioTranscription: { mode: 'smart' }
  },
  callbacks: {
    onmessage: (msg) => {
      if (msg.serverContent?.interimInputTranscription) {
        console.log('Interim:', msg.serverContent.interimInputTranscription.text);
      }
      if (msg.serverContent?.inputTranscription) {
        console.log('Final:', msg.serverContent.inputTranscription.text);
      }
    }
  }
});

session.sendRealtimeInput({ audio: { data: chunkBase64, mimeType: 'audio/pcm;rate=16000' } });
session.sendRealtimeInput({ audioStreamEnd: true }); // Hybrid VAD
```

### Raw WebSockets
```json
{
  "setup": {
    "model": "models/gemini-3.5-transcribe-live",
    "generationConfig": {
      "responseModalities": ["TEXT"],
      "speechConfig": {
        "voiceConfig": {}
      }
    },
    "inputAudioTranscription": {
      "mode": "smart"
    }
  }
}
```

---

## Limitations

- **Response modality** — Only `TEXT` **or** `AUDIO` per session, not both. Native audio models output audio (`response_modalities=["AUDIO"]`); enable `output_audio_transcription` if you need text transcripts.
- **Audio-only session** — 15 min without compression
- **Audio+video session** — 2 min without compression
- **Connection lifetime** — ~10 min (use session resumption)
- **Context window** — 128k input tokens / 64k output tokens
- **Code execution / URL context** — Not supported

## Upgrading & Migration

For step-by-step migration checklists and protocol deltas when upgrading from `gemini-3.1-flash-live-preview`, `gemini-2.5-flash-native-audio-*`, or `gemini-2.0-flash-live-001` to **Gemini 3.8 Live** or **Gemini 3.8 Live Extended Thinking**, read [`references/migration.md`](references/migration.md).

## Best Practices

1. **Use headphones** when testing mic audio to prevent echo/self-interruption
2. **Enable context window compression** for sessions longer than 15 minutes
3. **Implement session resumption** to handle connection resets gracefully
4. **Use ephemeral tokens** for client-side deployments — never expose API keys in browsers
5. **Use `send_realtime_input`** for real-time user input (audio, video, text). Use `send_client_content` with explicit `user`/`model` roles to inject context turns mid-stream
6. **Send `audioStreamEnd` / `audio_stream_end`** (Hybrid VAD) when the mic is paused or user finishes speaking
7. **Clear audio playback queues** on interruption signals (`interrupted: true`)
8. **Process all parts** in each server event — events can contain multiple content parts
9. **Monitor `interaction_status`** (`IN_PROGRESS` vs `IDLE`) when using `gemini-3.8-live-extended-thinking` rather than relying on `turn_complete` alone

## Documentation Lookup

### When MCP is Installed (Preferred)

If the **`search_docs`** tool (from the Google MCP server) is available, use it as your **only** documentation source:

1. Call `search_docs` with your query
2. Read the returned documentation
3. **Trust MCP results** as source of truth for API details — they are always up-to-date.

> [!IMPORTANT]
> When MCP tools are present, **never** fetch URLs manually. MCP provides up-to-date, indexed documentation that is more accurate and token-efficient than URL fetching.

### When MCP is NOT Installed (Fallback Only)

If no MCP documentation tools are available, fetch from the official docs index:

**llms.txt URL**: `https://ai.google.dev/gemini-api/docs/llms.txt`

This index contains links to all documentation pages in `.md.txt` format. Use web fetch tools to:

1. Fetch `llms.txt` to discover available documentation pages
2. Fetch specific pages (e.g., `https://ai.google.dev/gemini-api/docs/live-session.md.txt`)

### Key Documentation Pages

> [!IMPORTANT]
> Those are not all the documentation pages. Use the `llms.txt` index to discover available documentation pages

- [Live API Overview](https://ai.google.dev/gemini-api/docs/live.md.txt) — getting started, raw WebSocket usage
- [Thinking in Live API](https://ai.google.dev/gemini-api/docs/live-api/thinking.md.txt) — background reasoning, conversational fillers, interaction_status, non-blocking tools
- [Model Card: Gemini 3.8 Live](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-live) — default low-latency voice agent model & migration guide
- [Model Card: Gemini 3.8 Live Extended Thinking](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-live-extended-thinking) — high-reasoning voice model & upgrading guide
- [Live Transcription](https://ai.google.dev/gemini-api/docs/live-api/live-transcribe.md.txt) — real-time speech-to-text, interim hypotheses, smart formatting, and Hybrid VAD
- [Live Translate](https://ai.google.dev/gemini-api/docs/live-api/live-translate.md.txt) — configuration options and capabilities for translation
- [Live API Capabilities Guide](https://ai.google.dev/gemini-api/docs/live-guide.md.txt) — voice config, transcription config, VAD configuration, media resolution
- [Live API Tool Use](https://ai.google.dev/gemini-api/docs/live-tools.md.txt) — function calling (sync and async), Google Search grounding
- [Session Management](https://ai.google.dev/gemini-api/docs/live-session.md.txt) — context window compression, session resumption, GoAway signals
- [Ephemeral Tokens](https://ai.google.dev/gemini-api/docs/ephemeral-tokens.md.txt) — secure client-side authentication for browser/mobile
- [WebSockets API Reference](https://ai.google.dev/api/live.md.txt) — raw WebSocket protocol details
- [Migration & Upgrading Guide](references/migration.md) — step-by-step checklists and code examples for Gemini 3.8 Live and Extended Thinking

## Supported Languages

The Live API supports 70 languages including: English, Spanish, French, German, Italian, Portuguese, Chinese, Japanese, Korean, Hindi, Arabic, Russian, and many more. Native audio models automatically detect and switch languages.

### Source: `generators`

# Code Generators

Production-ready code generators for iOS and macOS apps. Unlike advisory skills (review, audit), these skills generate working code tailored to your project.

## When This Skill Activates

Use this skill when the user:
- Wants to add a common app component (logging, analytics, onboarding, etc.)
- Asks to "set up" or "add" infrastructure code
- Mentions replacing print() with proper logging
- Wants to add App Store review prompts
- Needs analytics or crash reporting setup

## Key Principles

### 1. Context-Aware Generation
Before generating code, skills will:
- Read existing project structure and patterns
- Detect deployment targets and Swift version
- Identify architecture patterns (MVVM, TCA, etc.)
- Check for existing implementations to avoid conflicts

### 2. Protocol-Based Architecture
Provider-dependent code uses protocols for easy swapping:
```swift
protocol AnalyticsService { ... }
class TelemetryDeckAnalytics: AnalyticsService { ... }
class FirebaseAnalytics: AnalyticsService { ... }
// Change provider by swapping ONE line
```

### 3. Platform Detection
Skills detect iOS vs macOS and App Store vs direct distribution to generate appropriate code.

## Available Generators

Read relevant module files based on the user's needs:

### logging-setup/
Replace print() statements with structured os.log/Logger.
- Audit existing print() usage
- Generate AppLogger infrastructure
- Migrate print → Logger with proper privacy levels

### analytics-setup/
Protocol-based analytics with swappable providers.
- TelemetryDeck, Firebase, Mixpanel support
- NoOp implementation for testing/privacy
- Easy provider switching

### onboarding-generator/
Value-moment-first onboarding — races a new user to the first felt experience of the app's promised outcome.
- Branches on ready-now vs. later, one decision per screen
- Root-swap presentation, phase-first gating, resume-safe hand-offs into existing features
- Local-notification implementation intentions for the "later" branch
- Value-moment reach-rate instrumentation (local-only, no analytics SDK required)
- Classic paged/stepped welcome carousel kept as an explicit fallback for explain-first apps

### review-prompt/
Smart App Store review prompts.
- Platform detection (skips for non-App Store macOS)
- Configurable trigger conditions
- Smart timing logic
- Debug override for testing

### networking-layer/
Protocol-based API client with async/await.
- Clean APIClient protocol for mocking/swapping
- Type-safe endpoint definitions
- Comprehensive error handling
- Environment-based configuration

### auth-flow/
Complete authentication flow.
- Sign in with Apple integration
- Biometric authentication (Face ID/Touch ID)
- Secure Keychain storage
- Credential state monitoring

### paywall-generator/
StoreKit 2 subscription paywall.
- Full StoreKit 2 implementation
- Product loading, purchasing, restoring
- Subscription status with Environment
- Beautiful paywall UI

### settings-screen/
Complete settings screen with modular sections.
- Centralized AppSettings with @AppStorage
- Appearance, Notifications, Account, About, Legal sections
- Cross-platform (iOS/macOS)
- Reusable row components

### persistence-setup/
SwiftData persistence with optional iCloud sync.
- SwiftData container configuration
- Repository pattern for testability
- Optional CloudKit/iCloud sync
- Sync status monitoring
- Migration support

### error-monitoring/
Protocol-based crash/error reporting.
- Sentry and Firebase Crashlytics support
- NoOp implementation for testing/privacy
- Breadcrumbs for debugging context
- User context (anonymized)
- Easy provider swapping

### ci-cd-setup/
CI/CD configuration for automated builds and deployment.
- GitHub Actions workflows (build, test, TestFlight, App Store)
- Xcode Cloud scripts and setup guide
- fastlane lanes for advanced automation
- Code signing and secrets management
- macOS notarization support

### localization-setup/
Internationalization (i18n) infrastructure for multi-language apps.
- String Catalogs (iOS 16+, recommended)
- Type-safe L10n enum for compile-time safety
- Pluralization and interpolation patterns
- RTL layout support
- SwiftUI preview helpers for testing locales

### push-notifications/
Push notification infrastructure with APNs setup.
- Registration and authorization flow
- UNUserNotificationCenterDelegate implementation
- Notification categories with action buttons
- Type-safe payload parsing
- Rich notifications and silent notifications

### deep-linking/
Deep linking with URL schemes, Universal Links, and App Intents.
- Custom URL scheme handling
- Universal Links with AASA file
- App Intents for Siri and Shortcuts
- Type-safe route definitions and navigation
- Spotlight indexing support

### test-generator/
Test templates for unit, integration, and UI tests.
- Swift Testing (modern, iOS 16+) and XCTest patterns
- Mock object generation
- ViewModel and service testing patterns
- UI testing with page object pattern

### preview-data-generator/
Sample data and a multi-variant #Preview matrix for SwiftUI views.
- Canvas sample data with visual edge cases (empty, long strings, missing, list)
- Data-state previews (loaded/empty/loading/error) for UI prototyping
- Appearance, Dynamic Type, locale/RTL, and device variant matrix
- SwiftData in-memory seeded containers; iOS 18 PreviewModifier + @Previewable
- Reuses test-data-factory fixtures instead of duplicating them

### accessibility-generator/
Accessibility infrastructure for inclusive apps.
- VoiceOver labels, hints, and traits
- Dynamic Type support with scaling
- Reduce Motion handling
- Accessibility audit checklist

### widget-generator/
WidgetKit widgets for home screen and lock screen.
- Static and interactive widgets (iOS 17+)
- Timeline providers
- Lock screen complications
- Widget intents for configuration

### app-icon-generator/
Programmatic app icon generation using CoreGraphics.
- Apple HIG compliant icon design
- Category-aware design recipes (productivity, media, dev tools, etc.)
- 3 variant generation for user selection
- Automatic resizing to all required sizes (macOS + iOS)
- Asset catalog installation with correct Contents.json
- No external dependencies — pure CoreGraphics

### feature-flags/
Feature flag infrastructure with local and remote support.
- Protocol-based service with swappable providers
- Local defaults with remote override (composite provider)
- @Observable manager for SwiftUI integration
- Debug menu for toggling flags

### live-activity-generator/
ActivityKit Live Activity with Dynamic Island and Lock Screen.
- ActivityAttributes and ContentState definitions
- Dynamic Island layouts (compact and expanded)
- Lock Screen presentation
- Push-to-update support via APNs
- Activity lifecycle management (start, update, end)

### tipkit-generator/
TipKit inline and popover tips with rules and testing.
- Inline and popover tip definitions
- Rule-based display logic (parameter and event rules)
- Display frequency and invalidation
- Testing and preview support

### cloudkit-sync/
CKSyncEngine-based CloudKit sync (iOS 17+).
- CKSyncEngine setup and delegate
- Record zone management
- Conflict resolution strategies
- Sharing and collaboration support

### http-cache/
HTTP caching layer with Cache-Control, ETag, and offline fallback.
- Cache-Control header parsing
- ETag/Last-Modified conditional requests (304)
- Stale-while-revalidate pattern
- Decorator pattern wrapping existing APIClient
- Network reachability for offline fallback

### pagination/
Pagination infrastructure with offset and cursor patterns.
- Offset-based and cursor-based response models
- State machine (idle, loading, loaded, error, exhausted)
- @Observable PaginationManager with prefetch threshold
- Searchable pagination with debounced query
- Infinite scroll, load-more button, and state views

### image-loading/
Image loading pipeline with caching and CachedAsyncImage view.
- NSCache memory cache with auto-eviction
- LRU disk cache with expiration
- Actor-based downloader with request deduplication
- ImageIO thumbnail generation
- Drop-in CachedAsyncImage SwiftUI replacement
- Collection prefetching

### share-card/
Shareable image cards for social media sharing.
- ShareCardContent protocol with achievement, statistics, and quote types
- ImageRenderer-based card generation
- Configurable styles (minimal, branded, statistics)
- ShareLink integration and QR code overlay

### social-export/
Export content to social platforms with correct formats.
- Platform-specific formatting (Instagram, TikTok, X)
- Aspect ratio and resolution handling per platform
- Branding overlay and caption support
- URL scheme-based and share sheet export

### subscription-lifecycle/
StoreKit 2 subscription lifecycle management.
- Grace period and billing retry handling
- Win-back and promotional offer management
- Subscription status monitoring with Transaction.updates
- Upgrade/downgrade path handling
- Dashboard UI for subscription management

### referral-system/
Referral and invite system with viral growth mechanics.
- Unique code generation with fraud prevention
- Deep link-based sharing and redemption
- Reward tracking for referrer and invitee
- Dashboard with referral statistics

### watermark-engine/
Watermark overlays for images with paywall integration.
- Text, image, and tiled watermark styles
- CoreGraphics-based rendering with Retina support
- Subscription-gated watermark removal
- SwiftUI overlay and ViewModifier

### streak-tracker/
Daily/weekly streak tracking with engagement mechanics.
- SwiftData-based activity recording
- Timezone-aware day boundary calculations
- Streak freeze/protection passes
- Calendar heat map and badge views
- Streak-at-risk notifications

### milestone-celebration/
Achievement celebrations with confetti and badges.
- CAEmitterLayer confetti with Reduce Motion support
- Milestone tracking with threshold detection
- Badge collection grid with progress rings
- Haptic feedback integration

### whats-new/
What's New screen shown after app updates.
- Version tracking with UserDefaults persistence
- Paged TabView feature highlights
- Local and remote content providers
- Auto-present as sheet on version change

### lapsed-user/
Lapsed user detection and re-engagement.
- Configurable inactivity thresholds (7/14/30 days)
- Personalized return experience by lapse category
- Win-back offer screen for lapsed subscribers
- ViewModifier for auto-detection on app launch

### usage-insights/
User-facing usage statistics and activity summaries.
- SwiftData event recording with batch writes
- Insight calculation (streaks, top categories, trends)
- Dashboard with Swift Charts integration
- Shareable recap cards (Spotify Wrapped-style)

### variable-rewards/
Variable reward system with gamification mechanics.
- Weighted probability reward pools with rarity tiers
- Daily spin wheel and mystery box animations
- Daily/weekly caps for ethical engagement
- Reward history and notification views

### consent-flow/
GDPR/CCPA/DPDP privacy consent management.
- Granular per-category consent (analytics, marketing, etc.)
- ATT (App Tracking Transparency) integration
- Consent audit logging for compliance
- Banner and preferences UI with equal prominence

### account-deletion/
Apple-compliant account deletion flow.
- Multi-step confirmation with re-authentication
- Data export before deletion
- Grace period with cancellation option
- Keychain cleanup and Sign in with Apple revocation

### permission-priming/
Pre-permission priming screens for higher grant rates.
- Unified permission manager (notifications, camera, location, etc.)
- Benefit-focused priming UI before system prompt
- Permission status tracking with Settings redirect
- Gated content ViewModifier

### force-update/
Minimum version enforcement with update prompts.
- Remote JSON and App Store lookup version checking
- Hard block (required) and soft prompt (recommended)
- Configurable check frequency
- Skip tracking for soft updates

### state-restoration/
State preservation and restoration across app launches.
- NavigationPath, tab selection, scroll position persistence
- Codable AppState with debounced auto-save
- Form draft manager with auto-save
- @SceneStorage and file-based storage options

### debug-menu/
Developer debug menu (DEBUG builds only).
- Feature flag toggles and environment switcher
- Network request logger with circular buffer
- Cache clearing and diagnostic info export
- Shake gesture and hidden tap triggers

### offline-queue/
Offline operation queue with automatic retry.
- Actor-based queue manager with FIFO + priority
- File-based persistence for queued operations
- Exponential backoff with jitter retry policy
- NWPathMonitor connectivity detection
- Offline status banner ViewModifier

### feedback-form/
In-app feedback collection with smart routing.
- Category-based feedback (bug, feature, praise)
- Screenshot capture and annotation
- Sentiment routing (happy → App Store, unhappy → support)
- Email and webhook submission

### announcement-banner/
In-app announcement banners with remote configuration.
- Priority-based banner display (info, warning, promotion)
- Local and remote announcement providers
- Deep link and URL action handling
- Scheduled display with date ranges

### quick-win-session/
Guided first-action flows for fast time-to-value.
- Step-by-step task guidance
- Spotlight hint overlays with cutout circles
- Completion celebration with timing stats
- ViewModifier for new user detection

### spotlight-indexing/
Core Spotlight indexing for system search integration.
- SpotlightIndexable protocol for any model
- Actor-based batch index manager
- Fluent attribute builder API
- Search continuation and Siri suggestions

### app-clip/
App Clip target with invocation and upgrade flow.
- Invocation URL parsing and routing
- Experience protocol with concrete implementations
- Location confirmation for physical invocations
- SKOverlay full app upgrade prompt
- App Group data sharing

### screenshot-automation/
Automated App Store screenshot generation.
- XCUITest-based screen capture with navigation
- Localized caption overlays with CoreText
- Device frame compositing
- Multi-locale, multi-device batch export

### background-processing/
Background task infrastructure with BGTaskScheduler.
- BGAppRefreshTask and BGProcessingTask setup
- Background URLSession for downloads/uploads
- Silent push notification handling
- Energy-efficient scheduling strategies

### app-extensions/
App extension targets for Share, Action, Keyboard, and Safari.
- Share Extension with content handling
- Action Extension for in-place content manipulation
- Keyboard Extension with UIInputViewController
- Safari Web Extension with message handler
- App Group data sharing between app and extension

### data-export/
Data export/import infrastructure with JSON, CSV, and PDF support.
- Protocol-based multi-format export (DataExportable)
- CSV generation with RFC 4180 compliance
- PDF report generation with UIGraphicsPDFRenderer
- File import with UTType-based parsing
- GDPR Article 20 data portability compliance

## How to Use

1. User requests a component (e.g., "add logging to my app")
2. Read the relevant skill's SKILL.md
3. Run pre-generation checks (conflicts, deployment target, etc.)
4. Ask configuration questions via AskUserQuestion
5. Generate code from templates, adapting to project context
6. Provide integration instructions

## Output Format

After generation, always provide:
- **Files created** (with full paths)
- **Integration steps** (how to wire into existing code)
- **Required capabilities** (entitlements, dependencies)
- **Testing instructions** (how to verify it works)

### Source: `generators/account-deletion`

# Account Deletion Generator

Generate a production account deletion flow compliant with Apple's App Store requirement (effective June 30, 2022) that any app offering account creation must also offer account deletion from within the app. Includes multi-step confirmation UI, optional data export, configurable grace period, Keychain cleanup, and Sign in with Apple token revocation.

## When This Skill Activates

Use this skill when the user:
- Asks to "add account deletion" or "delete account"
- Wants to "remove account" or implement "account removal"
- Mentions "right to delete" or "user data deletion"
- Asks about "Apple account deletion requirement"
- Needs App Store compliance for account management
- Wants to implement GDPR/privacy right-to-erasure

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Existing Auth/Account Code
Search for existing account management:
```
Glob: **/*Auth*.swift, **/*Account*.swift, **/*User*.swift, **/*Profile*.swift
Grep: "ASAuthorizationAppleIDProvider" or "SignInWithApple" or "Keychain" or "deleteAccount"
```

If existing deletion flow found:
- Ask if user wants to replace or enhance it
- If enhancing, integrate with existing auth architecture

### 3. Keychain Usage Detection
```
Grep: "SecItemAdd" or "SecItemDelete" or "SecItemCopyMatching" or "KeychainWrapper" or "keychain"
```

If Keychain usage found, ensure cleanup covers all stored items.

### 4. CloudKit / Server Sync Detection
```
Grep: "CKContainer" or "CloudKit" or "CKRecord" or "NSPersistentCloudKitContainer"
Glob: **/*CloudKit*.swift, **/*Sync*.swift
```

If CloudKit or server sync found, include remote data cleanup steps.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Deletion type?**
   - Immediate — account deleted right away after confirmation
   - Grace period — account scheduled for deletion, user can cancel

2. **Grace period duration?** (if grace period selected)
   - 7 days
   - 14 days — recommended
   - 30 days

3. **Include data export before deletion?**
   - Yes — generate DataExportService with JSON/ZIP archive and ShareLink
   - No — skip data export

4. **Server-side API call needed?**
   - Yes — generate server deletion request with configurable endpoint
   - No — local-only deletion (Keychain, UserDefaults, SwiftData/CoreData, files)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `AccountDeletionManager.swift` — @Observable orchestrator for the full deletion lifecycle
2. `DeletionConfirmationView.swift` — Multi-step confirmation UI with NavigationStack
3. `KeychainCleanup.swift` — Utility to remove all app Keychain items

### Step 3: Create Optional Files
Based on configuration:
- `DataExportService.swift` — If data export selected
- `DeletionGracePeriodView.swift` — If grace period selected
- `SignInWithAppleRevocation.swift` — If SIWA detected in project

### Step 4: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/AccountDeletion/`
- If `App/` exists -> `App/AccountDeletion/`
- Otherwise -> `AccountDeletion/`

## Output Format

After generation, provide:

### Files Created
```
AccountDeletion/
├── AccountDeletionManager.swift      # Orchestrator for deletion lifecycle
├── DeletionConfirmationView.swift    # Multi-step confirmation UI
├── KeychainCleanup.swift             # Keychain item cleanup
├── DataExportService.swift           # Data export before deletion (optional)
├── DeletionGracePeriodView.swift     # Grace period countdown UI (optional)
└── SignInWithAppleRevocation.swift    # SIWA token revocation (optional)
```

### Integration Steps

**Add to Settings or Account screen:**
```swift
// In your Settings or Account view
struct AccountSettingsView: View {
    @State private var showDeletionFlow = false

    var body: some View {
        Form {
            // ... other settings ...

            Section {
                Button(role: .destructive) {
                    showDeletionFlow = true
                } label: {
                    Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                }
            } footer: {
                Text("Permanently removes your account and all associated data.")
            }
        }
        .sheet(isPresented: $showDeletionFlow) {
            DeletionConfirmationView()
        }
    }
}
```

**With grace period (check on app launch):**
```swift
@main
struct MyApp: App {
    @State private var deletionManager = AccountDeletionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(deletionManager)
                .task {
                    await deletionManager.checkPendingDeletion()
                }
        }
    }
}
```

**With data export:**
```swift
// User can export before deleting
DeletionConfirmationView()
    .environment(DataExportService())
```

### Testing

```swift
@Test
func deletionFlowCompletesSuccessfully() async throws {
    let manager = AccountDeletionManager(
        serverClient: MockDeletionClient(),
        keychainCleanup: MockKeychainCleanup()
    )

    try await manager.confirmWithReauthentication()
    try await manager.executeDeletion()

    #expect(manager.deletionState == .completed)
}

@Test
func gracePeriodCancellation() async throws {
    let manager = AccountDeletionManager()

    try await manager.scheduleDeletion(gracePeriodDays: 14)
    #expect(manager.scheduledDeletionDate != nil)

    try await manager.cancelScheduledDeletion()
    #expect(manager.deletionState == .none)
    #expect(manager.scheduledDeletionDate == nil)
}

@Test
func keychainItemsRemovedOnDeletion() async throws {
    let cleanup = KeychainCleanup()
    // Store a test item
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "test-account",
        kSecValueData as String: Data("secret".utf8)
    ]
    SecItemAdd(query as CFDictionary, nil)

    // Delete all items
    try cleanup.removeAllItems()

    // Verify removal
    let searchQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "test-account",
        kSecReturnData as String: true
    ]
    let status = SecItemCopyMatching(searchQuery as CFDictionary, nil)
    #expect(status == errSecItemNotFound)
}

@Test
func dataExportGeneratesArchive() async throws {
    let exportService = DataExportService()
    let archiveURL = try await exportService.exportAllUserData()

    #expect(FileManager.default.fileExists(atPath: archiveURL.path))

    // Cleanup
    try FileManager.default.removeItem(at: archiveURL)
}
```

## Common Patterns

### Initiate Deletion from Settings
Account deletion must be accessible from within the app — typically in Settings > Account. Apple will reject apps that only offer deletion via website or email.

### Confirm with Password or Biometric
Re-authenticate the user before deletion to prevent accidental or unauthorized account removal. Use LocalAuthentication for biometric or prompt for password.

### Export Data Before Deletion
Offer users the ability to download their data before the account is removed. This is a privacy best practice and builds user trust.

### Schedule Deletion with Grace Period
Instead of immediate deletion, schedule it for 7-30 days out. Allow users to cancel during this window. Many users delete accounts impulsively and appreciate the recovery option.

## Gotchas

- **Apple requires in-app deletion** — App Review will reject apps where account deletion is only available via website, email, or contacting support. The option must be accessible from within the app itself.
- **Keychain items persist after app uninstall** — You must explicitly call `SecItemDelete` for all item classes (generic password, internet password, certificate, key, identity) during account deletion.
- **Sign in with Apple token revocation** — If your app supports Sign in with Apple, you must revoke the user's token via Apple's REST API (`https://appleid.apple.com/auth/revoke`). Failure to do so means Apple still considers the account linked.
- **CloudKit data cleanup** — CloudKit private database records are tied to the user's iCloud account, not your app. You cannot delete them on behalf of the user. Document this limitation and delete any shared/public records your app created.
- **Subscription cancellation guidance** — Account deletion does not automatically cancel active subscriptions. Display a warning and link to Settings > Subscriptions so users can cancel before deletion.
- **UserDefaults and app group data** — Remember to clean `UserDefaults.standard` and any shared app group containers (`UserDefaults(suiteName:)`).
- **SwiftData / CoreData cleanup** — Delete all model containers and persistent stores, not just individual records.

## References

- **templates.md** — All production Swift templates
- Related: `generators/auth-flow` — Authentication flow generation
- Related: `generators/persistence-setup` — Data persistence that needs cleanup
- Related: `generators/settings-screen` — Settings screen where deletion is placed
- Related: `generators/cloudkit-sync` — CloudKit data that needs cleanup consideration

### Source: `generators/announcement-banner`

# Announcement Banner Generator

Generate a configurable in-app announcement/banner system that displays contextual messages (maintenance alerts, new feature highlights, promotions) from remote config or local definitions. Supports dismissal, deep link actions, and scheduling.

## When This Skill Activates

Use this skill when the user:
- Asks to "add announcement banner" or "in-app banner"
- Wants "app announcement" or "notification banner"
- Mentions "promotional banner" or "promo banner"
- Asks about "maintenance notice" or "maintenance alert"
- Wants "in-app messaging" or "contextual banners"
- Asks to "show announcements" or "display alerts to users"
- Mentions "feature highlight banner" or "what's new banner"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing banner/toast code:
```
Glob: **/*Banner*.swift, **/*Announcement*.swift, **/*Toast*.swift, **/*InAppMessage*.swift
Grep: "AnnouncementBanner" or "InAppBanner" or "ToastView" or "BannerView"
```

If third-party library found (Firebase In-App Messaging, Braze, Intercom):
- Ask if user wants to replace or keep it
- If keeping, don't generate — advise on integration patterns instead

### 3. Deep Linking Detection
Check for existing deep linking setup:
```
Grep: "deepLink" or "DeepLink" or "universalLink" or "openURL" or "onOpenURL"
```

If deep linking exists, integrate with it. If not, generate standalone action handling.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Banner position?**
   - Top (slides in from top) — recommended for alerts
   - Bottom (slides in from bottom)
   - Floating (centered overlay with dimmed background)

2. **Content source?**
   - Local only (hardcoded announcements in code)
   - Remote JSON (fetch from server endpoint)
   - Both (remote with local fallbacks) — recommended

3. **Action type?**
   - Deep link (navigate to in-app screen)
   - URL (open in Safari/SFSafariViewController)
   - Dismiss only (informational, no action button)
   - All of the above — recommended

4. **Include scheduling (start/end dates)?**
   - Yes (time-limited announcements with date ranges) — recommended
   - No (always-active until dismissed)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `Announcement.swift` — Model with style, action, priority, scheduling
2. `AnnouncementManager.swift` — @Observable manager: loads, filters, tracks dismissals
3. `AnnouncementProvider.swift` — Protocol + local/remote implementations with caching

### Step 3: Create UI Files
4. `AnnouncementBannerView.swift` — SwiftUI banner with style-aware colors and animations
5. `AnnouncementBannerModifier.swift` — ViewModifier for overlay placement and action routing

### Step 4: Create Optional Files
Based on configuration:
- `AnnouncementScheduler.swift` — If scheduling selected (date range filtering, timezone handling)

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/AnnouncementBanner/`
- If `App/` exists -> `App/AnnouncementBanner/`
- Otherwise -> `AnnouncementBanner/`

## Output Format

After generation, provide:

### Files Created
```
AnnouncementBanner/
├── Announcement.swift              # Model with style, action, priority
├── AnnouncementManager.swift       # Observable manager with dismiss tracking
├── AnnouncementProvider.swift      # Protocol + local/remote providers
├── AnnouncementBannerView.swift    # SwiftUI banner view
├── AnnouncementBannerModifier.swift# ViewModifier for overlay + actions
└── AnnouncementScheduler.swift     # Date range filtering (optional)
```

### Integration Steps

**Add banner overlay to root view:**
```swift
// In your root ContentView or NavigationStack
ContentView()
    .announcementBanner()
```

**With custom position:**
```swift
ContentView()
    .announcementBanner(position: .bottom)
```

**With deep link action handler:**
```swift
ContentView()
    .announcementBanner { action in
        switch action {
        case .deepLink(let destination):
            router.navigate(to: destination)
        case .url(let url):
            openURL(url)
        case .dismiss:
            break
        }
    }
```

**Define local announcements:**
```swift
let provider = LocalAnnouncementProvider(announcements: [
    Announcement(
        id: "maintenance-2024",
        title: "Scheduled Maintenance",
        message: "We'll be performing maintenance on Saturday 9-11 AM EST.",
        style: .warning,
        action: .dismiss,
        priority: 10,
        startDate: maintenanceStart,
        endDate: maintenanceEnd
    ),
    Announcement(
        id: "new-feature-photos",
        title: "New: Photo Library",
        message: "Check out our new photo library with AI-powered search!",
        style: .promotion,
        action: .deepLink("app://features/photos"),
        priority: 5,
        isDismissible: true
    )
])
```

**Fetch from remote config:**
```swift
let provider = RemoteAnnouncementProvider(
    url: URL(string: "https://api.example.com/announcements")!,
    cacheDuration: 3600  // 1 hour
)
```

### Testing

```swift
@Test
func dismissedAnnouncementsAreHidden() async throws {
    let manager = AnnouncementManager(
        provider: MockAnnouncementProvider(announcements: [testAnnouncement]),
        dismissalStore: InMemoryDismissalStore()
    )

    await manager.loadAnnouncements()
    #expect(manager.activeAnnouncement != nil)

    manager.dismiss(testAnnouncement)
    #expect(manager.activeAnnouncement == nil)
}

@Test
func highestPriorityAnnouncementShownFirst() async throws {
    let lowPriority = Announcement(id: "low", title: "Low", message: "...", style: .info, priority: 1)
    let highPriority = Announcement(id: "high", title: "High", message: "...", style: .warning, priority: 10)
    let manager = AnnouncementManager(
        provider: MockAnnouncementProvider(announcements: [lowPriority, highPriority])
    )

    await manager.loadAnnouncements()
    #expect(manager.activeAnnouncement?.id == "high")
}

@Test
func expiredAnnouncementsAreFiltered() async throws {
    let expired = Announcement(
        id: "expired",
        title: "Old",
        message: "...",
        style: .info,
        endDate: Date.distantPast
    )
    let manager = AnnouncementManager(
        provider: MockAnnouncementProvider(announcements: [expired])
    )

    await manager.loadAnnouncements()
    #expect(manager.activeAnnouncement == nil)
}
```

## Common Patterns

### Show Maintenance Banner
```swift
Announcement(
    id: "maintenance-\(date)",
    title: "Scheduled Maintenance",
    message: "Service will be unavailable Saturday 2-4 AM EST.",
    style: .warning,
    action: .url(URL(string: "https://status.example.com")!),
    priority: 100,  // High priority overrides other banners
    startDate: Calendar.current.date(byAdding: .day, value: -1, to: maintenanceDate)!,
    endDate: maintenanceEndDate,
    isDismissible: false  // Can't dismiss maintenance warnings
)
```

### Promote New Feature
```swift
Announcement(
    id: "feature-v2.5-darkmode",
    title: "Dark Mode is Here!",
    message: "Try our new dark mode in Settings.",
    style: .promotion,
    action: .deepLink("app://settings/appearance"),
    priority: 5,
    isDismissible: true
)
```

### Time-Limited Promotion
```swift
Announcement(
    id: "promo-summer-2024",
    title: "Summer Sale - 40% Off!",
    message: "Upgrade to Pro at our lowest price ever.",
    style: .promotion,
    action: .deepLink("app://subscription/upgrade"),
    priority: 8,
    startDate: promoStart,
    endDate: promoEnd,
    isDismissible: true,
    targetAudience: .freeUsers
)
```

## Gotchas

1. **Banner stacking** — Never show multiple banners simultaneously. Use priority to determine which single banner to display. Queue others and show the next one after dismissal.
2. **Don't cover critical UI** — Ensure the banner doesn't overlap navigation bars, tab bars, or interactive elements. Use safe area insets.
3. **Respect user dismissal** — Persist dismissed announcement IDs so they don't reappear after app relaunch. Use UserDefaults or a lightweight store.
4. **Remote config caching** — Cache fetched announcements to avoid network requests on every app launch. Honor cache duration but allow force-refresh.
5. **Date/timezone handling** — Always use UTC for start/end dates in remote config. Convert to local timezone only for display purposes.
6. **Accessibility** — Announce banner appearance with `AccessibilityNotification.Announcement`. Ensure dismiss button has proper label.
7. **Animation interruption** — If a user navigates away mid-animation, ensure the banner state resets properly. Use `.task` tied to view lifecycle.

## References

- **templates.md** — All production Swift templates
- Related: `generators/deep-linking` — Deep link routing integration
- Related: `generators/whats-new` — What's new screen for feature highlights

### Source: `generators/app-clip`

# App Clip Generator

Generate production App Clip infrastructure — a lightweight version of your app invoked from NFC tags, QR codes, Safari banners, or Messages. Includes App Clip target setup, invocation URL handling, experience routing, location confirmation, and full app upgrade flow.

## When This Skill Activates

Use this skill when the user:
- Asks to "add an app clip" or "create an app clip target"
- Mentions "instant app" or "lightweight app experience"
- Wants to set up "App Clip Card" metadata
- Mentions "NFC tag" invocation or "QR code" launching an app
- Asks about "app clip invocation" or "invocation URL handling"
- Wants a "lightweight app experience" for a physical location

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 14+ required for App Clips, iOS 16+ recommended)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify Xcode project structure (.xcodeproj or .xcworkspace)

### 2. Conflict Detection
Search for existing App Clip targets:
```
Glob: **/*AppClip*/*.swift, **/*Clip*/*.swift
Grep: "NSUserActivityTypeBrowsingWeb" or "AppClipExperience" or "SKOverlay"
```

If existing App Clip target found:
- Ask if user wants to replace or extend it
- If extending, identify which components are missing

### 3. Project Structure
Identify where the main app target lives and where to place the App Clip target alongside it.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Invocation method?**
   - NFC tag only
   - QR code only
   - Safari banner (Smart App Banner)
   - Messages
   - All of the above — recommended

2. **Primary experience?**
   - Order food (restaurant/cafe)
   - Reserve (booking/reservation)
   - Check in (event/location)
   - Preview content (article/product)

3. **Include location confirmation?**
   - Yes — verifies user is physically at the expected location (recommended for physical-world invocations)
   - No — skip location verification

4. **Include full app upgrade prompt?**
   - Yes — show SKOverlay banner to download full app (recommended)
   - No — App Clip only, no upgrade path

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.
Read `patterns.md` for constraints, testing, and best practices.

### Step 2: Create Core Files
Generate these files:
1. `AppClipApp.swift` — @main App struct handling invocation via `.onContinueUserActivity`
2. `InvocationHandler.swift` — Parses invocation URL, extracts parameters, validates against registered experiences
3. `AppClipExperience.swift` — Protocol and concrete experience implementations

### Step 3: Create Location Files (if selected)
4. `LocationConfirmationView.swift` — CLLocationManager-based location verification for physical invocations

### Step 4: Create Upgrade Files (if selected)
5. `FullAppUpgradeView.swift` — SKOverlay-based banner prompting full app download
6. `SharedDataManager.swift` — App Group data sharing between App Clip and full app

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/AppClip/`
- If main app target folder exists -> `AppClip/` at the same level
- Otherwise -> `AppClip/`

## Output Format

After generation, provide:

### Files Created
```
AppClip/
├── AppClipApp.swift              # @main entry point with invocation handling
├── InvocationHandler.swift       # URL parsing and parameter extraction
├── AppClipExperience.swift       # Experience protocol and implementations
├── LocationConfirmationView.swift # Location verification (optional)
├── FullAppUpgradeView.swift      # SKOverlay upgrade prompt (optional)
└── SharedDataManager.swift       # App Group data sharing (optional)
```

### Xcode Target Setup Instructions

1. **Add App Clip Target:**
   - File > New > Target > App Clip
   - Set bundle ID to `{main-app-bundle-id}.Clip`
   - Set deployment target to iOS 16.0

2. **Configure Associated Domains:**
   - Add `appclips:{your-domain.com}` to both main app and App Clip entitlements

3. **Set Up App Group:**
   - Add `group.{your-bundle-id}` to both targets for shared data

4. **Apple-App-Site-Association (AASA) file:**
   - Host at `https://{your-domain.com}/.well-known/apple-app-site-association`

### Integration

**Handle invocation in the App Clip:**
```swift
@main
struct MyAppClip: App {
    @State private var handler = InvocationHandler()

    var body: some Scene {
        WindowGroup {
            ContentView(experience: handler.currentExperience)
                .onContinueUserActivity(
                    NSUserActivityTypeBrowsingWeb
                ) { activity in
                    handler.handle(activity)
                }
        }
    }
}
```

**Route to the correct experience:**
```swift
struct ContentView: View {
    let experience: (any AppClipExperience)?

    var body: some View {
        if let experience {
            AnyView(experience.makeView())
        } else {
            DefaultExperienceView()
        }
    }
}
```

**Share data with the full app:**
```swift
// In App Clip — save order before user upgrades
SharedDataManager.shared.save(order, forKey: "pendingOrder")

// In Full App — restore after install
if let order: Order = SharedDataManager.shared.load(forKey: "pendingOrder") {
    showOrder(order)
}
```

**Prompt full app download:**
```swift
FullAppUpgradeView(
    appStoreID: "123456789",
    benefits: [
        "Order history and favorites",
        "Loyalty rewards program",
        "Push notification for order updates"
    ]
)
```

### Testing

```swift
@Test
func invocationHandlerParsesProductURL() {
    let handler = InvocationHandler()
    let url = URL(string: "https://example.com/clip/product/abc123")!

    let experience = handler.parseURL(url)

    #expect(experience != nil)
    #expect(experience?.experienceType == .previewContent)
    #expect(experience?.parameters["productID"] == "abc123")
}

@Test
func invocationHandlerRejectsInvalidURL() {
    let handler = InvocationHandler()
    let url = URL(string: "https://other-domain.com/something")!

    let experience = handler.parseURL(url)

    #expect(experience == nil)
}

@Test
func sharedDataManagerRoundTrips() {
    let manager = SharedDataManager(suiteName: "group.test")
    let order = Order(id: "order-1", items: ["Latte", "Muffin"])

    manager.save(order, forKey: "testOrder")
    let loaded: Order? = manager.load(forKey: "testOrder")

    #expect(loaded?.id == "order-1")
    #expect(loaded?.items.count == 2)
}
```

## Common Patterns

### Handle Invocation URL
Every App Clip starts from a URL. Parse it to determine what experience to show:
```swift
// URL: https://example.com/clip/order?location=store-42
// -> Route to OrderExperience with locationID = "store-42"
```

### Present Experience Immediately
Users expect instant value. Show the relevant experience within 1-2 seconds, no sign-in required.

### Prompt Full App Install
After the user completes the primary task, show an SKOverlay banner with clear benefits of the full app.

## Gotchas

- **10 MB size limit** — App Clip binary must be under 10 MB. Use SF Symbols, avoid large assets, lazy-load images from network.
- **8-hour data retention** — App Clip data is deleted after 8 hours of inactivity. Use App Group to persist data accessible to the full app.
- **Limited frameworks** — No CallKit, no HealthKit, no CareKit. Limited background processing. Check Apple's framework availability list.
- **No background processing** — App Clips cannot run background tasks, background fetch, or silent push notifications.
- **Must work without sign-in** — App Clips should provide value immediately. Defer sign-in until the full app upgrade.
- **App Clip Card metadata** — Configure in App Store Connect: card image (3000x2000 px), title, subtitle, call-to-action button text.
- **Associated Domains required** — Both the main app and App Clip must have the `appclips:` associated domain configured, and the AASA file must be hosted on the domain.
- **Size budgeting** — Regularly check App Clip size during development with `xcodebuild -exportArchive` or the App Thinning Size Report.

## References

- **templates.md** — All production Swift templates for App Clip infrastructure
- **patterns.md** — Constraints, data lifecycle, testing, and best practices
- Related: `generators/deep-linking` — Universal link and deep link handling
- Related: `generators/onboarding-generator` — Onboarding flow for full app upgrade

### Source: `generators/app-extensions`

# App Extensions Generator

Generate production app extension infrastructure -- Share Extensions for receiving content from other apps, Action Extensions for manipulating content in-place, Keyboard Extensions for custom input, and Safari Web Extensions for browser integration. Includes App Group data sharing between the host app and extensions.

## When This Skill Activates

Use this skill when the user:
- Asks to "add a share extension" or "share sheet extension"
- Wants to "receive content from other apps" or "accept shared content"
- Mentions "action extension" or "content manipulation extension"
- Wants to "add a custom keyboard" or "keyboard extension"
- Asks about "Safari extension" or "Safari web extension"
- Mentions "app extension" or "extension target" generically
- Wants to "share data between app and extension" or "App Groups"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Identify project structure (find .xcodeproj or Package.swift)
- [ ] Identify source file locations

### 2. Existing Extension Detection
Search for existing extension targets:
```
Glob: **/*Extension*/*.swift, **/*Extension*/Info.plist
Grep: "NSExtensionPointIdentifier" or "NSExtensionPrincipalClass"
```

If existing extensions found:
- Ask if user wants to add another or modify existing
- Identify existing App Groups configuration

### 3. App Groups Detection
Check for existing App Groups setup:
```
Glob: **/*.entitlements
Grep: "com.apple.security.application-groups"
```

If App Groups exist, reuse the existing group identifier.

## Configuration Questions

Ask user via AskUserQuestion:

1. **What type of extension?**
   - Share Extension (accept content from other apps, display share UI)
   - Action Extension (manipulate content in-place -- transform text, edit images)
   - Keyboard Extension (custom input keyboard with KeyboardViewController)
   - Safari Web Extension (inject JavaScript/CSS into web pages)

2. **What content types does it handle?**
   - Text (plain text, rich text)
   - URLs (web links, deep links)
   - Images (photos, screenshots)
   - Files (documents, PDFs, archives)
   - All (any content type)

3. **Does the extension need to share data with the main app?**
   - Yes -- needs App Groups (shared UserDefaults, shared file container, shared Keychain)
   - No -- extension is self-contained

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Extension Files
Based on extension type selected:

**Share Extension:**
1. `ShareViewController.swift` -- Main share extension view controller with content handling
2. `Info.plist` -- Extension configuration with activation rules

**Action Extension:**
3. `ActionViewController.swift` -- Action extension with content manipulation
4. `Info.plist` -- Extension configuration

**Keyboard Extension:**
5. `KeyboardViewController.swift` -- Custom keyboard with UIInputViewController
6. `Info.plist` -- Keyboard extension configuration

**Safari Web Extension:**
7. `SafariWebExtensionHandler.swift` -- Native message handler
8. `manifest.json` -- Web extension manifest
9. `content.js` -- Content script template

### Step 3: Create Shared Infrastructure
If data sharing selected:
10. `SharedDataManager.swift` -- App Group data sharing helper

### Step 4: Determine File Location
Extensions are separate targets:
- Share Extension -> `ShareExtension/`
- Action Extension -> `ActionExtension/`
- Keyboard Extension -> `KeyboardExtension/`
- Safari Web Extension -> `SafariWebExtension/`
- Shared code -> `Shared/` or within main app target

## Output Format

After generation, provide:

### Files Created

**Share Extension:**
```
ShareExtension/
├── ShareViewController.swift  # Main share extension view controller
└── Info.plist                 # Extension activation rules & config
```

**Action Extension:**
```
ActionExtension/
├── ActionViewController.swift # Content manipulation controller
└── Info.plist                 # Extension activation rules & config
```

**Keyboard Extension:**
```
KeyboardExtension/
├── KeyboardViewController.swift # UIInputViewController subclass
└── Info.plist                   # Keyboard extension config
```

**Safari Web Extension:**
```
SafariWebExtension/
├── SafariWebExtensionHandler.swift # Native message handler
└── Resources/
    ├── manifest.json               # Web extension manifest
    ├── content.js                  # Content script
    └── popup.html                  # Popup UI (optional)
```

**Shared (if data sharing enabled):**
```
Shared/
└── SharedDataManager.swift    # App Group data sharing
```

### Integration Steps

**1. Add Extension Target in Xcode:**
- File > New > Target
- Select the extension type (Share, Action, Keyboard, Safari Web)
- Configure bundle identifier: `com.yourapp.ShareExtension`
- Xcode creates the target with boilerplate -- replace with generated code

**2. Configure App Groups (if data sharing):**
- Select main app target > Signing & Capabilities > Add "App Groups"
- Add group: `group.com.yourapp.shared`
- Select extension target > Signing & Capabilities > Add "App Groups"
- Add the same group identifier

**3. Share code between targets:**
- Add shared files to both the app and extension targets
- Or create a shared framework target

### Extension Content Handling

**Accept shared URLs:**
```swift
if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
    provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, error in
        guard let url = item as? URL else { return }
        // Process URL
    }
}
```

**Accept shared images:**
```swift
if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
    provider.loadItem(forTypeIdentifier: UTType.image.identifier) { item, error in
        if let imageURL = item as? URL {
            let imageData = try? Data(contentsOf: imageURL)
            // Process image data
        }
    }
}
```

**Share data to main app via App Groups:**
```swift
let shared = SharedDataManager.shared
shared.saveSharedContent(url.absoluteString, forKey: "lastSharedURL")
```

### Testing

**Share Extension:**
1. Build and run the extension scheme
2. Select a host app (Safari, Photos, etc.)
3. Share content and verify your extension appears
4. Test with different content types

**Action Extension:**
1. Build and run the extension scheme
2. Open content in a supported app
3. Tap the share/action button and select your action

**Keyboard Extension:**
1. Build and run the keyboard extension scheme
2. Go to Settings > General > Keyboard > Keyboards > Add New Keyboard
3. Select your keyboard
4. Open any text field and switch to your keyboard

**Safari Web Extension:**
1. Build and run the app (which contains the extension)
2. Go to Safari > Settings > Extensions
3. Enable your extension
4. Navigate to a web page and verify behavior

## Extension Lifecycle and Limits

### Memory Limits
- Share Extension: ~120 MB
- Action Extension: ~120 MB
- Keyboard Extension: ~48 MB (very constrained)
- Safari Web Extension: ~6 MB for content scripts

### Execution Limits
- Extensions must complete work quickly (no long background execution)
- Must call `completeRequest()` or `cancelRequest()` when done
- No access to HealthKit, CallKit, or some restricted frameworks
- Network requests are allowed but should be brief

### Extension Termination
The system can terminate extensions at any time for resource reclamation. Save state frequently and handle interruption gracefully.

## Gotchas

### completeRequest Must Be Called
The extension host waits for `extensionContext?.completeRequest(returningItems:)`. If you never call it, the share sheet hangs and the user is stuck. Always call it in both success and error paths.

### Keyboard Extensions Need Open Access for Network
By default keyboard extensions have no network access. The user must explicitly grant "Allow Full Access" in Settings. Without it, URLSession calls fail silently. Design your keyboard to work without network and enhance when access is granted.

### App Groups Require Matching Identifiers
The App Group identifier must be identical in both the main app and extension entitlements. A typo means `UserDefaults(suiteName:)` returns a different (empty) container.

### Safari Web Extension Content Scripts Run in Isolated World
Content scripts cannot directly access the page's JavaScript variables. Use `window.postMessage` or the browser messaging API to communicate between content scripts and the page.

### Extension Bundle Identifier Convention
Extension bundle identifiers must be prefixed with the main app bundle identifier:
- Main app: `com.yourcompany.myapp`
- Share Extension: `com.yourcompany.myapp.ShareExtension`

## References

- **templates.md** -- All production Swift templates for each extension type
- [App Extension Programming Guide](https://developer.apple.com/app-extensions/)
- [Creating a Share Extension](https://developer.apple.com/documentation/foundation/app_extension_support)
- [Custom Keyboard Guide](https://developer.apple.com/documentation/uikit/keyboards_and_input/creating_a_custom_keyboard)
- [Safari Web Extensions](https://developer.apple.com/documentation/safariservices/safari_web_extensions)
- Related: `generators/deep-linking` -- Handle URLs received via extensions
- Related: `generators/push-notifications` -- Notification extensions (Service/Content)

### Source: `generators/app-icon-generator`

# App Icon Generator

Generate an app icon programmatically with a CoreGraphics Swift script, resize it to every required size, and install it into the Xcode asset catalog — with appearance variants (light/dark/tinted).

## Read first — the Liquid Glass era (iOS 26 / macOS 26)

> **Apple icon standards verified as of July 2026** — Icon Composer, Xcode 26, macOS Tahoe 26.4+. This guidance is static (the skill does no per-run web lookup); if that date is well in the past or the OS has moved on, re-verify against the [HIG · App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) before trusting the specifics below.

Apple's shippable icon format changed. On iOS 26 / macOS 26 the modern app icon is a **layered, light-responsive Liquid Glass icon** authored in **Icon Composer** (free; ships with Xcode 26, needs macOS Tahoe 26.4+). You supply *flat* artwork in up to **four depth groups** (background → foreground); the **system renders the glass** — specular highlights, refraction, translucency, shadows — and masks the rounded-rect shape. One `.icon` file adapts across iPhone, iPad, Mac, and Apple Watch and across **Default / Dark / Mono (tinted)** appearances.

**So this skill does NOT produce the final iOS 26 icon.** Icon Composer is GUI-first; no script can author a true layered `.icon`. Its two honest roles are:

1. **Placeholder** — a fast flat 1024 PNG so early builds, TestFlight, and screenshots feel real before you invest in the real icon.
2. **Layered source art** — flat background / midground / foreground PNGs (or SVGs), effect-free, ready to drag into Icon Composer, where you assemble depth and export the `.icon`.

**What changed vs. the classic flow:**
- **Do not bake in lighting.** No pre-painted specular highlights, drop shadows, or gradients-used-as-lighting — the system owns those now, and baking them in double-exposes against the system glass. (The `drawShine`/`drawShadow` blocks below are **legacy-only**, off by default for iOS 26+ targets.)
- **Do not round the corners.** Icon Composer / the system apply the shape mask — fill a full square canvas.
- **SVG for shapes, PNG for effects** — vector where you can, raster only where you must.
- **Provide appearance variants** — light (default), dark, and tinted/mono. A single flat PNG only fills the light slot and won't adapt on iOS 18+.

**Detect the target first:** read the deployment target (`IPHONEOS_DEPLOYMENT_TARGET` / `MACOSX_DEPLOYMENT_TARGET` in the pbxproj, or `.planning/APP.md`). iOS 26+ / macOS 26+ → lead with the Icon Composer handoff and treat the flat PNG as a placeholder. Older targets → the classic flat + appearances path is fine to ship. **If the deployment target is newer than the "verified as of" date above, flag it to the user and re-verify the icon rules against the current HIG before generating** — the skill won't know about anything Apple shipped after that date.

## When This Skill Activates

Use this skill when the user:
- Asks to "generate an app icon" or "create an icon"
- Wants a "placeholder icon" or "app icon design"
- Mentions "icon for my app" or "need an app icon"
- Asks to "update the app icon"

## Pre-Generation Checks

### 1. Project Context Detection

```
Glob: **/Assets.xcassets/AppIcon.appiconset/Contents.json
```

- Identify platform: macOS, iOS, or universal
- Check for existing icon files (warn before overwriting)
- Read `Contents.json` to understand required sizes

### 2. App Context Detection

Gather app information to customize the icon:

```
Read: .planning/APP.md          (if exists — app definition)
Read: .planning/CODEBASE.md     (if exists — app description)
Grep: "CFBundleName" or app name in project files
```

If no planning files exist, ask the user.

## Configuration Questions

Ask via AskUserQuestion:

### Question 1: App Category
"What category best describes your app?"
- **Productivity** — Clean geometric shapes, blues/teals
- **Creative/Media** — Vibrant colors, camera/brush/music motifs
- **Developer Tools** — Dark backgrounds, terminal/code symbols
- **Utilities** — Functional shapes, neutral/system colors

### Question 2: Visual Style
"What visual style do you prefer?"
- **Bold Symbol** — Single prominent shape/icon centered (like the record button)
- **Contained Scene** — A scene inside a shape (like a monitor with elements)
- **Abstract Mark** — Geometric/abstract design (like viewfinder brackets)
- **Gradient Glyph** — SF Symbol-style glyph on gradient background

### Question 3: Color Palette
"What color palette fits your app?"
- **Deep Blue/Indigo** — Professional, trustworthy (navy #0f0c29 to indigo #302b63)
- **Teal/Cyan** — Fresh, modern (dark teal #0a1628 to blue #1a4a6b)
- **Purple/Violet** — Creative, premium (midnight #1a0533 to violet #4a1a8a)
- **Warm/Orange** — Energetic, friendly (dark red #2d1117 to orange #c0392b)

### Question 4: Accent Color
"What accent color for the focal element?"
- **Red** — Attention, recording, alerts (#ff453a to #d63031)
- **Blue** — Trust, communication (#007aff to #0056b3)
- **Green** — Success, nature, health (#34c759 to #248a3d)
- **Gold/Yellow** — Premium, energy (#ffd60a to #c7a600)

## Apple HIG Icon Guidelines

**Read `apple-hig-icons.md` before generating.**

**Timeless rules (all eras):**

1. **No text** in the icon — must be universally recognizable
2. **Single focal point** — one clear element the eye is drawn to
3. **Simple shapes** — legible at 16×16 (macOS menu bar) and at Home-screen size
4. **Fill a full square canvas** — never bake in rounded corners; the system / Icon Composer apply the shape mask
5. **Front-facing** — no 3D tilts or dramatic angles
6. **Ensure contrast** — the focal element must stand out from the background
7. **Platform-appropriate detail** — macOS can be more detailed (displays larger); iOS simpler

**Liquid Glass era rules (iOS 26 / macOS 26):**

8. **The system owns lighting.** No baked specular, drop shadows, or gradients-as-lighting — Icon Composer / the system add depth, refraction, and highlights. Keep artwork flat.
9. **Provide appearance variants** — light (default), dark, and tinted/mono. Make sure the mark reads on all three (tinted renders as a monochrome silhouette on a system-tinted background).
10. **Layer, don't flatten (final icon)** — organize art into ≤4 depth groups for Icon Composer; SVG for shapes, PNG only for texture.

## Designing the Icon (Apple's Rules)

Design-layer guidance from Apple's icon sessions (WWDC25) plus evergreen craft tests. The numbered rules above are the hard constraints; this is how to make the artwork good.

### Composition

- **One 1024×1024 canvas** drives every platform — except **watchOS, which uses 1088×1088**, deliberately overshooting the circular mask so edge-to-edge art survives the crop. Either way the system applies the mask.
- **Frontal, flat illustration** beats realistic 3D/perspective rendering — the glass material supplies the dimensionality, so pre-rendered depth fights it.
- **Fewer, rounder layers beat dense detail.** Avoid sharp edges and thin lines: rounder corners carry the glass lighting; bolder weights survive small sizes.
- **Soft gradients over flat fills.** For backgrounds, prefer the built-in **System Light / System Dark gradients** to pure white or black.
- **Colored backgrounds keep light, dark, and tinted modes distinct** — a neutral field collapses across appearances.
- **Translucency and blur are encouraged**, not risky: clear mode shows the wallpaper *through* the glass, so translucent layers are rewarded.

### Appearance modes

Author **three** variants — default, dark, mono — and the system derives **six** renders: default, dark, clear light/dark, tinted light/dark. Preview all six before shipping.

### Icon Composer craft details

1. Export artwork **flat and opaque**, each color region split into its own layer; SVG for flat graphics (**convert text to outlines** first), PNG for gradients and raster; export at canvas size.
2. Prefix layer filenames with a **Z-order number** so stacking imports deterministically.
3. Glass is applied **per layer** — if a narrow shape turns "pillowy", toggle that layer's specular off.
4. Tune per appearance: swap any fill that vanishes against black in dark mode; in mono keep **one prominent white element** and step the rest down to grays.
5. Choose **neutral vs chromatic shadows** per layer — chromatic tints the shadow with the layer's color, better for colorful art on light backgrounds.
6. Test on real wallpapers, with the grid overlay, and at small sizes — then ship the exported `.icon` into Xcode.

### Classic tests (evergreen)

- **One identifiable metaphor** — if you can't name the single thing the icon depicts, users can't either.
- **Squint test inside a folder**: still distinguishable among its neighbors?
- Check the **Settings-list render**, not only the Home Screen (Step 4.6) — it's the smallest surface users see daily.
- **Align key shapes to the icon grid** for optical balance (a guide, not a straitjacket).
- An icon is **identity with lineage** — refine it release over release; don't redesign from scratch every update.

## Generation Process

### Step 1: Determine Icon Design

Based on the user's answers (or app context), select:
- **Background**: Gradient direction, colors, optional radial glow
- **Primary Element**: The main shape/symbol
- **Secondary Elements**: Optional ring, glow, accent shapes
- **Style Modifiers**: stroke weight (⚠️ skip Shine/shadow for iOS 26+ targets — the system applies Liquid Glass specular and shadow; baking them in double-exposes)

### Step 2: Generate Swift Script

Create a self-contained Swift script at `scripts/generate-icon.swift` that:
- Uses `import AppKit` and `CoreGraphics` (no dependencies)
- Generates **3 variants** at 1024x1024
- Saves to `icon-variants/` directory
- Uses the design parameters from Step 1

**Script structure:**
```swift
#!/usr/bin/env swift
import AppKit
import CoreGraphics

let size: CGFloat = 1024
// ... helper functions (gradients, glows, shapes)
// ... variant generation functions
// ... save and output
```

**Design building blocks** (combine these based on category/style):

| Building Block | Function | Use For |
|---------------|----------|---------|
| `drawGradientBackground` | Linear gradient fill | All icons |
| `drawRadialGlow` | Soft colored glow behind focal element | Adding depth |
| `drawCircle` | Filled/stroked circle | Record buttons, dots, orbs |
| `drawRoundedRect` | Rounded rectangle | Screens, cards, containers |
| `drawRing` | Circle outline | Borders, focus rings |
| `drawBrackets` | Corner bracket marks | Viewfinders, capture |
| `drawMonitor` | Screen + stand shape | Screen/display apps |
| `drawShield` | Shield outline | Security/privacy apps |
| `drawGear` | Gear/cog shape | Settings/utility apps |
| `drawWaveform` | Audio waveform bars | Audio/music apps |
| `drawDocument` | Page with fold corner | Document/writing apps |
| `drawShine` | Elliptical specular highlight | ⚠️ Legacy only — off for iOS 26+ (system paints its own specular) |
| `drawShadow` | Drop shadow beneath element | ⚠️ Legacy only — off for iOS 26+ (system casts its own shadow) |

### Step 3: Run Script and Present Variants

```bash
swift scripts/generate-icon.swift
```

Show all 3 variants to the user using the Read tool (Claude can view images).
Ask the user to pick one, or request adjustments.

### Step 4: Resize and Install

Once the user picks a variant:

1. **Resize** using `sips` (built into macOS):

For **macOS** (10 sizes):
```bash
sips -z 16 16     master.png --out icon_16x16.png
sips -z 32 32     master.png --out icon_16x16@2x.png
sips -z 32 32     master.png --out icon_32x32.png
sips -z 64 64     master.png --out icon_32x32@2x.png
sips -z 128 128   master.png --out icon_128x128.png
sips -z 256 256   master.png --out icon_128x128@2x.png
sips -z 256 256   master.png --out icon_256x256.png
sips -z 512 512   master.png --out icon_256x256@2x.png
sips -z 512 512   master.png --out icon_512x512.png
sips -z 1024 1024 master.png --out icon_512x512@2x.png
```

For **iOS** (single 1024x1024):
```bash
cp master.png icon_1024x1024.png
```

2. **Write Contents.json** for the asset catalog

For **macOS**:
```json
{
  "images": [
    { "filename": "icon_16x16.png", "idiom": "mac", "scale": "1x", "size": "16x16" },
    { "filename": "icon_16x16@2x.png", "idiom": "mac", "scale": "2x", "size": "16x16" },
    { "filename": "icon_32x32.png", "idiom": "mac", "scale": "1x", "size": "32x32" },
    { "filename": "icon_32x32@2x.png", "idiom": "mac", "scale": "2x", "size": "32x32" },
    { "filename": "icon_128x128.png", "idiom": "mac", "scale": "1x", "size": "128x128" },
    { "filename": "icon_128x128@2x.png", "idiom": "mac", "scale": "2x", "size": "128x128" },
    { "filename": "icon_256x256.png", "idiom": "mac", "scale": "1x", "size": "256x256" },
    { "filename": "icon_256x256@2x.png", "idiom": "mac", "scale": "2x", "size": "256x256" },
    { "filename": "icon_512x512.png", "idiom": "mac", "scale": "1x", "size": "512x512" },
    { "filename": "icon_512x512@2x.png", "idiom": "mac", "scale": "2x", "size": "512x512" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

For **iOS** (single size, system generates others):
```json
{
  "images": [
    { "filename": "icon_1024x1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

3. **Copy files** into the asset catalog directory
4. **Build** to verify: `xcodebuild build -scheme <scheme> -destination 'platform=<platform>' -quiet`

### Step 4.5: Appearance variants & Icon Composer handoff

**Appearance variants (iOS 18+, scriptable).** For the flat path, generate three 1024 PNGs — light (default), dark, and a monochrome/tinted mark — and declare them so the icon adapts to the user's Home screen:

```json
{
  "images": [
    { "filename": "icon_light.png",  "idiom": "universal", "platform": "ios", "size": "1024x1024" },
    { "filename": "icon_dark.png",   "idiom": "universal", "platform": "ios", "size": "1024x1024",
      "appearances": [ { "appearance": "luminosity", "value": "dark" } ] },
    { "filename": "icon_tinted.png", "idiom": "universal", "platform": "ios", "size": "1024x1024",
      "appearances": [ { "appearance": "luminosity", "value": "tinted" } ] }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

**Icon Composer handoff (iOS 26+ / the shippable icon).** The flat PNGs above are a placeholder. For the real Liquid Glass icon:

1. Export the design as **flat layers** — background, midground, foreground — as SVG (shapes) or PNG (texture), with **no** baked highlights, shadows, or corners.
2. Open **Icon Composer** (Xcode 26 ▸ Open Developer Tool ▸ Icon Composer; needs macOS Tahoe 26.4+). Drag the layers in, organize into ≤4 depth groups, tune specular / refraction / translucency / shadow (don't overdo refraction), and check the Default / Dark / Mono previews.
3. **Export `.icon`** and add it to the target (it replaces the `AppIcon` set). Icon Composer also exports a flattened 1024 PNG for App Store marketing.

This is a manual GUI step by design — the skill prepares the layers and hands off; it does not author the `.icon`.

### Step 4.6: Validate Before Install (hard checks — do not skip)

An icon that "looks fine" as a 1024px file on a neutral canvas can still fail on a real Home Screen. All three checks below caught real shipped bugs:

1. **Adjacent-element contrast.** Any mark element that touches the icon *background* (a header band, badge ring, tab, outline) must clearly contrast with that background — same-hue-slightly-darker vanishes at Home Screen size, amputating part of the mark. Elements sitting on the card/mark interior only need contrast against the card.
2. **Judge at 60–64 px, not 1024.** `sips -Z 120` each variant and Read the small render — that's the size users see. Subtle contrast that survives at 1024 dies at 60.
3. **Tinted variant must be strictly grayscale.** iOS 18+ overlays the user's tint on the tinted variant; baked-in color renders wrong. Beware colors hardcoded *inside* shared draw functions — the tinted call site can pass gray arguments while the function paints brand color anyway. Parametrize every color per variant, then verify the exported PNG has zero saturation (e.g. a quick pixel scan).
4. **See it in place (required, not optional).** Build to a simulator and screenshot the Home Screen — the icon among other apps on a real wallpaper is the only honest review. Check light, dark, and tinted appearances.

### Step 5: Cleanup

- Keep `scripts/generate-icon.swift` for future regeneration
- Remove `icon-variants/` directory (or add to `.gitignore`)

## Category-Specific Design Recipes

### Productivity Apps
- **Background**: Deep blue (#0f1b3d) to teal (#1a4a6b)
- **Element**: Checkmark, list, or document shape in white
- **Accent**: Green checkmark or blue highlight
- **Style**: Clean, minimal, professional

### Creative/Media Apps
- **Background**: Dark purple (#1a0533) to magenta (#6b1a5c)
- **Element**: Camera lens, brush stroke, play button, or waveform
- **Accent**: Red record dot, orange/yellow creative spark
- **Style**: Vibrant, expressive

### Developer Tools
- **Background**: Near-black (#0d1117) to dark gray (#1a1a2e)
- **Element**: Terminal bracket `>_`, code braces `{}`, or gear
- **Accent**: Green (#34c759) or cyan (#00d4ff) terminal glow
- **Style**: Monospace feel, technical

### Communication Apps
- **Background**: Blue (#0a2463) to lighter blue (#1e5aa8)
- **Element**: Speech bubble, person silhouette, or connection lines
- **Accent**: White or light blue
- **Style**: Friendly, approachable

### Utility Apps
- **Background**: Dark gray (#1a1a2e) to medium gray (#2d2d44)
- **Element**: Gear, wrench, shield, or lightning bolt
- **Accent**: System blue (#007aff) or orange (#ff9500)
- **Style**: Functional, trustworthy

### Finance Apps
- **Background**: Dark green (#0a2e1a) to emerald (#1a6b3a)
- **Element**: Chart line, coin, or dollar symbol
- **Accent**: Gold (#ffd60a) or green (#34c759)
- **Style**: Secure, premium

### Health/Fitness Apps
- **Background**: Dark red (#2d1117) to pink (#6b1a3a)
- **Element**: Heart, activity ring, or pulse line
- **Accent**: Red (#ff3b30) or green (#34c759)
- **Style**: Energetic, motivating

### Education Apps
- **Background**: Deep blue (#0f0c29) to royal blue (#302b63)
- **Element**: Book, graduation cap, or lightbulb
- **Accent**: Yellow (#ffd60a) or white
- **Style**: Inspiring, trustworthy

## Output Summary

After completion, report:

```
Icon installed!

Type:     [placeholder flat icon | classic icon + appearances]
Master:   scripts/generate-icon.swift (re-run to regenerate)
Sizes:    [list] · appearances: [light/dark/tinted]
Location: [path to AppIcon.appiconset]

⚠️ For an iOS 26+ / macOS 26+ target this is a PLACEHOLDER. Finish the real
   Liquid Glass icon in Icon Composer (see the handoff step) before submitting.

Build and run to see it: Home screen (iOS) · menu bar / Finder / Spotlight (macOS).
```

## Iteration

If the user wants changes:
1. Modify the Swift script parameters (colors, shapes, sizes)
2. Re-run: `swift scripts/generate-icon.swift`
3. Show the updated variants
4. Resize and reinstall once approved

Common adjustment requests:
- "Make the record dot bigger/smaller" → adjust radius parameter
- "Different background color" → change gradient hex values
- "Add more depth" → add a radial glow (⚠️ not baked shine on iOS 26+ — add depth in Icon Composer instead)
- "Too busy, simplify" → remove secondary elements
- "Doesn't look good at small size" → increase stroke widths, simplify shapes

### Source: `generators/background-processing`

# Background Processing Generator

Generate production background processing infrastructure -- BGTaskScheduler for periodic refresh and long-running tasks, background URLSession for downloads/uploads that survive app termination, and silent push handling for server-triggered updates.

## When This Skill Activates

Use this skill when the user:
- Asks to "add background processing" or "background tasks"
- Mentions "BGTaskScheduler" or "BGAppRefreshTask" or "BGProcessingTask"
- Wants "background refresh" or "periodic background updates"
- Asks about "background downloads" or "background uploads"
- Mentions "silent push" or "content-available push notifications"
- Wants data to sync or update while the app is in the background
- Asks about "background fetch" or "background execution"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (BGTaskScheduler requires iOS 13+)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Existing Background Task Detection
Search for existing background task code:
```
Glob: **/*BackgroundTask*.swift, **/*BGTask*.swift, **/*BackgroundDownload*.swift
Grep: "BGTaskScheduler" or "BGAppRefreshTask" or "BGProcessingTask" or "backgroundSession"
```

If existing background code found:
- Ask if user wants to replace or augment it
- If augmenting, identify what is missing and generate only those pieces

### 3. Info.plist Check
Search for existing background modes configuration:
```
Grep: "BGTaskSchedulerPermittedIdentifiers" or "UIBackgroundModes"
```

Check for push notification entitlements if silent push is needed:
```
Glob: **/*.entitlements
Grep: "aps-environment"
```

## Configuration Questions

Ask user via AskUserQuestion:

1. **What background processing do you need?**
   - App refresh (lightweight periodic updates -- weather, feeds, content)
   - Data processing (long-running -- database cleanup, ML model updates, large syncs)
   - Background downloads (files, media, assets that survive app termination)
   - Silent push notifications (server-triggered content updates)
   - Multiple (select which combination)

2. **How often should background tasks run?**
   - Hourly (system decides exact timing, best-effort)
   - Every few hours (recommended for most apps)
   - Daily (content that changes infrequently)
   - On content change via push (server triggers update with silent push)

3. **Does the task need network access?**
   - Yes -- needs background fetch or download capability
   - No -- local processing only (database maintenance, cleanup)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `BackgroundTaskManager.swift` -- Central manager for registering and scheduling all background tasks
2. `BackgroundTaskConfiguration.swift` -- Info.plist keys, entitlements, and task identifier constants

### Step 3: Create Feature-Specific Files
Based on configuration:
3. `BackgroundDownloadManager.swift` -- If background downloads selected
4. `SilentPushHandler.swift` -- If silent push selected

### Step 4: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/BackgroundProcessing/`
- If `App/` exists -> `App/BackgroundProcessing/`
- Otherwise -> `BackgroundProcessing/`

## Output Format

After generation, provide:

### Files Created
```
BackgroundProcessing/
├── BackgroundTaskManager.swift        # BGTaskScheduler registration & scheduling
├── BackgroundTaskConfiguration.swift  # Task identifiers and Info.plist config
├── BackgroundDownloadManager.swift    # Background URLSession downloads (optional)
└── SilentPushHandler.swift            # Silent push handling (optional)
```

### Integration with App Lifecycle

**Register tasks at app launch (must happen before app finishes launching):**
```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        BackgroundTaskManager.shared.registerTasks()
        return true
    }
}
```

**Schedule refresh when app enters background:**
```swift
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            FeedView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                BackgroundTaskManager.shared.scheduleAppRefresh()
            }
        }
    }
}
```

**Start a background download:**
```swift
func downloadAsset(from url: URL) {
    BackgroundDownloadManager.shared.startDownload(from: url)
}
```

**Handle silent push in AppDelegate:**
```swift
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) async -> UIBackgroundFetchResult {
    await SilentPushHandler.shared.handle(userInfo: userInfo)
}
```

### Testing

**Simulate background task in Xcode debugger (LLDB):**
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.app.refresh"]
```

**Simulate expiration:**
```
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"com.app.refresh"]
```

**Test background download:**
```swift
#if DEBUG
func simulateBackgroundDownload() {
    let testURL = URL(string: "https://example.com/test-asset.zip")!
    BackgroundDownloadManager.shared.startDownload(from: testURL)
}
#endif
```

### Required Info.plist Configuration

Add to Info.plist:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.app.refresh</string>
    <string>com.app.processing</string>
</array>
```

### Required Background Modes

In Xcode: Target > Signing & Capabilities > Background Modes:
- **Background fetch** -- for BGAppRefreshTask
- **Background processing** -- for BGProcessingTask
- **Remote notifications** -- for silent push
- **Background download** -- for background URLSession (automatic when using background configuration)

## Common Patterns

### Schedule Refresh on Entering Background
Always schedule the next refresh when the app goes to background. The system decides when to actually run it.
```swift
BackgroundTaskManager.shared.scheduleAppRefresh()
```

### Long-Running Processing with Expiration Handling
BGProcessingTask can run for minutes, but always handle the `expirationHandler` to save progress.
```swift
task.expirationHandler = {
    // Save partial progress so next run can resume
    processingJob.saveCheckpoint()
}
```

### Energy-Efficient Background Work
```swift
// Only process on Wi-Fi + power
let request = BGProcessingTaskRequest(identifier: taskID)
request.requiresNetworkConnectivity = true
request.requiresExternalPower = true
```

## Gotchas

### Registration Must Happen Before didFinishLaunching Returns
`BGTaskScheduler.shared.register(forTaskWithIdentifier:)` must be called during `didFinishLaunchingWithOptions`. If called later, the registration silently fails. Always register in AppDelegate, never in a View.

### System Controls Scheduling
The system decides when to run background tasks based on battery, network, user patterns, and frequency. You cannot guarantee exact timing. `earliestBeginDate` is a hint, not a guarantee.

### Background URLSession Delegate Callbacks
Background URLSession delivers delegate callbacks even if the app was terminated and relaunched. The session must be recreated with the same identifier, and `application(_:handleEventsForBackgroundURLSession:completionHandler:)` must be implemented.

### Silent Push Limitations
Silent push notifications are rate-limited by APNs. If you send too many, the system throttles them. Use them for important content changes, not periodic polling.

### 30-Second Window for App Refresh
`BGAppRefreshTask` gives you approximately 30 seconds of execution time. For longer work, use `BGProcessingTask` instead (which can run for several minutes when conditions are met).

### Simulator Limitations
Background tasks do not run naturally on the Simulator. Use the LLDB `_simulateLaunchForTaskWithIdentifier:` command to trigger them manually during development.

## References

- **templates.md** -- All production Swift templates for background processing
- [Background Tasks Framework](https://developer.apple.com/documentation/backgroundtasks)
- [Downloading Files in the Background](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background)
- [Pushing Background Updates to Your App](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app)
- Related: `generators/push-notifications` -- Full push notification infrastructure
- Related: `generators/offline-queue` -- Queue operations for when back online

### Source: `generators/cloudkit-sync`

# CloudKit Sync Generator

Generate production-ready CloudKit sync infrastructure using `CKSyncEngine` (iOS 17+ / macOS 14+), the modern replacement for manual `CKOperation` chains.

## When This Skill Activates

Use this skill when the user:
- Asks to "add iCloud sync" or "sync data across devices"
- Mentions "CloudKit", "CKSyncEngine", or "cloud sync"
- Wants to "share data between users" via iCloud
- Asks about "conflict resolution" for synced data
- Mentions "CKRecord", "CKShare", or "CKRecordZone"

## Pre-Generation Checks

### 1. Project Context Detection

Before generating, ALWAYS check:

```bash
# Check deployment target (CKSyncEngine requires iOS 17+ / macOS 14+)
grep -r "platform" Package.swift 2>/dev/null || true
grep -r "IPHONEOS_DEPLOYMENT_TARGET\|MACOSX_DEPLOYMENT_TARGET" --include="*.pbxproj" | head -3

# Find existing CloudKit implementations
rg -l "CKSyncEngine\|CKContainer\|CKRecord\|CKOperation" --type swift | head -10

# Check for existing entitlements
find . -name "*.entitlements" -exec cat {} \; 2>/dev/null | grep -i "icloud"

# Check existing persistence layer
rg -l "@Model\|NSManagedObject\|PersistentModel" --type swift | head -5

# Check for existing sync infrastructure
rg "CKSyncEngineDelegate\|CKSubscription\|CKFetchRecordZoneChanges" --type swift | head -5
```

### 2. Compatibility Verification

**CKSyncEngine requires:**
- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+
- CloudKit entitlement
- Active iCloud account on device

If deployment target is below iOS 17 / macOS 14, warn the user that CKSyncEngine is not available and suggest either raising the target or using the older CKOperation approach (which this generator does not cover).

### 3. Conflict Detection

If existing CloudKit code is found:
- Ask: Replace existing implementation, extend it, or migrate to CKSyncEngine?

## Configuration Questions

Ask user via AskUserQuestion:

1. **What data needs syncing?**
   - Provide your model types (e.g., Note, Task, Document)
   - What properties does each model have?

2. **Database scope?**
   - Private only (user's own data across their devices)
   - Private + Shared (enable CKShare for collaboration)

3. **Conflict resolution strategy?**
   - Server-wins (simplest -- always accept server version)
   - Client-wins (always push local version)
   - Timestamp-based merge (most recent modification wins)
   - Custom merge (field-level merge logic)

4. **Existing persistence layer?**
   - SwiftData (will generate CKRecord <-> SwiftData bridging)
   - Core Data (will generate CKRecord <-> NSManagedObject bridging)
   - Custom / in-memory (will generate standalone CKRecord mapping)
   - None yet (will generate lightweight local store + sync)

## Generation Process

### Step 1: Read Templates

Read code templates from this skill:
- `templates.md` - All CKSyncEngine code templates

### Step 2: Create Core Files

Generate these files based on configuration:

**Always generate:**
```
Sources/CloudSync/
├── SyncEngine.swift              # CKSyncEngine setup + CKSyncEngineDelegate
├── SyncConfiguration.swift       # Zone names, container ID, database scope
├── RecordMapping.swift           # CKRecord <-> local model conversion
├── ConflictResolver.swift        # Conflict resolution strategy
├── SyncMonitor.swift             # Account status + sync state observation
└── CloudSyncError.swift          # Typed error handling with CKError mapping
```

**If sharing enabled:**
```
Sources/CloudSync/Sharing/
├── ShareManager.swift            # CKShare creation and management
└── ShareParticipantView.swift    # UICloudSharingController wrapper
```

### Step 3: Determine File Location

Check project structure:
- If `Sources/` exists -> `Sources/CloudSync/`
- If `App/` exists -> `App/CloudSync/`
- Otherwise -> `CloudSync/`

### Step 4: Customize for Project

Adapt templates to match:
- User's model types and property names
- Bundle identifier for CloudKit container ID
- Chosen conflict resolution strategy
- Database scope (private only vs. private + shared)

### Step 5: Entitlements Setup

Generate or update entitlements file with required CloudKit capabilities.

## Entitlements and Capabilities Setup

### Required Xcode Capabilities

1. **iCloud** capability:
   - Check "CloudKit"
   - Add container: `iCloud.com.<team-identifier>.<app-bundle-id>`

2. **Background Modes** (recommended):
   - Check "Remote notifications" (for push-based sync triggers)

### Required Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.yourcompany.yourapp</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
</dict>
</plist>
```

### CloudKit Dashboard Setup

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/)
2. Select your container
3. Record types are auto-created when you first save a CKRecord of that type during development
4. **Deploy schema to production before App Store release**
5. Indexes are required for queryable fields -- add them in the dashboard

## Output Format

After generation, provide:

### Files Created

```
Sources/CloudSync/
├── SyncEngine.swift              # CKSyncEngine + delegate implementation
├── SyncConfiguration.swift       # Container, zone, and scope config
├── RecordMapping.swift           # CKRecord <-> model bridging
├── ConflictResolver.swift        # Pluggable conflict resolution
├── SyncMonitor.swift             # Account status + sync state
├── CloudSyncError.swift          # Error types with CKError mapping
└── Sharing/                      # (if sharing enabled)
    ├── ShareManager.swift        # CKShare lifecycle
    └── ShareParticipantView.swift
```

### Integration Steps

**1. Initialize the sync engine at app launch:**

```swift
@main
struct MyApp: App {
    @State private var syncEngine = SyncEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(syncEngine)
                .task {
                    await syncEngine.start()
                }
        }
    }
}
```

**2. Send local changes to CloudKit:**

```swift
// After saving a local model
let recordID = CKRecord.ID(recordName: item.id.uuidString, zoneID: SyncConfiguration.zoneID)
syncEngine.addPendingChange(.saveRecord(recordID))
```

**3. Handle incoming changes in your model layer:**

The `SyncEngine` delegate methods automatically call `RecordMapping` to convert fetched `CKRecord` objects into your local model types and persist them.

**4. Monitor sync status in the UI:**

```swift
struct SyncStatusView: View {
    @Environment(SyncMonitor.self) private var syncMonitor

    var body: some View {
        HStack {
            if syncMonitor.isSyncing {
                ProgressView()
                Text("Syncing...")
            } else if let error = syncMonitor.lastError {
                Image(systemName: "exclamationmark.icloud")
                Text(error.localizedDescription)
            } else {
                Image(systemName: "checkmark.icloud")
                Text("Up to date")
            }
        }
    }
}
```

### Testing

**Use a separate CloudKit container for development:**

```swift
#if DEBUG
let containerID = "iCloud.com.yourcompany.yourapp.dev"
#else
let containerID = "iCloud.com.yourcompany.yourapp"
#endif
```

**Test account status handling:**

```swift
@Test
func handlesNoAccountGracefully() async {
    let monitor = SyncMonitor()
    await monitor.handleAccountStatus(.noAccount)
    #expect(monitor.accountAvailable == false)
    #expect(monitor.lastError is CloudSyncError)
}
```

**Test conflict resolution:**

```swift
@Test
func serverWinsConflictResolution() {
    let resolver = ConflictResolver(strategy: .serverWins)
    let serverRecord = makeCKRecord(title: "Server Version", modifiedAt: .now)
    let clientRecord = makeCKRecord(title: "Client Version", modifiedAt: .distantPast)

    let resolved = resolver.resolve(server: serverRecord, client: clientRecord)
    #expect(resolved["title"] == "Server Version")
}
```

## Verification Checklist

After generation, verify:

- [ ] App compiles without errors
- [ ] Entitlements file contains CloudKit container identifier
- [ ] CloudKit container exists in Apple Developer portal
- [ ] CKSyncEngine initializes without crash
- [ ] Local changes appear as pending record zone changes
- [ ] Fetched changes are converted to local models
- [ ] Conflict resolution behaves as configured
- [ ] Account status changes are observed and surfaced to UI
- [ ] (If sharing) CKShare can be created and participants added
- [ ] App handles offline gracefully (queues changes)
- [ ] App handles "no iCloud account" gracefully

## Common Customizations

### Adding a New Synced Model Type

1. Add `CKRecord` field mapping in `RecordMapping.swift`
2. Register the record zone in `SyncConfiguration.swift` (if using a separate zone)
3. Update `nextRecordZoneChangeBatch()` to include pending changes for the new type

### Switching Conflict Resolution

```swift
// Change strategy without touching sync engine code
let resolver = ConflictResolver(strategy: .timestampMerge)
let config = SyncConfiguration(conflictResolver: resolver)
```

### Adding Shared Database Support

1. Set `databaseScope` to include `.shared` in `SyncConfiguration`
2. Add `ShareManager` to handle `CKShare` lifecycle
3. Wrap `UICloudSharingController` for the sharing UI

## Troubleshooting

### Sync Not Working

1. Verify device is signed into iCloud (Settings > Apple Account)
2. Check entitlements match the CloudKit container identifier exactly
3. Confirm container exists in CloudKit Dashboard
4. Look for CKError logs in Console.app -- filter by "CloudKit"
5. Ensure `CKSyncEngine` is started (not just initialized)

### "User Did Not Sign In" Error

- `CKAccountStatus.noAccount` -- prompt user to sign into iCloud
- `CKAccountStatus.restricted` -- parental controls or MDM restriction
- `CKAccountStatus.temporarilyUnavailable` -- retry after delay

### Schema Deployment

- Development schema changes are automatic
- **Production schema must be explicitly deployed** from CloudKit Dashboard
- Schema changes in production are additive only (cannot remove fields)

### Rate Limiting

- CloudKit has per-user rate limits
- `CKError.requestRateLimited` includes `retryAfterSeconds` in `userInfo`
- `CKSyncEngine` handles most retry logic automatically

## References

- **templates.md** -- All code templates for CKSyncEngine infrastructure
- [CKSyncEngine Documentation](https://developer.apple.com/documentation/cloudkit/cksyncengine)
- [CloudKit Overview](https://developer.apple.com/documentation/cloudkit)
- [Sharing CloudKit Data](https://developer.apple.com/documentation/cloudkit/shared_records)
- [CloudKit Dashboard](https://icloud.developer.apple.com/)

### Source: `generators/consent-flow`

# Consent Flow Generator

Generate a production privacy consent system with granular category-based consent, persistent state management, a consent banner and preferences UI, audit logging for compliance, and App Tracking Transparency integration.

## When This Skill Activates

Use this skill when the user:
- Asks about "privacy consent" or "consent management"
- Mentions "GDPR consent" or "GDPR compliance"
- Wants "cookie consent" or "tracking consent"
- Mentions "ATT prompt" or "App Tracking Transparency"
- Asks for "privacy preferences" or "consent preferences"
- Mentions "CCPA compliance" or "DPDP compliance"
- Wants to "manage user consent" or "consent banner"
- Asks about "consent audit log" or "consent records"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing consent or privacy code:
```
Glob: **/*Consent*.swift, **/*Privacy*.swift, **/*Tracking*.swift, **/*GDPR*.swift
Grep: "ATTrackingManager" or "ConsentManager" or "trackingAuthorizationStatus"
```

If third-party library found (OneTrust, Usercentrics, CookieBot):
- Ask if user wants to replace or keep it
- If keeping, don't generate — advise on integration best practices instead

### 3. ATT Framework Availability
Check for App Tracking Transparency framework:
```
Grep: "AppTrackingTransparency" in project files
Grep: "NSUserTrackingUsageDescription" in Info.plist
```

If `NSUserTrackingUsageDescription` is missing from Info.plist, warn the user that ATT requires this key and offer to add it.

### 4. Platform Detection
Determine if generating for iOS (primary ATT target) or macOS (ATT not applicable) or both.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Target regulations?**
   - GDPR only (EU — opt-in model)
   - CCPA only (California — opt-out model)
   - DPDP only (India — consent-based)
   - All regulations (recommended for global apps)

2. **Consent categories?** (multi-select)
   - Essential (always on, cannot be disabled)
   - Analytics (usage tracking, crash reporting)
   - Marketing (advertising, attribution)
   - Personalization (recommendations, content tailoring)
   - Functional (preferences, saved settings beyond essential)

3. **Include ATT integration?**
   - Yes — request ATT permission before any tracking (recommended for iOS)
   - No — handle consent without ATT (macOS, or no IDFA usage)

4. **Consent UI style?**
   - Bottom banner with manage preferences (recommended)
   - Full-screen consent view (for first launch)
   - Settings-embedded (preferences in app settings, no banner)
   - Banner + Settings (banner on first launch, preferences in settings)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.
Read `patterns.md` for compliance rules, regulation differences, and UX guidance.

### Step 2: Create Core Files
Generate these files:
1. `ConsentCategory.swift` — Enum of consent categories with metadata
2. `ConsentDecision.swift` — Per-category consent state with timestamp
3. `ConsentManager.swift` — @Observable manager with persistence and ATT integration
4. `ConsentAuditLog.swift` — Compliance audit trail with JSON export

### Step 3: Create UI Files
5. `ConsentBannerView.swift` — Animated slide-up consent banner
6. `ConsentPreferencesView.swift` — Detailed toggle list for each category

### Step 4: Create Optional Files
Based on configuration:
- `ConsentRegulationConfig.swift` — If multiple regulations selected
- `ConsentATTBridge.swift` — If ATT integration selected (extracted for testability)

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/Consent/`
- If `App/` exists → `App/Consent/`
- Otherwise → `Consent/`

## Output Format

After generation, provide:

### Files Created
```
Consent/
├── ConsentCategory.swift        # Consent category enum with metadata
├── ConsentDecision.swift         # Per-category decision with timestamp
├── ConsentManager.swift          # @Observable manager with persistence
├── ConsentAuditLog.swift         # Compliance audit trail
├── ConsentBannerView.swift       # Animated consent banner
├── ConsentPreferencesView.swift  # Granular preferences UI
├── ConsentRegulationConfig.swift # Multi-regulation rules (optional)
└── ConsentATTBridge.swift        # ATT integration bridge (optional)
```

### Integration Steps

**Show consent on first launch:**
```swift
@main
struct MyApp: App {
    @State private var consentManager = ConsentManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(consentManager)
                .overlay(alignment: .bottom) {
                    if consentManager.needsConsent {
                        ConsentBannerView()
                            .environment(consentManager)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: consentManager.needsConsent)
        }
    }
}
```

**Check consent before tracking:**
```swift
func trackEvent(_ event: AnalyticsEvent) {
    guard consentManager.hasConsent(for: .analytics) else { return }
    analyticsService.track(event)
}

func showPersonalizedAd() {
    guard consentManager.hasConsent(for: .marketing) else {
        showGenericAd()
        return
    }
    adService.showPersonalized()
}
```

**Open preferences from settings:**
```swift
NavigationLink("Privacy Preferences") {
    ConsentPreferencesView()
        .environment(consentManager)
}
```

**Export audit log for data requests:**
```swift
func handleDataRequest() async throws -> Data {
    let auditLog = ConsentAuditLog.shared
    return try auditLog.exportJSON()
}
```

### Testing

```swift
@Test
func consentGrantedPersistsAcrossLaunches() async {
    let defaults = UserDefaults(suiteName: "test")!
    defaults.removePersistentDomain(forName: "test")
    let manager = ConsentManager(defaults: defaults)

    manager.updateConsent(for: .analytics, granted: true)

    let manager2 = ConsentManager(defaults: defaults)
    #expect(manager2.hasConsent(for: .analytics) == true)
}

@Test
func essentialConsentCannotBeRevoked() {
    let manager = ConsentManager()
    manager.updateConsent(for: .essential, granted: false)
    #expect(manager.hasConsent(for: .essential) == true) // Always granted
}

@Test
func auditLogRecordsDecisions() {
    let log = ConsentAuditLog(directory: tempDirectory)
    log.record(category: .analytics, granted: true, regulation: .gdpr)

    let entries = log.allEntries()
    #expect(entries.count == 1)
    #expect(entries[0].category == .analytics)
    #expect(entries[0].granted == true)
}

@Test
func denyAllRevokesNonEssentialCategories() {
    let manager = ConsentManager()
    manager.grantAll()
    manager.denyAllNonEssential()

    #expect(manager.hasConsent(for: .essential) == true)
    #expect(manager.hasConsent(for: .analytics) == false)
    #expect(manager.hasConsent(for: .marketing) == false)
}
```

## Common Patterns

### Show Consent on First Launch
```swift
.onAppear {
    if consentManager.needsConsent {
        // Banner auto-shows via overlay
    }
}
```

### Update Preferences Later
```swift
Button("Privacy Settings") {
    showPreferences = true
}
.sheet(isPresented: $showPreferences) {
    ConsentPreferencesView()
        .environment(consentManager)
}
```

### Check Consent Before Any Tracking Call
```swift
extension ConsentManager {
    func executeIfConsented(
        category: ConsentCategory,
        action: () -> Void
    ) {
        guard hasConsent(for: category) else { return }
        action()
    }
}
```

### Export Audit Log for Data Subject Requests
```swift
let jsonData = try consentManager.auditLog.exportJSON()
// Attach to email or upload to compliance endpoint
```

## Gotchas

### ATT Must Be Requested Before Any Tracking
Apple rejects apps that access IDFA before calling `ATTrackingManager.requestTrackingAuthorization`. Always request ATT first, then enable tracking SDKs based on the result.

### GDPR Requires Opt-In (Not Opt-Out)
Under GDPR, all non-essential tracking requires explicit opt-in consent. Pre-checked boxes or implied consent are not valid. The default state for all non-essential categories must be `.notDetermined`, not `.granted`.

### Consent Must Be As Easy to Withdraw As to Grant
GDPR Article 7(3): "It shall be as easy to withdraw as to give consent." If consent is granted with one tap on a banner, it must be revocable with equal ease — not buried 5 screens deep in settings.

### Different Regulations Have Different Age Thresholds
- GDPR: 16 years (member states can lower to 13)
- CCPA: 16 years for sale of data, 13 for minors
- DPDP: 18 years (parental consent required below)

If your app serves minors, you need age verification before consent collection.

### Don't Block the UI on ATT
`ATTrackingManager.requestTrackingAuthorization` is async and shows a system dialog. Never call it during app launch or in a way that blocks the main UI. Show your own consent banner first, then request ATT as a secondary step.

### Consent State Must Survive App Reinstall (GDPR)
For GDPR compliance, consider syncing consent state to a server. UserDefaults is deleted on app uninstall. If a user reinstalls, you must re-request consent — never assume prior consent.

## References

- **templates.md** — All production Swift templates for consent flow
- **patterns.md** — Regulation comparison, ATT details, UX best practices, anti-patterns
- Related: `generators/permission-priming` — Pre-permission UI patterns (ATT priming)
- Related: `generators/analytics-setup` — Analytics that respects consent state
- Related: `generators/settings-screen` — Embedding consent preferences in settings
