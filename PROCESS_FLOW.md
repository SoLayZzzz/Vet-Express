# VET Express – Process Flow

This document maps the major screens and GetX routes, grouped by feature, and outlines typical navigation paths through the app.

## Startup & Auth
- **Entry**
  - `SplashScreen` → preloads ads and app/device info → `AdsScreen`
- **Ads decision**
  - `AdsScreen`
    - If `AppPref.isLoggedIn() == true` → `AppRoutes.home`
    - Else → `AppRoutes.signIn`
- **Sign-in / Registration / Reset**
  - `AppRoutes.signIn` → on success → `AppRoutes.home`
  - Register → `AppRoutes.verifyCode` (identify=1) → success → `AppRoutes.home`
  - Forgot password → `AppRoutes.verifyCode` (identify=2/3) → `AppRoutes.newPassword` → `AppRoutes.signIn`

## Dashboard & Tabs
- **Home shell**
  - `AppRoutes.home` → `DashboardScreen(from)` with 5 tabs
    - 0 → `MenuScreen`
    - 1 → `TrackingScreen`
    - 2 → `ScanQrScreen`
    - 3 → `MemberShipScreen`
    - 4 → `LocationScreen`
- **Initial deeplink behavior (via `from`)**
  - `from=1` → open `SelfServiceScreen`
  - `from=2` → `AppRoutes.ticketHistory`
  - `from=5` → `AppRoutes.packageHistory`

## Ticket Booking (Bus / Air / Boat)
- **Start**
  - `MenuScreen` → choose booking type → `AppRoutes.ticketMenu`
- **Select route & date**
  - Origin selection → `AppRoutes.selectTicket`
  - Destination selection → `AppRoutes.selectTicket`
  - Search → `AppRoutes.scheduleList` (`isBack=false`)
- **Explore**
  - From schedule list → optional details → `AppRoutes.ticketScheduleCarDetail`
- **Choose schedule**
  - Schedule chosen → `AppRoutes.selectSeat` (`isBack=false`)
  - If round-trip (`ValueStatic.journeyType == 2`)
    - After Go seats → `AppRoutes.scheduleList` (`isBack=true`) → choose Return schedule → `AppRoutes.selectSeat` (`isBack=true`)
- **Passenger & Payment**
  - Seats confirmed → `AppRoutes.passengerDetail`
  - Proceed to pay → `AppRoutes.payment`
    - ABA (KHQR/Card/Alipay) → `AppRoutes.paymentAba` → `PaymentABAScreen`
    - Wing → `AppRoutes.paymentWing` → `PaymentWingScreen`
    - On success → success dialog → navigate to `AppRoutes.home` or `AppRoutes.ticketHistory`
- **Extras**
  - Reviews from schedule list → `AppRoutes.reviewRate`

## EV Charger: Wallet, Stations, Payments
- **Main**
  - `MenuScreen` → `AppRoutes.evCharger`
- **Wallet & Top-up**
  - `AppRoutes.evWallet` → `AppRoutes.evTopUp`
    - Initiate top-up (deep link and KHQR) → `AppRoutes.evPayment`
    - Controller polls payment status
    - On APPROVED → close payment screens → `AppRoutes.evPaymentSuccess` → back to `AppRoutes.evWallet`
- **Stations & Tools**
  - All stations map → `AppRoutes.evAllStations`
    - Province filter → `AppRoutes.evSelectProvince`
    - Full search → `AppRoutes.evSearchStations`
  - Favorites → `AppRoutes.evFavorites`
  - News/FAQ/Policy → `AppRoutes.evNewsFeed`, `AppRoutes.evFaq`, `AppRoutes.evPolicy`
  - QR scan → `AppRoutes.evQrScanner`

## Self Service (Logistics)
- **Flow**
  - `AppRoutes.selfService` → `AppRoutes.selfServiceSelect` → `AppRoutes.selfServiceCheck`
  - Generate QR → `AppRoutes.selfServiceQr`
  - View list/history → `AppRoutes.selfServiceQrList`

## China Service (Access Address)
- **Decision**
  - From `MenuScreen`
    - If user has customers → `AppRoutes.warehouseAddress`
    - Else → `AppRoutes.chinaRegistration`
- **Edit**
  - `AppRoutes.chinaEditInfo`

## Car Rental
- **Flow**
  - `AppRoutes.carRentalList` → `AppRoutes.carRentalDetail` → `AppRoutes.carRentalInfo`
  - Province selection when needed → `AppRoutes.carRentalSelectProvince`

## Travel Packages
- **Flow**
  - `AppRoutes.travelPackageList` → payment via ABA
    - `AppRoutes.paymentAbaPackage` → `PaymentABAPackageScreen`

## Booking Delivery
- **Flow**
  - `AppRoutes.bookingDelivery`

## Member & Notifications
- **Screens**
  - `AppRoutes.memberAccountDetail`
  - `AppRoutes.notifications`
  - `AppRoutes.contactUs`

## History
- **Screens**
  - `AppRoutes.ticketHistory`
  - `AppRoutes.packageHistory`
  - `AppRoutes.goodsTransferHistory`

## Utilities
- **Screens**
  - `AppRoutes.scanQr`
  - `AppRoutes.vetAirway`
