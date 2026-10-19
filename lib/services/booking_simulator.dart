import '../models/venue.dart';
import 'booking_service.dart';

void main() async {
  final monitor = BookingOSMonitor();
  
  // Register default test venue with Binary Semaphore capacity (1 seat)
  final testVenue = Venue.testVenueBinary;
  monitor.registerVenueCapacity(testVenue.id, testVenue.capacity);
  
  final process1 = BookingProcess(userId: "USER_001", venueId: testVenue.id, timeSlot: DateTime.now());
  final process2 = BookingProcess(userId: "USER_002", venueId: testVenue.id, timeSlot: DateTime.now());
  final process3 = BookingProcess(userId: "USER_003", venueId: testVenue.id, timeSlot: DateTime.now());

  print("--- INITIATING CONCURRENT BOOKING REQUESTS FOR ${testVenue.name} (${testVenue.code}) ---");
  // Simulate race condition
  Future.wait([
    monitor.requestBooking(process1),
    monitor.requestBooking(process2),
    monitor.requestBooking(process3),
  ]);
}
