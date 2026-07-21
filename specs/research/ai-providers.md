# AI provider evaluation

Status: Research snapshot

Evaluated: 2026-07-20

Pricing, limits, models, and provider terms change frequently. Re-check the linked
official sources before implementation or release.

## Recommendation

Use a bring-your-own-key model for the MVP and implement Google Gemini first with
stable `gemini-3.5-flash`.

Reasons:

- free API quota is available
- text and image inputs fit the planned capture modes
- structured JSON output supports the nutrition contract
- a user-owned key avoids shipping a shared project secret or operating a backend
- the paid tier remains inexpensive if users later upgrade

Gemini's terms differ by service tier and region. Outside the EEA, Switzerland,
and UK, unpaid-service content may be used to improve Google products and may be
human reviewed. The app must show provider-specific disclosure before enabling a
provider. Google states that EEA/Switzerland/UK unpaid quota receives the paid-data
treatment, but the app must not infer a user's legal region solely from locale.

Official sources:

- https://ai.google.dev/gemini-api/docs/pricing
- https://ai.google.dev/gemini-api/docs/billing
- https://ai.google.dev/gemini-api/docs/structured-output
- https://ai.google.dev/gemini-api/docs/deprecations
- https://ai.google.dev/gemini-api/terms

## Alternatives

### OpenAI

OpenAI provides mature image input and structured outputs. `gpt-5-nano` is a low
cost candidate, but its documented API free tier is not supported. It is a good
second adapter for users who already have funded API accounts, not the zero-cost
default.

Official source:

- https://developers.openai.com/api/docs/models/gpt-5-nano

### Groq

Groq has a free plan and OpenAI-compatible APIs. Its currently documented
`qwen/qwen3.6-27b` supports image input and JSON mode. It is a useful experimental
adapter, but rapidly changing model availability makes it less suitable as the
only default. A previously suitable vision model was deprecated on the evaluation
date, illustrating this lifecycle risk.

Official sources:

- https://console.groq.com/docs/rate-limits
- https://console.groq.com/docs/vision
- https://console.groq.com/docs/deprecations

### Mistral

Mistral documents a free API mode, with exact organization limits shown in its
console. It remains a possible European alternative. It is deferred until its
current multimodal model, schema behavior, quota, and data terms are evaluated in
an implementation spike.

Official source:

- https://docs.mistral.ai/admin/billing-usage/usage-limits

## Credential strategy

- MVP: users paste their own provider API key.
- Keys remain in platform-backed secure storage and requests go directly to the
  chosen provider over TLS.
- The app ships without a project-owned AI key.
- Provider adapters expose capabilities so text, image, and strict-schema support
  can be enabled independently.
- A future managed option uses a server-side gateway with quotas and abuse
  protection; it never embeds a shared key in a mobile binary.

## Provider acceptance tests

Before enabling a provider in a release, verify:

- German and English food descriptions
- text and image capability claims used by the app
- schema-conformant output and semantic validation
- invalid-key, rate-limit, timeout, and policy-rejection mapping
- redaction of credentials and meal content from diagnostics
- current pricing, data-use notice, and model lifecycle status
