# AI Platform — LaravelAutoScript v2

LaravelAutoScript v2 provides a provider-agnostic AI platform foundation for Laravel applications.

## AI Configuration Parameters
Configured securely in `.env` without exposing keys or committing secrets:

```env
AI_PROVIDER=openai
AI_MODEL=gpt-4o
AI_API_KEY=
EMBEDDING_MODEL=text-embedding-3-small
VECTOR_STORE=pgvector
```

## CLI Usage
```bash
laravelautoscript ai sdk --project ./my-app --provider openai --model gpt-4o
```
