'use client';

import { useState, useRef, useEffect } from 'react';
import Image from 'next/image';
import { Send, Terminal, ShieldAlert } from 'lucide-react';

export default function Home() {
  const [messages, setMessages] = useState([
    { role: 'assistant', content: 'System Online. Protocol: Sowrakasha. \nReady for orders.' }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    const userMessage = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: input }),
      });

      const data = await response.json();
      setMessages(prev => [...prev, { role: 'assistant', content: data.response }]);
    } catch (error) {
      setMessages(prev => [...prev, { role: 'assistant', content: 'CONNECTION SEVERED. RETRYING...' }]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen flex-col bg-black text-red-500 font-mono selection:bg-red-900 selection:text-white">
      {/* Glitch Keyframes */}
      <style jsx global>{`
        @keyframes pulse-red {
          0%, 100% { box-shadow: 0 0 5px #ff0000, 0 0 10px #ff0000; }
          50% { box-shadow: 0 0 2px #550000, 0 0 5px #550000; }
        }
        @keyframes glitch {
          0% { transform: translate(0); }
          20% { transform: translate(-2px, 2px); }
          40% { transform: translate(-2px, -2px); }
          60% { transform: translate(2px, 2px); }
          80% { transform: translate(2px, -2px); }
          100% { transform: translate(0); }
        }
        .glitch-hover:hover {
          animation: glitch 0.3s cubic-bezier(.25, .46, .45, .94) both infinite;
        }
        .scanline {
          background: linear-gradient(to bottom, rgba(255,0,0,0), rgba(255,0,0,0) 50%, rgba(255,0,0,0.1) 50%, rgba(255,0,0,0.1));
          background-size: 100% 4px;
          position: fixed;
          top: 0; left: 0; right: 0; bottom: 0;
          pointer-events: none;
          z-index: 50;
        }
      `}</style>

      <div className="scanline"></div>

      {/* Header */}
      <div className="border-b border-red-900/50 bg-black/80 p-4 backdrop-blur sticky top-0 z-10">
        <div className="max-w-4xl mx-auto flex items-center gap-4">
          <div className="relative h-12 w-12 glitch-hover cursor-pointer border border-red-800 rounded-lg overflow-hidden shadow-[0_0_15px_rgba(255,0,0,0.3)]">
            <Image
              src="/logo.png"
              alt="Sowrakasha Logo"
              fill
              className="object-cover"
            />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-widest text-red-600 drop-shadow-[0_0_5px_rgba(255,0,0,0.8)]">
              SOWRAKASHA_AI
            </h1>
            <div className="flex items-center gap-2 text-[10px] text-red-800 uppercase">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
              </span>
              System Active
            </div>
          </div>
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 max-w-4xl mx-auto w-full p-4 space-y-6 overflow-y-auto pb-32">
        {messages.map((msg, idx) => (
          <div
            key={idx}
            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[85%] rounded border p-4 backdrop-blur-sm ${msg.role === 'user'
                  ? 'bg-red-950/20 border-red-800 text-red-100 shadow-[0_0_10px_rgba(153,27,27,0.2)]'
                  : 'bg-black border-red-900/50 text-red-400 shadow-[0_0_5px_rgba(255,0,0,0.1)]'
                }`}
            >
              <div className="mb-1 text-[10px] uppercase tracking-wider opacity-50 flex items-center gap-2">
                {msg.role === 'user' ? (
                  <>USER <span className="text-red-500">❯❯</span></>
                ) : (
                  <><Terminal size={10} /> CORE</>
                )}
              </div>
              <p className="whitespace-pre-wrap leading-relaxed">{msg.content}</p>
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-black border border-red-900/30 p-3 rounded text-red-700 text-xs animate-pulse">
              _COMPUTING_TENSOR_OPERATIONS...
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      <div className="fixed bottom-0 w-full bg-black/90 border-t border-red-900/50 p-4 backdrop-blur-md z-20">
        <div className="max-w-4xl mx-auto">
          <form onSubmit={handleSubmit} className="relative group">
            <div className="absolute -inset-0.5 bg-red-600 rounded opacity-20 blur group-hover:opacity-40 transition duration-500"></div>
            <div className="relative flex items-center bg-black border border-red-800 p-1">
              <span className="pl-3 text-red-600 font-bold">❯</span>
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Execute command..."
                className="flex-1 bg-transparent px-4 py-3 text-sm text-red-100 placeholder-red-900/50 focus:outline-none font-mono"
                autoFocus
              />
              <button
                type="submit"
                disabled={isLoading || !input.trim()}
                className="p-2 text-red-600 hover:text-white hover:bg-red-900 transition disabled:opacity-50 disabled:hover:bg-transparent"
              >
                <Send size={18} />
              </button>
            </div>
          </form>

          {/* Footer Attribution */}
          <div className="mt-2 text-center text-[10px] text-red-900/40 uppercase tracking-[0.2em] hover:text-red-600 transition-colors duration-500 cursor-help">
            Constructed by Sharath
          </div>
        </div>
      </div>
    </main>
  );
}
