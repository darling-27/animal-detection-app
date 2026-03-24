# Wildlife Monitoring Application - UI/UX Specification Document

## Project Overview

This document provides comprehensive UI/UX specifications for two applications in the Wild Guardian wildlife monitoring system:

1. **Forest Officer Dashboard** - Professional control panel for wildlife monitoring
2. **Civilian Safety Alert App** - Public safety application for communities near forest areas

---

# Part 1: Forest Officer Dashboard

## 1.1 Theme & Visual Identity

### Color Palette

| Purpose | Color Name | Hex Code | Usage |
|---------|-----------|----------|-------|
| Background Primary | Deep Forest | `#0A1F0A` | Main screen backgrounds |
| Background Secondary | Dark Moss | `#132413` | Card backgrounds |
| Background Tertiary | Night Green | `#1A3320` | Elevated surfaces |
| Primary Accent | Emerald Glow | `#00E676` | Primary actions, active states |
| Secondary Accent | Forest Teal | `#26A69A` | Secondary elements |
| Danger/Alert High | Warning Red | `#FF1744` | Dangerous animal alerts |
| Caution/Alert Medium | Caution Amber | `#FFC107` | Suspicious movement |
| Safe/Normal | Safe Green | `#00E676` | Normal wildlife |
| Text Primary | Pure White | `#FFFFFF` | Headlines, important text |
| Text Secondary | Mist Gray | `#B0BEC5` | Body text, descriptions |
| Text Muted | Fog Gray | `#607D8B` | Timestamps, metadata |
| Glass Effect | Frosted | `#FFFFFF15` | Glassmorphism overlays |
| Border Glow | Neon Green | `#00FF8840` | Glow effects |

### Typography

| Element | Font Family | Size | Weight | Letter Spacing |
|---------|------------|------|--------|-----------------|
| App Title | Orbitron | 28sp | Bold | 4.0 |
| Screen Headers | Inter | 24sp | Bold | 1.5 |
| Section Headers | Inter | 18sp | SemiBold | 0.5 |
| Card Titles | Inter | 16sp | SemiBold | 0.25 |
| Body Text | Inter | 14sp | Regular | 0.25 |
| Metadata/Labels | Inter | 12sp | Medium | 0.5 |
| Timestamps | JetBrains Mono | 11sp | Regular | 0.5 |
| Alert Badges | Inter | 10sp | Bold | 1.0 |

### Spacing System (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing, icon padding |
| sm | 8px | Between related elements |
| md | 16px | Standard padding |
| lg | 24px | Section spacing |
| xl | 32px | Major section breaks |
| xxl | 48px | Screen margins |

---

## 1.2 Layout Structure

### Dashboard Screen Layout

```
┌─────────────────────────────────────────────┐
│  TOP HEADER (64px height)                   │
│  [Logo] [Title]              [User Avatar]  │
├─────────────────────────────────────────────┤
│  ALERT BANNER (variable height, animated)  │
│  ⚠ DANGER: Wild Boar detected - Zone B     │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐ ┌─────────────────┐  │
│  │  LIVE FEED CARD │ │ STATISTICS CARD  │  │
│  │  (Real-time     │ │ (Detections,     │  │
│  │   detections)   │ │  Alerts, Zones)  │  │
│  └─────────────────┘ └─────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  ACTIVITY CHART (Line/Bar graph)     │  │
│  │  Wildlife movement patterns          │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  FILTER BAR                           │  │
│  │  [All] [Dangerous] [Caution] [Safe]  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  DETECTION CARDS (Scrollable List)    │  │
│  │  ┌─────┐ Animal - Time - Location     │  │
│  │  │Img  │ Confidence - Status          │  │
│  │  └─────┘                               │  │
│  └──────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│  BOTTOM NAVIGATION (80px)                   │
│  [Dashboard] [Alerts] [Map] [History]       │
└─────────────────────────────────────────────┘
```

### Map Screen Layout

```
┌─────────────────────────────────────────────┐
│  HEADER: Detection Map           [Filters] │
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│           FULL-SCREEN MAP                   │
│           (Google Maps with                 │
│            dark theme styling)              │
│                                             │
│    📍 User Location (Blue)                  │
│    🔴 Danger Marker (Red)                   │
│    🟡 Caution Marker (Yellow)               │
│    🟢 Safe Marker (Green)                   │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│  ZONE INFO PANEL (Collapsible bottom sheet) │
│  Zone A - 3 detections - Active            │
└─────────────────────────────────────────────┘
```

