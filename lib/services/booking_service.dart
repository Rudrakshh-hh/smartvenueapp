import 'dart:async';
import 'dart:collection';

/// An OS-level Process representation of a Booking Request.
class BookingProcess {
  final String userId;
  final String venueId;
  final DateTime timeSlot;
  
  // OS Process Control Block (PCB) state simulation
  int ticketNumber = 0;
  bool isChoosingTicket = false;
  
  BookingProcess({
    required this.userId,
    required this.venueId,
    required this.timeSlot,
  });
}

/// A Counting Semaphore used to manage venue capacity.
/// If capacity is 1, it acts as a Binary Semaphore for the venue.
class CountingSemaphore {
  int _permits;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  CountingSemaphore(this._permits);

  /// P operation (Wait/Acquire)
  Future<void> wait() async {
    if (_permits > 0) {
      _permits--;
      return Future.value();
    } else {
      // Resource is exhausted, push to Blocked Queue
      final completer = Completer<void>();
      _waitQueue.addLast(completer);
      return completer.future;
    }
  }

  /// V operation (Signal/Release)
  void signal() {
    if (_waitQueue.isNotEmpty) {
      // Wake up the next process in the Blocked Queue (FCFS)
      final next = _waitQueue.removeFirst();
      next.complete();
    } else {
      _permits++;
    }
  }
}

/// Binary Semaphore (Mutex) for encapsulating the Critical Section.
class Mutex {
  bool _isLocked = false;
  final Queue<Completer<void>> _blockedQueue = Queue<Completer<void>>();

  /// Lock (Acquire)
  Future<void> lock() async {
    if (!_isLocked) {
      _isLocked = true;
      return Future.value();
    } else {
      final completer = Completer<void>();
      _blockedQueue.addLast(completer);
      return completer.future;
    }
  }

  /// Unlock (Release)
  void unlock() {
    if (_blockedQueue.isNotEmpty) {
      final next = _blockedQueue.removeFirst();
      next.complete();
    } else {
      _isLocked = false;
    }
  }
}

/// OS Monitor for Booking System
/// Uses Lamport's Bakery Algorithm and Mutexes to guarantee zero race conditions.
class BookingOSMonitor {
  // Lamport's Bakery Algorithm State (Ready Queue)
  final List<BookingProcess> _readyQueue = [];
  
  // Mutex to protect the Critical Section (Database Writes)
  final Mutex _criticalSectionMutex = Mutex();
  
  // Counting Semaphores mapped by Venue ID
  final Map<String, CountingSemaphore> _venueSemaphores = {};
  
  // Mock Database state
  final Map<String, List<BookingProcess>> _databaseState = {};

  // Singleton pattern
  static final BookingOSMonitor _instance = BookingOSMonitor._internal();
  factory BookingOSMonitor() => _instance;
  BookingOSMonitor._internal();

  /// Initialize a venue's capacity in the OS Monitor.
  /// For a standard room, capacity is 1 (Binary Semaphore).
  /// For a multi-seat hall, capacity > 1 (Counting Semaphore).
  void registerVenueCapacity(String venueId, int capacity) {
    if (!_venueSemaphores.containsKey(venueId)) {
      _venueSemaphores[venueId] = CountingSemaphore(capacity);
    }
  }

