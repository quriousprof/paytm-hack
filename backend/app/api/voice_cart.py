from fastapi import APIRouter, File, UploadFile
from app.services.cart_parser import parse_voice_cart
from app.schemas.cart import VoiceCartResponse

router = APIRouter(prefix="/voice-cart", tags=["voice-cart"])


@router.post("", response_model=VoiceCartResponse)
async def voice_cart(audio: UploadFile = File(...)):
    """
    Accept a WAV/MP3 audio file of a spoken cart command.

    Example input (spoken):  "ek kilo pyaaz aur do kilo tamatar"
    Example response:
    {
      "transcript": "एक किलो प्याज और दो किलो टमाटर",
      "items": [
        {"name": "onions",   "qty": 1, "unit": "kg"},
        {"name": "tomatoes", "qty": 2, "unit": "kg"}
      ]
    }
    """
    audio_bytes = await audio.read()
    transcript, items = parse_voice_cart(audio_bytes, audio.filename or "audio.wav")
    return VoiceCartResponse(transcript=transcript, items=items)
