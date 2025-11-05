# Function based approach

print("="*60)
print("Function Based state machine design")
print("="*60)

def get_next_state(current_state, input_bit):
    """ The I/P to this function is present state and the bit(I/P)"""
    
    if current_state == "S0":
        if input_bit == 1:
            return "S1"
        else:
            return "S0"
            
    elif current_state == "S1":
        if input_bit == 1:
            return "S2"
        else:
            return "S0"  # sequence pattern is difft. so restart.
    
    elif current_state == "S2":
        if input_bit == 0:
            return "S3"
        else:
            return "S2"
    
    elif current_state == "S3":
        if input_bit == 1:
            return "S4"
        else:
            return "S0"
            
    elif current_state == "S4":
        if input_bit == 1:
            return "S1"
        else:
            return "S0"
            
#verification for the same 

state = "S0"
sequence = [ 1,1,0,1]

print(f"Processing sequence: {sequence}\n")
for bit in sequence:
    old_state = state
    state = get_next_state(state,bit)
    detected = "***DETECTED***" if state == "S4" else ""
    print(f"{old_state}-- ({bit})---> {state} {detected}")
    
print("\n")
