# Manual tracking program

print("=" *60)
print("Simple variable tracking")
print("="*60)

#step1: initialize the first state.
state = "S0"
print(f"Statrting state :{state}\n")

#step2 : when "1" is dtected
bit = 1
if state == "S0" and bit ==1:
    state = "S1"
print(f"After bit {bit}:state = {state}")

bit = 1
if state == "S1"and bit == 1:
    state = "S2"
print(f"After bit {bit}: state = {state}")

bit = 0
if state == "S2" and bit == 0:
    state = "S3"
print(f"After bit {bit}: state = {state}")

bit = 1
if state == "S3" and bit == 1:
    state = "S4"
print(f"After bit {bit}: state = {state}")

if(state == "S4"):
    print(f"sequence 1101 detected")
