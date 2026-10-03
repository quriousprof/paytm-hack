import os
from dotenv import load_dotenv

load_dotenv()


def get_sarvam_api_key() -> str:
    key = os.getenv("SARVAM_API_KEY")
    if not key:
        raise RuntimeError("SARVAM_API_KEY is not set in environment")
    return key
