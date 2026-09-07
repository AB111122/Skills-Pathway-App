# Skills-Pathway-App

## AI assistant configuration

The career assistant uses an OpenAI-compatible chat-completions endpoint. Configure
the demo build without putting a secret in Dart source:

```text
flutter run --dart-define=AI_API_KEY=your-key
```

Optional overrides are `AI_API_ENDPOINT` and `AI_MODEL`. The default endpoint is
OpenAI's API and the default model is `gpt-4o-mini`. For production, proxy these
requests through a trusted backend because a client-side key can be extracted from
an APK. When no key is configured, the app shows a configuration error instead of
pretending that a canned response came from an AI model.