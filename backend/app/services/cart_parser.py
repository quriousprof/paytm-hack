"""
Two-step pipeline:
  1. Sarvam STT  (saaras:v2)  → raw transcript
  2. Sarvam LLM (sarvam-m)   → structured CartItem list
"""

import json
import tempfile
import os
from fastapi import HTTPException

from app.services.sarvam_client import get_sarvam_client
from app.schemas.cart import CartItem

_SYSTEM_PROMPT = """You are a kirana store assistant.
The user speaks in Hindi, Hinglish, Marathi, or English.
Extract every item they want to add to their cart.

Hindi/Marathi→English name mappings (non-exhaustive):
pyaaz/kanda→onions, tamatar/tomato→tomatoes, aloo/batata→potatoes,
doodh→milk, anda/ande/ande→eggs, chawal/tandul→rice, dal→lentils,
gehun/atta/peeth→wheat flour, maida→flour, chini/saakhar→sugar,
namak/meeth→salt, tel→oil, ghee→ghee, dahi→yogurt,
mirchi→chili, adrak/aale→ginger, lahsun/lasun→garlic,
sarso/mohri→mustard, jeera/jire→cumin, haldi→turmeric,
sabun→soap, chai→tea, coffee→coffee, bread→bread,
banana/kela→bananas, seb/apple→apples, santara/orange→oranges.

Quantity words (Hindi & Marathi):
ek→1, do/don→2, teen/tin→3, char→4, paanch/panch→5,
chhe/saha→6, saat/sat→7, aath→8, nau/nav→9, das/daha→10,
aadha/ardha/half→0.5, sau/shambhar→100, hazaar/hazar→1000.

Unit normalisation:
kilo/kg/kilogram→kg, gram/g/gm→g,
litre/liter/l→l, ml→ml,
packet/pack/pkt→packet, piece/pcs/piec/number→piece,
dozen/darjan→dozen.

Return ONLY valid JSON, no extra text."""

_RESPONSE_SCHEMA = {
    "type": "json_schema",
    "json_schema": {
        "name": "CartItems",
        "schema": {
            "type": "object",
            "properties": {
                "items": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "name": {"type": "string"},
                            "qty":  {"type": "number"},
                            "unit": {"type": "string"},
                        },
                        "required": ["name", "qty", "unit"],
                    },
                }
            },
            "required": ["items"],
        },
    },
}


def _transcribe(audio_bytes: bytes, filename: str) -> str:
    """Send audio bytes to Sarvam STT and return the transcript."""
    client = get_sarvam_client()
    suffix = os.path.splitext(filename)[1] or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp_path = tmp.name

    print(f"[STT] Sending {len(audio_bytes)} bytes to Sarvam STT...")
    try:
        with open(tmp_path, "rb") as f:
            response = client.speech_to_text.transcribe(
                file=f,
                model="saaras:v2",
                mode="transcribe",
            )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"STT error: {exc}") from exc
    finally:
        os.unlink(tmp_path)

    transcript = response.transcript
    if not transcript or not transcript.strip():
        raise HTTPException(status_code=422, detail="STT returned an empty transcript")

    print(f"[STT] Transcript: {transcript!r}")
    return transcript


def _extract_items(transcript: str) -> list[CartItem]:
    """Send the transcript to Sarvam LLM and return parsed CartItems."""
    client = get_sarvam_client()
    print(f"[LLM] Parsing cart items from: {transcript!r}")
    try:
        response = client.chat.completions(
            model="sarvam-m",
            messages=[
                {"role": "system", "content": _SYSTEM_PROMPT},
                {"role": "user", "content": f'Cart command: "{transcript}"'},
            ],
            response_format=_RESPONSE_SCHEMA,
        )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"LLM error: {exc}") from exc

    raw = response.choices[0].message.content
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise HTTPException(
            status_code=502, detail=f"LLM returned invalid JSON: {raw}"
        ) from exc

    items = [CartItem(**item) for item in data.get("items", [])]
    print(f"[LLM] Parsed {len(items)} item(s):")
    for item in items:
        print(f"      → {item.name}  qty={item.qty}  unit={item.unit}")
    return items


def parse_voice_cart(audio_bytes: bytes, filename: str) -> tuple[str, list[CartItem]]:
    """Full pipeline: audio → transcript → cart items."""
    print(f"[VOICE-CART] Starting pipeline for {filename!r}")
    transcript = _transcribe(audio_bytes, filename)
    items = _extract_items(transcript)
    print(f"[VOICE-CART] Done — transcript={transcript!r}, items={len(items)}")
    return transcript, items
