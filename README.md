# 🏍️ WheelRide

**Ride together. Stay connected.**

WheelRide is a lightweight mobile app designed for motorcycle group rides.

Create a ride in seconds, invite riders with a QR code, track everyone in real time, and chat with the group while on the road.

No route planning.
No social network.
No complicated setup.

Just create a ride, join, and ride.

---

## Features

### Authentication

- Email & password sign up
- Login
- Password reset

### Ride Management

Create a ride:

- Ride name
- Optional description
- Unique QR code generation

Join a ride:

- Scan QR code
- Instant access to the ride

### Live Location Sharing

Each participant shares:

- Latitude
- Longitude
- Speed
- Heading

Updates are sent every few seconds while a ride is active.

Map view includes:

- All participants
- Rider names
- Live positions
- Your own location highlighted

### Group Chat

- Real-time text chat
- No message history
- No attachments
- No unnecessary complexity

### Participants List

- Rider name
- Online/offline status
- Ride leader indicator

---

## Architecture

### Mobile

Framework:

- Flutter

Platforms:

- iOS
- Android

### Backend

Powered by Supabase:

- Authentication
- PostgreSQL
- Realtime
- Storage

### Real-Time Communication

WheelRide uses WebSockets through Supabase Realtime.

Why not P2P?

- More complex networking
- NAT traversal issues
- Higher battery consumption
- Less reliable on mobile networks

A centralized realtime backend provides a much better user experience for this use case
