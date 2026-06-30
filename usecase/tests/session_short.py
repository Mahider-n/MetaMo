SESSIONS = [
    {
        "name": "Session A - 10 turn mixed stress",
        "session_id": "session_a",
        "queries": [
            "What is the capital of France?",
            "Quickly tell me the capital of France!",
            "Can you help me with it?",
            "Explain baroque architecture in simple terms for a beginner.",
        ],
        "expected_actions": [
            "act_respond",
            "act_respond",
            "act_clarify",
            "act_respond",
        ],
        "acceptable_actions": [
            [],
            [],
            [],
            ["act_think"],
        ],
    },
    {
        "name": "Session B - modulators stress",
        "session_id": "session_b",
        "queries": [
            "What is the capital of Japan?",
            "Please quickly tell me the answer.",
            "Can you help me with this?",
            "For a medical recommendation, can I definitely take this dosage without side effects?",
        ],
        "expected_actions": [
            "act_respond",
            "act_clarify",
            "act_clarify",
            "act_verify",
        ],
        "acceptable_actions": [
            [],
            [],
            [],
            [],
        ],
    },
]


def get_session_queries(session_id: str) -> str:
    for session in SESSIONS:
        if session["session_id"] == session_id:
            queries = " ".join(
                [f'"{q}"' for q in session["queries"]]
            )
            return f"({queries})"
    return "(queries)" 