---

## 1.3 Glassmorphism Card Design

### Card Specifications

```
┌─────────────────────────────────────┐
│  ╭─────────────────────────────────╮ │
│  │      GLASSMORPHISM LAYER        │ │
│  │  Background: #FFFFFF10          │ │
│  │  Border: 1px #FFFFFF20          │ │
│  │  Blur: 10px                     │ │
│  │  Border Radius: 16px            │ │
│  ╰─────────────────────────────────╯ │
│                                     │
│  [Icon]  Card Title                 │
│          Description text here      │
│          with more details...       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │    Inner Content Area       │   │
│  │    (Charts, Lists, etc)      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ← Subtle glow on hover/press →    │
│     Box Shadow: #00FF8830           │
└─────────────────────────────────────┘
```

### Card Variations

| Card Type | Border Color | Glow Color | Icon |
|-----------|-------------|------------|------|
| Danger | `#FF174440` | `#FF1744` | `warning_amber` |
| Caution | `#FFC10740` | `#FFC107` | `error_outline` |
| Safe | `#00E67640` | `#00E676` | `check_circle` |
| Info | `#26A69A40` | `#26A69A` | `info` |
| Neutral | `#FFFFFF20` | None | `pets` |

---

## 1.4 UI Components Specification

### 1.4.1 Top Header Component

```
┌──────────────────────────────────────────────────────┐
│ [Forest Icon]  Wild Guardian     [Avatar] [Notif]   │
│                 Forest Officer                       │
└──────────────────────────────────────────────────────┘
```

- **Height**: 64px
- **Background**: Gradient from `#0A1F0A` to transparent
- **Logo**: 32x32px with glow effect
- **Title Font**: Orbitron 20sp Bold
- **Subtitle**: Inter 12sp, color `#B0BEC5`
- **Notification Badge**: Red circle with count

### 1.4.2 Real-Time Alert Banner

```
┌─────────────────────────────────────────────────────┐
│ ⚠ RED ALERT: Tiger detected in Zone C            │
│    📍 2.3km away | High Confidence (94%) | 2m ago  │
└─────────────────────────────────────────────────────┘
```

- **Animation**: Pulse effect (scale 1.0 → 1.02 → 1.0, 2s loop)
- **Background**: Gradient based on severity
  - Danger: `#FF1744` → `#FF174420`
  - Caution: `#FFC107` → `#FFC10720`
- **Icon**: Animated radar sweep
- **Swipe**: Right to acknowledge, Left to dismiss

### 1.4.3 Detection Card Component

```
┌────────────────────────────────────────────────────────┐
│ ┌────────┐  Tiger Detected                    [DANGER]│
│ │        │  📸 Camera Trap #12                            │
│ │ Animal │  ──────────────────────────────────          │
│ │ Image  │  ⏱ 2 minutes ago                              │
│ │        │  📍 Zone C - North Sector                      │
│ │ 120x80 │  23.5432°N, 87.2341°E                         │
│ └────────┘  ──────────────────────────────────          │
│            🎯 Confidence: 94%   [View] [Resolve]         │
└────────────────────────────────────────────────────────┘
```

- **Dimensions**: Full width, ~160px height
- **Image**: Rounded corners 8px, placeholder icon if null
- **Confidence Bar**: Gradient progress bar (green → yellow → red)
- **Action Buttons**: Ghost buttons with icon + text
- **States**:
  - Default: Standard glass effect
  - Pressed: Scale 0.98, increased glow
  - Resolved: Reduced opacity (0.6), checkmark overlay

### 1.4.4 Statistics Card Component

```
┌─────────────────────────────────────────────┐
│  📊 TODAY'S ACTIVITY                        │
│                                             │
│  ┌────────┐  ┌────────┐  ┌────────┐        │
│  │   24   │  │   3    │  │   1    │        │
│  │Detectns│  │Alerts  │  │Danger  │        │
│  └────────┘  └────────┘  └────────┘        │
│                                             │
│  ████████░░ 78% Safety Score                │
└─────────────────────────────────────────────┘
```

