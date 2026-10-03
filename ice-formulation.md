# ICE — Inventory Confidence Engine: Formulation

ICE infers inventory state purely from POS sales events — no manual stock counts required. Every metric flows from a single source of truth: the timestamped sale records emitted by the kirana POS.

---

## 1. Data Model

Each POS transaction produces one or more **sale events**:

```
SaleEvent {
  item_id   : string        // catalog product ID
  qty_sold  : float         // units sold in this transaction
  unit      : string        // kg, L, pkt, piece, …
  price     : float         // ₹ per unit at time of sale
  timestamp : ISO-8601 UTC
}
```

ICE aggregates these into a **daily demand series** per item:

```
D[item][day] = Σ qty_sold  for all events on that calendar day
```

All higher-level metrics derive from `D[item][day]`.

---

## 2. Velocity — V(t)

Velocity is the **exponentially weighted moving average (EWMA)** of daily demand. It gives more weight to recent days, making ICE responsive to short-term shifts without overreacting to single-day noise.

```
V(t) = α · D(t)  +  (1 − α) · V(t−1)

α = 0.30   (smoothing factor — tune higher for faster response)
```

**Seed rule:** `V(0) = D(0)` — velocity is bootstrapped from the first day of recorded sales for that item.

**Interpretation:** `V(t)` is the best single-number answer to *"how many units do we sell per day?"* as of day `t`.

---

## 3. Trend — τ

Trend measures the **relative acceleration** of demand by comparing two EWMA windows: a short (recent) window vs. a longer (baseline) window.

```
V_recent   = EWMA(D, α=0.50) over last  4 days   // reacts fast
V_baseline = EWMA(D, α=0.15) over last 14 days   // slower baseline

τ = (V_recent − V_baseline) / V_baseline  × 100%
```

| τ value | Meaning |
|---------|---------|
| `+42%`  | Demand spiked ~42% above the 2-week baseline |
| `−5%`   | Demand slightly lower than recent average |
| `0%`    | Stable |

**Example — Onions during festival week:**
- V_baseline = 2.2 kg/day (past 14 days)
- V_recent   = 3.1 kg/day (last 4 days)
- τ = (3.1 − 2.2) / 2.2 × 100 = **+40.9%**

---

## 4. Adjusted Velocity — V_adj

Before computing any forward projections, velocity is adjusted by the current trend so that allocations respond to demand acceleration, not just historical averages:

```
V_adj(t) = V(t) · (1 + τ / 100)
```

All downstream formulae (days-to-stockout, 7-day allocation) use `V_adj`.

---

## 5. Stock Estimation — S_est

ICE does not require the merchant to enter stock counts. Instead it maintains a **running stock estimate** anchored to the last known quantity and depleted by sales:

```
S_est(t) = S_anchor  −  Σ D[day]  (for all days after anchor)
                     +  Σ reorder_qty  (for all reorders after anchor)
```

### Anchor events (any of these resets S_anchor)
| Trigger | Source |
|---------|--------|
| Merchant performs a **manual count** | App input |
| Merchant logs a **supplier delivery** | Delivery note input |
| System detects a **stockout** (sales stop suddenly after high velocity) | Inferred |
| First-time item setup | Merchant sets opening stock once |

### Stockout inference
If `D(t) = 0` for 2 consecutive days while `V_adj(t−1) > 0.5`, ICE flags a **probable stockout** and sets `S_est = 0` unless the merchant overrides.

### Stock percentage
```
S_pct = S_est / S_capacity   (clamped to [0, 1])
```

`S_capacity` is the merchant's typical max stock — set once per item and rarely changes.

---

## 6. Days to Stockout — D_out

```
D_out = S_est / V_adj        (if V_adj > 0, else ∞)
```

This is the forward-looking estimate of how many days of stock remain at the current adjusted demand rate.

---

## 7. Status Classification

Each item is classified into one of three tiers based on `D_out` and `S_pct`:

```
if   D_out < 1.0  OR  S_pct < 0.15  →  CRITICAL
elif D_out < 3.0  OR  S_pct < 0.30  →  LOW
else                                 →  HEALTHY
```

The OR condition means an item with 25% stock but fast velocity (D_out < 1) is still CRITICAL — stock percentage alone is not sufficient.

---

## 8. Confidence Score — C

Confidence quantifies how **reliable** ICE's estimate is for a given item. An item sold every day by the hundreds has a high-confidence velocity; an item sold once a week has low confidence.

```
C = w1 · R  +  w2 · F  +  w3 · K

weights:  w1=0.40, w2=0.35, w3=0.25
```

### Components

| Symbol | Name | Formula |
|--------|------|---------|
| **R** | Recency | `exp(−days_since_last_sale / 7)` — decays if item hasn't sold recently |
| **F** | Frequency | `min(1,  sales_events_last_7d / 7)` — penalises items sold < once/day |
| **K** | Consistency | `1 − (σ_daily / V)` — coefficient of variation; 0 = erratic, 1 = perfectly steady |

