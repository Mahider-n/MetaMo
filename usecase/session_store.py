import json
import os
from datetime import datetime

# Define directories for storing session data and logs.
SESSIONS_DIR = os.path.join(os.path.dirname(__file__), "sessions")
LOGS_DIR = os.path.join(os.path.dirname(__file__), "logs")


def _path(session_id: str) -> str:
    """
    Generates the full file path for a given session ID within the sessions directory.
    Ensures the sessions directory exists.
    """
    os.makedirs(SESSIONS_DIR, exist_ok=True)
    return os.path.join(SESSIONS_DIR, session_id + ".json")


def has_session(session_id: str) -> bool:
    """
    Checks if a session file corresponding to the provided session ID already exists on disk.
    """
    return os.path.exists(_path(session_id))


def load_test_session(name: str) -> list:
    """
    Loads a predefined test session's queries from a specific test file,
    identified by its name. This is typically used for development or testing.
    """
    import importlib.util

    here = os.path.dirname(__file__)
    test_file = os.path.join(here, "tests", "session_short.py")
    
    # Dynamically import the Python module containing test session definitions.
    spec = importlib.util.spec_from_file_location("session_short", test_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Iterate through available test sessions to find the one that matches 'name'.
    for session in module.SESSIONS:
        if session["name"] == name:
            return session["queries"]
    return [] # Return an empty list if no matching session is found.


def load_goals(session_id: str) -> dict:
    """
    Loads the 'goals' dictionary for a given session from its corresponding JSON file.
    """
    with open(_path(session_id), "r", encoding="utf-8") as f:
        return json.load(f)["goals"]


def load_mods(session_id: str) -> dict:
    """
    Loads the 'mods' (modifiers) dictionary for a given session from its corresponding JSON file.
    """
    with open(_path(session_id), "r", encoding="utf-8") as f:
        return json.load(f)["mods"]


def load_anti_goals(session_id: str) -> dict:
    """
    Loads the 'anti_goals' dictionary for a given session from its corresponding JSON file.
    """
    with open(_path(session_id), "r", encoding="utf-8") as f:
        return json.load(f)["anti_goals"]


def save_session(session_id: str, goals: dict, mods: dict, anti_goals: dict) -> bool:
    """
    Saves the current state of a conversation session, including goals,
    modifiers, and anti-goals, into a JSON file associated with the session ID.
    """
    data = {"goals": goals, "mods": mods, "anti_goals": anti_goals}
    with open(_path(session_id), "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2) # Writes data with a 2-space indentation for readability.
    return True


def log_turn(session_id: str, query: str, action: str, answer: str) -> bool:
    """
    Appends a new conversation turn (user query, system action, system answer)
    to the log file specific to the given session ID.
    Includes a timestamp for each turn.
    """
    os.makedirs(LOGS_DIR, exist_ok=True)
    log_path = os.path.join(LOGS_DIR, session_id + ".json")

    # Load existing turns from the log file, or initialize an empty list if the file doesn't exist.
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as f:
            turns = json.load(f)
    else:
        turns = []

    # Add the current turn's details, including the precise timestamp.
    turns.append({
        "timestamp": datetime.now().isoformat(timespec="seconds"), # Generates a string like "YYYY-MM-DDTHH:MM:SS"
        "query": query,
        "action": action,
        "answer": answer,
    })

    # Write the updated list of turns back to the log file.
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(turns, f, indent=2)
    return True
