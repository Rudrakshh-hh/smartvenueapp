import 'booking_service.dart';

void main() async {
  final monitor = BookingOSMonitor();
  
  // Register a venue with capacity of 1 (Binary Semaphore)
  monitor.registerVenueCapacity("VENUE_A", 1);
  
  final process1 = BookingProcess(userId: "USER_001", venueId: "VENUE_A", timeSlot: DateTime.now());
  final process2 = BookingProcess(userId: "USER_002", venueId: "VENUE_A", timeSlot: DateTime.now());
  final process3 = BookingProcess(userId: "USER_003", venueId: "VENUE_A", timeSlot: DateTime.now());

  print("--- INITIATING CONCURRENT BOOKING REQUESTS ---");
  // Simulate race condition
  Future.wait([
    monitor.requestBooking(process1),
    monitor.requestBooking(process2),
    monitor.requestBooking(process3),
  ]);
}
