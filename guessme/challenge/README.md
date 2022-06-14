This challenge is based on ambiguous Base64.

Basically, it challenges them to guess a word. If they get it wrong, it tells
them what the word is. If they get it right, they get the flag.

Once guessed, it's added to a list of used words. But it's added by the
base64, which is ambiguous. I prevent the obvious things (like adding
whitespace), but sometimes due to padding a base64 string is totally ambiguous.

The solution averages probably 5 or so guesses.
