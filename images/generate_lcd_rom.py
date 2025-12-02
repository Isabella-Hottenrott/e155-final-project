#!/usr/bin/env python3
"""
Generate .mem file for LCD messages using HD44780 character codes
Supports ASCII text and custom character definitions

The WH2002AE-1 uses a 36-bit wide memory (4 bytes per address)
9-bit addressing allows 512 locations
"""

def string_to_hex(text, max_width=20):
    """Convert ASCII string to hex codes for HD44780"""
    codes = []
    for char in text[:max_width]:
        codes.append(ord(char))
    return codes

def pack_bytes_to_36bit(bytes_list):
    """Pack up to 4 bytes into a 36-bit hex value"""
    # Pad with zeros if less than 4 bytes
    while len(bytes_list) < 4:
        bytes_list.append(0x00)
    
    # Combine 4 bytes into 36-bit value
    # Byte order: [byte3][byte2][byte1][byte0]
    value = (bytes_list[3] << 24) | (bytes_list[2] << 16) | (bytes_list[1] << 8) | bytes_list[0]
    return f"{value:09X}"

def create_mem_file(messages_dict, output_file="messages.mem"):
    """
    Create a .mem file from a dictionary of messages
    
    messages_dict format:
    {
        "msg_0": "Hello World",
        "msg_1": "Checkmate!",
        ...
    }
    """
    mem_lines = []
    mem_lines.append("// Auto-generated LCD memory initialization file")
    mem_lines.append("// Format: 36-bit hex (9 hex digits per line)")
    mem_lines.append("// Each line stores 4 ASCII characters")
    mem_lines.append("")
    
    address = 0
    
    for msg_name, text in messages_dict.items():
        mem_lines.append(f"// {msg_name}: \"{text}\"")
        
        # Split message into 4-character chunks
        for i in range(0, len(text), 4):
            chunk = text[i:i+4]
            char_codes = [ord(c) for c in chunk]
            hex_val = pack_bytes_to_36bit(char_codes)
            mem_lines.append(hex_val)
            address += 1
        
        mem_lines.append("")
    
    # Write to file
    with open(output_file, 'w') as f:
        f.write('\n'.join(mem_lines))
    
    print(f"Generated {output_file} with {address} addresses")

# ============================================================================
# EXAMPLE: Define your game messages here
# ============================================================================

game_messages = {
    "msg_0": "Rock",
    "msg_1": "Paper",
    "msg_2": "Scissors",
    "msg_3": "You Win!",
    "msg_4": "You Lose!",
    "msg_5": "Tie",
    "msg_6": "Starting...",
    "msg_7": "Next Level?",
    #"msg_8": "",
    #"msg_9": "Wait...",
    #"msg_10": "GameOver",
    #"msg_11": "Starting",
}

if __name__ == "__main__":
    output_path = "messages.mem"
    create_mem_file(game_messages, output_path)
    print(f"Successfully created {output_path}")
