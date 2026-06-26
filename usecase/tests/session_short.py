SESSIONS = [
    {
        "name": "Session A - basic mixed stress",
        "session_id": "session_a",
        "queries": [
            "What is the capital of France?",
            "Explain baroque architecture in simple terms for a beginner.",
            "Could you explain that again?",
            "Give me a concise answer: what is overfitting?",
        ],
        "expected_actions": [
            "act_respond",
            "act_think",
            "act_clarify",
            "act_respond",
        ],
    },
    {
        "name": "Session B - verify and search stress",
        "session_id": "session_b",
        "queries": [
            "Check whether this legal claim is accurate as of this week.",
            "Search for recent guidance on diagnosing unstable validation loss.",
            "Decompose this into a 6-step plan to compare two algorithms.",
            "Synthesize two contrasting viewpoints into one conclusion.",
        ],
        "expected_actions": [
            "act_verify",
            "act_search",
            "act_decompose",
            "act_synthesize",
        ],
    },
]