  /// Entry point for a booking request. Treated as a concurrent OS Process.
  Future<bool> requestBooking(BookingProcess process) async {
    // ---------------------------------------------------------
    // PHASE 1: ENTER THE BAKERY (Lamport's FCFS Ticketing)
    // ---------------------------------------------------------
    _enterBakery(process);

    // Wait until it's this process's strictly ordered turn
    await _awaitMyTurn(process);

    bool success = false;

    // ---------------------------------------------------------
    // PHASE 2: ACQUIRE MUTEX (Enter Critical Section)
    // ---------------------------------------------------------
    print("[OS Kernel] Process ${process.userId} requesting Mutex Lock...");
    await _criticalSectionMutex.lock();
    try {
      print("[OS Kernel] Process ${process.userId} entered CRITICAL SECTION.");
      
      // ---------------------------------------------------------
      // PHASE 3: CHECK SEMAPHORE (Atomic CAS Simulation)
      // ---------------------------------------------------------
      final venueSemaphore = _venueSemaphores[process.venueId];
      if (venueSemaphore != null) {
        
        // Attempt to claim one capacity slot. 
        // If 0, it will suspend the process until someone cancels (Signal).
        // Wait! In a strict booking system, if full, we might just fail. 
        // Let's implement an atomic check to fail fast if full.
        if (venueSemaphore._permits > 0) {
           await venueSemaphore.wait(); // Atomic decrement
           
           // Simulated DB Transaction (Atomic commit)
           _databaseState.putIfAbsent(process.venueId, () => []);
           _databaseState[process.venueId]!.add(process);
           success = true;
           
           print("[DB Write] Process ${process.userId} successfully booked Venue ${process.venueId}.");
        } else {
           print("[OS Kernel] Venue ${process.venueId} is out of capacity. Rejecting Process ${process.userId}.");
           success = false;
        }

      } else {
        print("[OS Error] Venue ${process.venueId} not registered in hardware monitor.");
      }
    } catch (e) {
      success = false;
      print("[OS Exception] Kernel panic in Critical Section: $e");
    } finally {
      // ---------------------------------------------------------
      // PHASE 4: RELEASE MUTEX (Exit Critical Section)
      // ---------------------------------------------------------
      _readyQueue.remove(process);
      _criticalSectionMutex.unlock();
      print("[OS Kernel] Process ${process.userId} exited CRITICAL SECTION and released Mutex.");
    }

    return success;
  }

  /// Lamport's Bakery Algorithm: Doorway Phase
  /// Atomically assigns the next available FCFS ticket to the process.
  void _enterBakery(BookingProcess process) {
    process.isChoosingTicket = true;
    _readyQueue.add(process);

    int maxTicket = 0;
    for (var p in _readyQueue) {
      if (p.ticketNumber > maxTicket) {
        maxTicket = p.ticketNumber;
      }
    }
    
    // Assign strictly increasing ticket (Ensures FCFS)
    process.ticketNumber = maxTicket + 1;
    process.isChoosingTicket = false;
    print("[Lamport Bakery] Process ${process.userId} assigned ticket #${process.ticketNumber}.");
  }

  /// Lamport's Bakery Algorithm: Waiting Phase
  /// Enforces mutual exclusion by halting process execution until its ticket is the lowest.
  Future<void> _awaitMyTurn(BookingProcess myProcess) async {
    for (var otherProcess in List<BookingProcess>.from(_readyQueue)) {
      if (otherProcess == myProcess) continue;

      // 1. Wait if the other process is currently reading the ticket counter
      while (otherProcess.isChoosingTicket) {
        await Future.delayed(const Duration(milliseconds: 5)); // Yield to Event Loop
      }

      // 2. Wait if the other process holds a lower ticket, OR
      // if tickets are identical, fallback to Process ID (UserId) to break the tie mathematically.
      while (otherProcess.ticketNumber != 0 &&
            ((otherProcess.ticketNumber < myProcess.ticketNumber) ||
            (otherProcess.ticketNumber == myProcess.ticketNumber && 
             otherProcess.userId.compareTo(myProcess.userId) < 0))) {
        
        if (!_readyQueue.contains(otherProcess)) break;
        await Future.delayed(const Duration(milliseconds: 5)); // Yield to Event Loop
      }
    }
  }

  /// Releases a booking, executing a V (Signal) operation on the Semaphore.
  Future<void> cancelBooking(BookingProcess process) async {
    await _criticalSectionMutex.lock();
    try {
      final venueState = _databaseState[process.venueId];
      if (venueState != null && venueState.remove(process)) {
        // V operation: Release a permit back to the counting semaphore
        _venueSemaphores[process.venueId]?.signal();
        print("[OS Kernel] Process ${process.userId} cancelled booking. Semaphore released for Venue ${process.venueId}.");
      }
    } finally {
      _criticalSectionMutex.unlock();
    }
  }

  /// Helper to view the current bookings (Read-only state)
  List<BookingProcess> getBookingsForVenue(String venueId) {
    return _databaseState[venueId] ?? [];
  }
}
