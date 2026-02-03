'use client';

import { useState, useRef, useEffect } from 'react';
import { Send, Terminal, Cpu, ShieldCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import ReactMarkdown from 'react-markdown';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

// UTILS
function cn(...inputs: (string | undefined | null | false)[]) {
  return twMerge(clsx(inputs));
}

type Message = {
  role: 'user' | 'assistant';
  content: string;
};

export default function Home() {
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<Message[]>([
    { role: 'assistant', content: 'Systems Online. \n\nI am **Sowrakasha**, your digital twin architected by **Sharath**. \n\nHow can I serve our mission today?' }
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMsg = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMsg }]);
    setIsLoading(true);

    try {
      // Connect to our internal API (which proxies to Ollama)
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: userMsg }),
      });

      if (!res.ok) throw new Error('Network response was not ok');
      const data = await res.json();

      setMessages(prev => [...prev, { role: 'assistant', content: data.response }]);
    } catch (error) {
      setMessages(prev => [...prev, { role: 'assistant', content: `**Error:** Connection to Neural Core failed. \n\nCheck if the GKE Cluster is active.` }]);
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen flex-col bg-[#050505] text-gray-100 font-sans selection:bg-purple-900 selection:text-white">

      {/* HEADER */}
      <header className="sticky top-0 z-50 border-b border-gray-800/50 bg-[#050505]/80 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-6">
          <div className="flex items-center gap-2">
            <div className="relative flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-purple-600 to-blue-600 shadow-[0_0_15px_rgba(124,58,237,0.5)]">
              <ShieldCheck className="h-5 w-5 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-tight text-white">Sowrakasha AI</h1>
              <p className="text-[10px] font-medium tracking-widest text-gray-500 uppercase">
                Forged By Sharath
              </p>
            </div>
          </div>

          <div className="flex items-center gap-4 text-xs font-mono text-gray-500">
            <div className="flex items-center gap-1.5 rounded-full bg-gray-900 px-3 py-1 border border-gray-800">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
              </span>
              <span>GKE: ONLINE</span>
            </div>
            <div className="hidden sm:flex items-center gap-1.5">
              <Cpu className="h-3 w-3" />
              <span>vLLM</span>
            </div>
          </div>
        </div>
      </header>

      {/* CHAT AREA */}
      <div className="flex-1 overflow-hidden relative">
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"></div>
        <div className="absolute left-0 right-0 top-0 -z-10 m-auto h-[310px] w-[310px] rounded-full bg-purple-500 opacity-5 blur-[100px]"></div>

        <div className="mx-auto flex h-full max-w-3xl flex-col px-4 pt-10 pb-4">
          <div
            ref={scrollRef}
            className="flex-1 space-y-6 overflow-y-auto pr-2 scrollbar-thin scrollbar-track-transparent scrollbar-thumb-gray-800"
          >
            <AnimatePresence initial={false}>
              {messages.map((m, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3 }}
                  className={cn(
                    "flex w-full",
                    m.role === 'user' ? "justify-end" : "justify-start"
                  )}
                >
                  <div className={cn(
                    "max-w-[85%] rounded-2xl px-5 py-3.5 shadow-sm text-sm leading-relaxed",
                    m.role === 'user'
                      ? "bg-gradient-to-br from-purple-700 to-indigo-700 text-white shadow-purple-900/20"
                      : "bg-gray-900/80 border border-gray-800 text-gray-200 backdrop-blur-sm"
                  )}>
                    <ReactMarkdown className="prose prose-invert prose-p:my-1 prose-pre:bg-black/50 prose-pre:p-2 prose-pre:rounded-lg">
                      {m.content}
                    </ReactMarkdown>
                  </div>
                </motion.div>
              ))}

              {isLoading && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="flex w-full justify-start"
                >
                  <div className="max-w-[85%] rounded-2xl px-5 py-3.5 bg-gray-900/50 border border-gray-800/50 text-gray-400">
                    <div className="flex items-center gap-2">
                      <Terminal className="h-3 w-3 animate-spin" />
                      <span className="text-xs font-mono">Thinking...</span>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* INPUT */}
          <div className="mt-6">
            <form onSubmit={handleSubmit} className="relative group">
              <div className="absolute -inset-0.5 rounded-xl bg-gradient-to-r from-purple-600 to-blue-600 opacity-30 blur transition duration-1000 group-hover:opacity-60 group-hover:duration-200"></div>
              <div className="relative flex items-center rounded-xl bg-[#0a0a0a] p-1.5 ring-1 ring-gray-800">
                <input
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  placeholder="Ask me anything..."
                  className="flex-1 bg-transparent px-4 py-3 text-sm text-white placeholder-gray-500 focus:outline-none"
                  autoFocus
                />
                <button
                  type="submit"
                  disabled={isLoading || !input.trim()}
                  className="flex h-10 w-10 items-center justify-center rounded-lg bg-white text-black transition hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Send className="h-4 w-4" />
                </button>
              </div>
            </form>
            <div className="mt-3 flex justify-center gap-4 text-[10px] text-gray-600 font-mono">
              <span>MODEL: Llama-3-8B</span>
              <span>•</span>
              <span>LATENCY: 45ms</span>
              <span>•</span>
              <span>ARCHITECT: SHARATH</span>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
