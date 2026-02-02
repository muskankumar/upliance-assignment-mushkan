"""
Rock-Paper-Scissors Plus - Minimal code

"""

import json
import random
import re

# Game state
class State:
    def __init__(self):
        self.round = 0
        self.user_bomb_used = False
        self.bot_bomb_used = False
        self.user_wins = 0
        self.bot_wins = 0
        self.draws = 0

def get_judgment(user_input, state):
   
    
    user_input = user_input.lower().strip()
    
    
    valid_moves = ["rock", "paper", "scissors", "bomb"]
    
   
    unclear_patterns = [
        r'\?',  # questions
        r'\bmay\s*be\b',  # maybe
        r'\bprobably\b',  # probably
        r'\bor\b',  # or (indicates choice)
        r'\bthink\b',  # thinking
        r'\bshould\b',  # should I
        r'\bidk\b',  # idk
        r'^\.+$',  # just dots
        r'^\s*$',  # empty
    ]
    
    for pattern in unclear_patterns:
        if re.search(pattern, user_input):
            return {
                "intent": f"Player seems uncertain about their choice",
                "status": "UNCLEAR",
                "move": None,
                "reasoning": f"Input contains uncertainty markers like '{pattern}' - player hasn't committed to a move",
                "next_action": "TURN_WASTED"
            }
    
    
    found_move = None
    for move in valid_moves:
        if move in user_input:
            if found_move:
                # Multiple moves found
                return {
                    "intent": f"Player tried to use multiple moves",
                    "status": "INVALID",
                    "move": None,
                    "reasoning": "Can only choose one move per turn",
                    "next_action": "TURN_WASTED"
                }
            found_move = move
    
    
    if not found_move:
        # Check for common typos
        if "rok" in user_input or "roc" in user_input:
            found_move = "rock"
        elif "papper" in user_input or "papr" in user_input:
            found_move = "paper"
        elif "scissor" in user_input or "sissor" in user_input:
            found_move = "scissors"
        elif "bom" in user_input and "bomb" not in user_input:
            found_move = "bomb"
        else:
            return {
                "intent": "Unclear what move player wants",
                "status": "UNCLEAR",
                "move": None,
                "reasoning": "Couldn't identify a valid move (rock/paper/scissors/bomb) in the input",
                "next_action": "TURN_WASTED"
            }
    
    
    if found_move == "bomb" and state.user_bomb_used:
        return {
            "intent": "Player wants to use bomb again",
            "status": "INVALID",
            "move": None,
            "reasoning": f"Bomb was already used in round {find_bomb_round(state)} and can only be used once per game",
            "next_action": "TURN_WASTED"
        }
    
    
    return {
        "intent": f"Player wants to play {found_move}",
        "status": "VALID",
        "move": found_move,
        "reasoning": f"{found_move.capitalize()} is a valid move",
        "next_action": "PROCEED_TO_BATTLE"
    }

def find_bomb_round(state):
    
    
    return state.round // 2 + 1

def bot_move(state):
    
    if not state.bot_bomb_used and state.round > 0 and random.random() < 0.2:
        return "bomb"
    return random.choice(["rock", "paper", "scissors"])

def winner(p1, p2):
    
    if p1 == p2:
        return "draw"
    if p1 == "bomb" or p2 == "bomb":
        return "draw" if p1 == p2 else ("p1" if p1 == "bomb" else "p2")
    wins = {"rock": "scissors", "scissors": "paper", "paper": "rock"}
    return "p1" if wins[p1] == p2 else "p2"

def play_round(user_input, state):
    
    state.round += 1
    
    print(f"\n{'='*50}")
    print(f"ROUND {state.round}")
    print(f"{'='*50}")
    
    
    try:
        judgment = get_judgment(user_input, state)
    except Exception as e:
        print(f"Error: {e}")
        return
    
    print(f"Your input: \"{user_input}\"")
    print(f"Status: {judgment['status']}")
    print(f"Reasoning: {judgment['reasoning']}\n")
    
    
    if judgment['status'] != 'VALID':
        print("Turn wasted - Bot wins this round")
        state.bot_wins += 1
        return
    
    
    user_move = judgment['move']
    bot_choice = bot_move(state)
    
    if user_move == "bomb":
        state.user_bomb_used = True
    if bot_choice == "bomb":
        state.bot_bomb_used = True
    
    print(f"You: {user_move.upper()}")
    print(f"Bot: {bot_choice.upper()}")
    
    result = winner(user_move, bot_choice)
    
    if result == "p1":
        print("You win this round!")
        state.user_wins += 1
    elif result == "p2":
        print("Bot wins this round!")
        state.bot_wins += 1
    else:
        print("Draw!")
        state.draws += 1

def main():
    print("Rock-Paper-Scissors Plus")
    print("Moves: rock, paper, scissors, bomb (once only)")
    print("Type 'quit' to stop")
    
    state = State()
    
    while True:
        user_input = input(f"Round {state.round + 1} - Your move: ").strip()
        
        if user_input.lower() in ['quit', 'q', 'exit']:
            break
        if not user_input:
            continue
        
        play_round(user_input, state)
    
   
    if state.round > 0:
        print(f"\n{'='*50}")
        print(f"FINAL: You {state.user_wins} - {state.bot_wins} Bot ({state.draws} draws)")
        if state.user_wins > state.bot_wins:
            print("Yayy! You won!")
        elif state.bot_wins > state.user_wins:
            print(" Bot won!")
        else:
            print("Tie!")

if __name__ == "__main__":
    main()