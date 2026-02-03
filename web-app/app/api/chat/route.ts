
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    try {
        const { prompt } = await req.json();

        // In Kubernetes, we talk to the Service DNS
        // Using /api/chat is better for Llama 3 (Instruct models)
        const OLLAMA_URL = process.env.OLLAMA_URL || 'http://ollama.default.svc.cluster.local:11434/api/chat';

        console.log(`Sending chat to: ${OLLAMA_URL}`);

        const res = await fetch(OLLAMA_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                model: "llama3:latest", // Explicitly use the tag we pulled
                messages: [{ role: "user", content: prompt }], // Reformatted for Chat API
                stream: false
            }),
        });

        if (!res.ok) {
            console.error("Ollama Error", res.status, res.statusText);
            const errorText = await res.text();
            console.error("Ollama Error Details:", errorText);
            return NextResponse.json({ response: `Error: ${res.statusText} - ${errorText}` }, { status: res.status });
        }

        const data = await res.json();
        const reply = data.message?.content || "No response content.";
        return NextResponse.json({ response: reply });

    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ response: 'System Critical Failure.' }, { status: 500 });
    }
}
