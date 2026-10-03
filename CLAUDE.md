# Paytm Hackathon - Digital Kirana Storefront

## Project Overview
A mini app built on top of Paytm POS that serves as a digital storefront for kirana (local grocery) stores. The app allows kirana store owners to create and manage a digital catalog accessible to customers via the Paytm ecosystem.

## Architecture
- **pos_frontend/** — Flutter app that mocks the Paytm Android app and hosts the mini app (digital storefront) within it
- **backend/** — Backend service for the storefront

## Key Concepts
- The `pos_frontend` is a **mock of the Paytm Android app** — it simulates the Paytm interface and launches our mini app (the kirana storefront) from within it
- The digital storefront mini app is served as a "Mini App" inside this Paytm mock