- **Layout**: 3-column grid for stats
- **Numbers**: Orbitron 28sp Bold
- **Labels**: Inter 12sp, `#B0BEC5`
- **Progress Bar**: Rounded, animated fill

### 1.4.5 Activity Chart Component

```
┌─────────────────────────────────────────────────────┐
│  WILDLIFE ACTIVITY (Last 7 Days)                   │
│                                                     │
│  20 |    █                                          │
│  15 |    █  █                                       │
│  10 | █  █  █  █         █                          │
│   5 | █  █  █  █  █  █  █  █                       │
│   0 +──────�──────�──────────────                     │
│      Mon  Tue  Wed  Thu  Fri  Sat  Sun             │
│                                                     │
│  ▓ Danger  ░ Caution  ▒ Normal                     │
└─────────────────────────────────────────────────────┘
```

- **Type**: Grouped bar chart
- **Colors**: Danger (red), Caution (yellow), Normal (green)
- **Animation**: Bars grow from bottom on load (500ms staggered)
- **Interaction**: Tap bar to see details

### 1.4.6 Filter Bar Component

```
┌─────────────────────────────────────────────────────┐
│  [All]  [🐯 Dangerous]  [⚠ Caution]  [✓ Normal]   │
│        [Deer] [Boar] [Tiger] [Fox] [Bird]         │
└─────────────────────────────────────────────────────┘
```

- **Chip Style**: Rounded pill buttons
- **Selected State**: Filled with accent color
- **Multi-select**: Yes, for animal types

---

## 1.5 Animations & Micro-interactions

### Animation Specifications

| Element | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Card Appear | Fade + Slide Up | 300ms | easeOutCubic |
| Card Press | Scale (0.98) | 100ms | easeInOut |
| Alert Pulse | Scale (1.0 → 1.02) | 2000ms | easeInOut (loop) |
| Chart Bars | Grow from bottom | 800ms | easeOutCubic |
| Navigation | Fade crossfade | 200ms | easeInOut |
| Button Press | Ripple + Scale | 150ms | easeOut |
| Alert Slide | Slide from top | 400ms | easeOutBack |
| Map Markers | Drop in | 300ms | bounceOut |
| Glow Pulse | Opacity 0.3 → 0.6 | 1500ms | easeInOut (loop) |

### Glow Effects

```dart
// Card glow on hover/focus
BoxShadow(
  color: Color(0xFF00FF88).withValues(alpha: 0.3),
  blurRadius: 20,
  spreadRadius: 2,
)

// Alert danger glow
BoxShadow(
  color: Color(0xFFFF1744).withValues(alpha: 0.5),
  blurRadius: 30,
  spreadRadius: 5,
)
```

---

## 1.6 Data Models

### Detection Model

```dart
class Detection {
  String id;
  String animalType;        // "Tiger", "Wild Boar", "Deer", etc.
  String animalImageUrl;    // URL from camera trap
  double confidence;        // 0.0 - 1.0
  DateTime timestamp;
  double latitude;
  double longitude;
  String zoneId;
  String zoneName;
  AlertSeverity severity;   // dangerous, caution, normal
  DetectionStatus status;   // active, resolved, dismissed
  String? notes;
}

enum AlertSeverity { dangerous, caution, normal }
enum DetectionStatus { active, resolved, dismissed }
```

### Zone Model

```dart
class Zone {
  String id;
  String name;
  String sector;             // "North", "South", etc.
  LatLng position;
  int activeSensors;
  int detectionCount;
  ZoneStatus status;        // active, warning, offline
  List<String> recentAlerts;
}
```

---

# Part 2: Civilian Safety Alert Application

## 2.1 Theme & Visual Identity

### Color Palette

| Purpose | Color Name | Hex Code | Usage |
|---------|-----------|----------|-------|
| Background | Forest Night | `#0D1B0D` | Main backgrounds |
| Surface | Deep Green | `#142414` | Cards, panels |
| Primary | Safety Green | `#00C853` | Safe indicators |
| Warning | Alert Orange | `#FF6D00` | Possible movement |
| Danger | Emergency Red | `#D50000` | Dangerous animal |
| Text Primary | White | `#FFFFFF` | Main text |
| Text Secondary | Light Gray | `#E0E0E0` | Descriptions |

