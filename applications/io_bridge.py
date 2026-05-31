def read_user_input(prompt: str) -> str:
    """Reads input from stdin."""
    try:
        return input(prompt)
    except EOFError:
        return "quit"
    except Exception as e:
        print(f"Error reading input: {e}")
        return "quit"

def print_output(*args) -> bool:
    """Prints text to stdout."""
    print(*(str(a) for a in args), sep="")
    return True
