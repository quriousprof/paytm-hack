from functools import lru_cache
from sarvamai import SarvamAI
from app.core.config import get_sarvam_api_key


@lru_cache(maxsize=1)
def get_sarvam_client() -> SarvamAI:
    return SarvamAI(api_subscription_key=get_sarvam_api_key())
