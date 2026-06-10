# WheelRide

Ride together. Stay connected.

WheelRide is a lightweight Flutter app for motorcycle group rides: create a ride, invite riders with a QR code, share live locations, and chat in real time.

## MVP

- Email/password authentication and password reset through Supabase Auth.
- Create rides with name, optional description, unique join code, and QR invite.
- Join rides by QR scan or manual code.
- Live location sharing on an OpenStreetMap/MapTiler `flutter_map` view.
- Real-time text chat with no historical fetch.
- Participants list with online state and owner badge.

## Configuration

The app runs in local demo mode when Supabase credentials are not provided. To connect a backend:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_... \
  --dart-define=MAPTILER_KEY=optional_maptiler_key
```

Apply the database schema and RLS policies from:

```sh
supabase/migrations/20260610174600_init_wheelride.sql
```

## Project Structure

```txt
lib/
├── core/
│   ├── constants/
│   ├── routing/
│   ├── services/
│   └── theme/
├── features/
│   ├── auth/
│   └── rides/
└── shared/
    ├── models/
    ├── providers/
    └── widgets/
```
