from pydantic import BaseModel


class CartItem(BaseModel):
    name: str   # English product name, e.g. "onions"
    qty: float  # numeric quantity
    unit: str   # e.g. "kg", "g", "packet", "piece"


class VoiceCartResponse(BaseModel):
    transcript: str          # raw STT transcript
    items: list[CartItem]    # parsed cart items