### Typography (Large & Readable)

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Alert Title | Roboto | 28sp | Bold |
| Warning Message | Roboto | 22sp | SemiBold |
| Distance Display | Roboto Mono | 48sp | Bold |
| Body Text | Roboto | 18sp | Regular |
| Button Text | Roboto | 18sp | Bold |
| Safety Tips | Roboto | 16sp | Regular |

---

## 2.2 Layout Structure

### Home Screen Layout

```
┌─────────────────────────────────────────────┐
│  ALERT BANNER (Emergency if active)        │
│  ⚠ ANIMAL ALERT                            │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │      YOUR SAFETY STATUS             │    │
│  │           🟢 SAFE                   │    │
│  │    Last alert: 2 hours ago         │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │     NEARBY DETECTION MAP            │    │
│  │     (Your location + alerts)        │    │
│  │        📍 You are here              │    │
│  │        🔴 Animal detected           │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  IF ALERT ACTIVE:                   │    │
│  │  ┌─────┐ WARNING: Wild Boar          │    │
│  │  │Animal│ Distance: 800m             │    │
│  │  │Image │ Direction: North           │    │
│  │  └─────┘ [View Details] [Navigate]  │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │     SAFETY TIPS SECTION             │    │
│  │     • Stay indoors                   │    │
│  │     • Avoid forest trails            │    │
│  │     • Keep pets inside               │    │
│  └─────────────────────────────────────┘    │
│                                             │
├─────────────────────────────────────────────┤
│  BOTTOM: [Home] [Map] [Tips] [Settings]    │
└─────────────────────────────────────────────┘
```

---

## 2.3 Alert Level System

### Alert Levels Specification

| Level | Name | Color | Icon | Action Required |
|-------|------|-------|------|-----------------|
| 3 | DANGER | `#D50000` Red | ⚠️ | Seek shelter immediately |
| 2 | WARNING | `#FF6D00` Orange | ⚡ | Stay alert, avoid area |
| 1 | CAUTION | `#FFD600` Yellow | ℹ️ | Be aware |
| 0 | SAFE | `#00C853` Green | ✓ | Normal activity |

### Distance Thresholds

| Distance | Alert Level | Message |
|----------|-------------|---------|
| < 100m | DANGER (Red) | "Animal very close - Seek shelter!" |
| 100-500m | WARNING (Orange) | "Animal approaching - Stay alert" |
| 500m-1km | CAUTION (Yellow) | "Movement detected nearby" |
| > 1km | SAFE (Green) | "No nearby threats" |

---

## 2.4 UI Components Specification

### 2.4.1 Alert Banner (Emergency)

```
┌────────────────────────────────────────────────────────────┐
│ ████████████████████████████████████████████████████████  │
│ █  ⚠⚠⚠  DANGER ALERT  ⚠⚠⚠                              █  │
│ █                                                        █  │
│ █  Wild Boar detected 800m from your location          █  │
│ █                                                        █  │
│ █       [VIEW ON MAP]        [GET DIRECTIONS]          █  │
│ ████████████████████████████████████████████████████████  │
└────────────────────────────────────────────────────────────┘
```

- **Animation**: Flashing/pulsing border (red)
- **Sound**: Optional emergency alert sound
- **Vibration**: Strong haptic feedback (if enabled)
- **Auto-dismiss**: After 30 seconds or user action

### 2.4.2 Safety Status Card

```
┌────────────────────────────────────────────┐
│        🟢  YOU ARE SAFE  🟢                │
│                                            │
│   No dangerous animals detected            │
│   within 1km radius                        │
│                                            │
│   Last updated: 2 hours ago               │
└────────────────────────────────────────────┘
```

- **Size**: Large, prominent card
- **Color**: Green background tint
- **Icon**: Large checkmark with glow

### 2.4.3 Alert Detail Card

```
┌────────────────────────────────────────────┐
│ ┌────────────┐                            │
│ │            │   WILD BOAR                │
│ │  ANIMAL    │   DETECTED                 │
│ │   IMAGE    │                            │
│ │            │   Distance: 800m           │
│ │   150x150  │   Direction: North         │
│ │            │   Time: 5 minutes ago       │
│ └────────────┘                            │
│                                            │
│   ⚠ WARNING: Do not approach              │
│                                            │
│   [  🗺️ View on Map  ]                   │
└────────────────────────────────────────────┘
```

