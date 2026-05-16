"""
decrypt_gvr.py

Decrypts a Base64-encoded AES-CBC encrypted file and writes the decrypted
contents to a text file.

This script derives a fixed 16-byte AES key and initialization vector (IV)
using the `gen_key()` and `gen_iv()` routines, then decrypts the input using
AES in CBC mode. The decrypted data is expected to use PKCS#7 padding, which
is removed before the plaintext is written to disk.

Requirements:
    pip install pycryptodome

Usage:
    python decrypt_gvr.py <input.enc> <output.txt>

Example:
    python decrypt_gvr.py nfscabinet_Content.enc output.txt

Arguments:
    input.enc
        Path to the encrypted input file. The file should contain Base64-
        encoded AES-CBC encrypted data.

    output.txt
        Path where the decrypted plaintext will be written.

Notes:
    - The decrypted text is decoded using latin-1 and written as UTF-8.
    - The AES key and IV are hardcoded/derived in this script, so this tool is
      intended for compatibility with a specific file format rather than for
      general-purpose secure encryption.
    - Do not use this key/IV generation approach for new encryption systems.
"""

import base64
from Crypto.Cipher import AES
import sys

def gen_key():
    array = [61, 221, 17, 85, 239, 86, 26, 52, 120, 171, 55, 147, 35, 124, 101, 214]
    b = 156
    for i in range(16):
        b ^= array[i]
        b &= 0xFF
        array[i] = b
    return bytes(array)

def gen_iv():
    array = [52, 69, 116, 204, 177, 79, 57, 146, 255, 239, 184, 172, 101, 16, 144, 169]
    b = 93
    for i in range(16):
        b ^= array[i]
        b &= 0xFF
        array[i] = b
    return bytes(array)

def decrypt_file(input_path, output_path):
    with open(input_path, 'r') as f:
        content = f.read().strip()
    
    encrypted_bytes = base64.b64decode(content)
    
    key = gen_key()
    iv = gen_iv()
    
    cipher = AES.new(key, AES.MODE_CBC, iv)
    decrypted = cipher.decrypt(encrypted_bytes)
    
    # Remove PKCS7 padding
    pad_len = decrypted[-1]
    decrypted = decrypted[:-pad_len]
    
    text = decrypted.decode('latin-1')
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(text)
    
    print(f"Decrypted successfully -> {output_path}")
    return text

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python decrypt_gvr.py <input.enc> <output.txt>")
        print("Example: python decrypt_gvr.py nfscabinet_Content.enc output.txt")
    else:
        decrypt_file(sys.argv[1], sys.argv[2])