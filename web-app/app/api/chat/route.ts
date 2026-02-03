
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    try {
        const { prompt } = await req.json();

        // In Kubernetes, we talk to the Service DNS
        // "ollama" is the service name, "default" is the namespace
        // PORT 11434 is standard for Ollama
        const OLLAMA_URL = process.env.OLLAMA_URL || 'http://ollama.default.svc.cluster.local:11434/api/generate';

        // Development fallback (if running locally on laptop)
        // You can set OLLAMA_URL=http://localhost:11434/api/generate in .env.local

        console.log(`Sending prompt to: ${OLLAMA_URL}`);

        const res = await fetch(OLLAMA_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                model: "llama3", // Or whatever model you pulled
                prompt: prompt,
                stream: false // Simple non-streaming for now
            }),
        });

        if (!res.ok) {
            console.error("Ollama Error", res.status, res.statusText);
            return NextResponse.json({ response: "Error: Neural Core Unreachable." }, { status: 500 });
        }

        const data = await res.json();
        return NextResponse.json({ response: data.response });

    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ response: 'System Critical Failure.' }, { status: 500 });
    }
}