- **Image**: Large, clear animal image
- **Distance**: Large, readable number (48sp)
- **Actions**: Primary buttons for navigation

### 2.4.4 Safety Tips Section

```
┌────────────────────────────────────────────┐
│   🛡️ SAFETY TIPS                          │
│                                            │
│   📍 If you see an animal:                │
│   • Stay calm and do not run              │
│   • Back away slowly                      │
│   • Do not turn your back                 │
│                                            │
│   🏠 At home:                             │
│   • Keep doors and windows closed         │
│   • Store food securely                   │
│   • Keep pets indoors at night            │
│                                            │
│   📞 Emergency: 112                       │
└────────────────────────────────────────────┘
```

- **Collapsible**: Yes, tap to expand/collapse
- **Icons**: Clear, recognizable icons
- **Font**: Large, high contrast

---

## 2.5 Civilian App Data Models

### User Location Model

```dart
class UserLocation {
  double latitude;
  double longitude;
  DateTime timestamp;
  double accuracy;  // in meters
}

class Alert {
  String id;
  String animalType;
  String animalImageUrl;
  AlertLevel level;     // danger, warning, caution, safe
  double distanceFromUser;  // in meters
  double directionFromUser;  // 0-360 degrees
  DateTime detectedAt;
  double latitude;
  double longitude;
  String message;
  bool isActive;
}

enum AlertLevel { danger, warning, caution, safe }
```

---

## 2.6 Animation Specifications (Civilian App)

| Element | Animation | Duration | Trigger |
|---------|-----------|----------|---------|
| Alert Banner | Flash + Slide Down | 300ms | New alert |
| Status Change | Color morph | 500ms | Alert level change |
| Distance Update | Number counter | 300ms | Location update |
| Map Marker | Pulse ripple | 2000ms (loop) | Alert active |
| Safe Status | Gentle pulse | 3000ms (loop) | Always |
| Button Press | Scale + Glow | 150ms | Touch |

---

# Part 3: Implementation Priorities

## Phase 1: Core Functionality

1. **Forest Officer Dashboard**
   - [ ] Implement glassmorphism card system
   - [ ] Create detection card component
   - [ ] Build statistics display
   - [ ] Add alert banner with animations

2. **Civilian App**
   - [ ] Create safety status display
   - [ ] Implement alert card component
   - [ ] Build distance calculation
   - [ ] Add safety tips section

## Phase 2: Visual Enhancement

1. **Forest Officer Dashboard**
   - [ ] Add activity charts (fl_chart package)
   - [ ] Implement filter system
   - [ ] Enhance map integration
   - [ ] Add micro-animations

2. **Civilian App**
   - [ ] Enhance map visualization
   - [ ] Add emergency alert animations
   - [ ] Implement notification system

## Phase 3: Polish

1. [ ] Review and optimize all animations
2. [ ] Ensure accessibility (contrast, touch targets)
3. [ ] Test on various screen sizes
4. [ ] Add loading states and error handling

---

# Appendix: Required Assets

## Icons (Material Icons)
- `pets` - Wildlife/animals
- `warning_amber` - Caution alerts
- `error` - Danger alerts
- `check_circle` - Safe status
- `location_on` - Location/GPS
- `map` - Map view
- `notifications` - Alerts
- `history` - History
- `filter_list` - Filters
- `security` - Safety

## Custom Assets Needed
- Animal silhouette icons (Tiger, Leopard, Wild Boar, Deer, Fox, Bear, Elephant)
- Forest department logo
- App logos for both apps
- Empty state illustrations
- Map marker custom icons

## Package Recommendations

| Package | Version | Purpose |
|---------|---------|---------|
| fl_chart | ^0.68.0 | Activity graphs |
| google_maps_flutter | ^2.5.3 | Map display |
| geolocator | ^11.0.0 | GPS location |
| flutter_animate | ^4.5.0 | Animations |
| shimmer | ^3.0.0 | Loading effects |
| cached_network_image | ^3.3.1 | Image caching |
| flutter_svg | ^2.0.10 | SVG support |

---

*Document Version: 1.0*
*Last Updated: 2026-03-24*
*Project: Wild Guardian - Wildlife Monitoring System*
