# plagiarism/views.py
from difflib import SequenceMatcher

def check_plagiarism(code1, code2):
    similarity = SequenceMatcher(None, code1, code2).ratio()
    return similarity >= 0.8  # 80% similarity threshold