`σ_daily` is the standard deviation of `D[day]` over the last 14 days.

**Output range:** 0–100%. Values below 60% should show a warning UI; ICE still surfaces a prediction but flags it as low-confidence.

---

## 9. 7-Day Allocation — A₇

The allocation is the quantity the merchant should order **today** to satisfy the next 7 days of adjusted demand, after accounting for current stock:

```
A₇_raw = max(0,  V_adj · 7  −  S_est)
```

A safety buffer is added based on status tier (buffers absorb variance and unexpected spikes):

```
buffer = 0.15   if HEALTHY
buffer = 0.25   if LOW
buffer = 0.40   if CRITICAL

A₇ = A₇_raw · (1 + buffer)
```

Items with `A₇ = 0` (adequate stock) are omitted from the Suggested Reorder list.

---

## 10. Inventory Health Score — H

The overall health of the inventory at a point in time:

```
H = (count_HEALTHY / count_total) × 100   (rounded to nearest integer)
```

This is the headline percentage shown in the ICE dashboard header ring.

---

## 11. Full Data Pipeline

```
POS Sale Events
      │
      ▼
┌─────────────────────────────────────────────┐
│  Daily Aggregator                           │
│  D[item][day] = Σ qty_sold per day          │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  EWMA Engine                                │
│  V(t)        — smoothed velocity (α=0.30)  │
│  V_recent    — fast EWMA (α=0.50, 4d)      │
│  V_baseline  — slow EWMA (α=0.15, 14d)     │
│  τ           — trend %                     │
│  V_adj       — trend-adjusted velocity     │
│  σ_daily     — daily demand std dev        │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  Stock Estimator                            │
│  S_est  = S_anchor − Σ sales + Σ reorders  │
│  S_pct  = S_est / S_capacity               │
│  D_out  = S_est / V_adj                    │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  Confidence Engine                          │
│  C = 0.40·R + 0.35·F + 0.25·K             │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  Classifier & Allocator                     │
│  status  — CRITICAL / LOW / HEALTHY        │
│  A₇      — 7-day allocation with buffer    │
│  H       — inventory health score          │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
               ICE Screen (Flutter)
       ┌──────────────────────────────┐
       │ Header: H%, ring, status chips│
       │ AI Insights (top anomalies)  │
       │ Calculated Allocations       │
       │ Item cards: S_est, S_pct, C  │
       │ Reorder summary: Σ A₇        │
       └──────────────────────────────┘
```

---

## 12. AI Insights Generation

Insights are generated by scanning items for notable signal patterns:

| Pattern | Threshold | Example insight |
|---------|-----------|-----------------|
| Demand spike | `τ > 30%` AND status CRITICAL | "Onions selling 42% faster — festival demand detected" |
| Imminent stockout | `D_out < 1.0` | "Milk runs out in ~18 hrs" |
| Stable high-mover | `V > 2.0` AND status HEALTHY | "Rice demand stable at 2.1 kg/day" |
| Cross-item correlation | Items bought together > 60% of transactions | "Tomatoes + Onions + Potatoes co-purchased 68% of the time" |

In production these would be generated by a server-side job querying the sales database. In the current prototype they are seeded from the modelled mock data.

---

## 13. Parameters Summary

| Parameter | Symbol | Default | Effect of increasing |
|-----------|--------|---------|----------------------|
| EWMA smoothing | α | 0.30 | Faster velocity response, more noise |
| Recent trend window | α_r | 0.50 | More reactive trend |
| Baseline trend window | α_b | 0.15 | Slower baseline drift |
| Critical threshold (days) | — | 1.0 d | More items flagged critical |
| Low threshold (days) | — | 3.0 d | More items flagged low |
| Critical stock % | — | 15% | — |
| Low stock % | — | 30% | — |
| Safety buffer (CRITICAL) | — | 40% | Larger reorder suggestions |
| Safety buffer (LOW) | — | 25% | — |
| Safety buffer (HEALTHY) | — | 15% | — |
| Confidence weights | w1/w2/w3 | 0.40/0.35/0.25 | Shifts C sensitivity |

---

## 14. Future Extensions

- **Seasonal decomposition:** Additive STL decomposition to separate weekly seasonality from the trend signal, preventing false CRITICAL flags every Monday when certain items always sell less.
- **Supplier lead-time aware reorder point:** `A₇` becomes `A_lead = V_adj × lead_days`, triggered when `D_out ≤ lead_days + 1`.
- **Price elasticity feedback:** If a price change correlates with a velocity shift, ICE should attribute the trend to price, not demand growth.
- **Cross-item demand coupling:** Learn the co-purchase matrix from transaction data and proactively raise confidence for correlated items.
- **Supplier API integration:** Auto-dispatch the reorder payload via Paytm's supplier network when the merchant approves the ICE suggestion.
