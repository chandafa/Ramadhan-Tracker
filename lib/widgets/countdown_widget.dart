import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  PrayerTimes? _prayerTimes;
  Prayer? _nextPrayer;
  Duration _timeRemaining = Duration.zero;
  Timer? _timer;
  String _locationName = 'Locating...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayers();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextPrayer != null && _prayerTimes != null) {
        _updateTimeRemaining();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndPrayers() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationName = 'Location Disabled';
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationName = 'Permission Denied';
            _isLoading = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationName = 'My Location'; // Could use geocoding to get city name
      });

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      setState(() {
        _prayerTimes = prayerTimes;
        _nextPrayer = _prayerTimes!.nextPrayer();
        _updateTimeRemaining();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Error';
        _isLoading = false;
      });
      print('Error getting location: $e');
    }
  }

  String _targetLabel = 'COUNTDOWN';

  void _updateTimeRemaining() {
    if (_prayerTimes == null) return;

    DateTime nextTime;
    final now = DateTime.now();
    final fajr = _prayerTimes!.fajr;
    final maghrib = _prayerTimes!.maghrib;

    bool isSahurTime = now.isBefore(fajr);
    bool isIftarTime = now.isAfter(fajr) && now.isBefore(maghrib);

    String newLabel;

    if (isSahurTime) {
      nextTime = fajr;
      newLabel = 'COUNTDOWN TO SAHUR';
    } else if (isIftarTime) {
      nextTime = maghrib;
      newLabel = 'COUNTDOWN TO IFTAR';
    } else {
      // Target tomorrow Fajr
      nextTime = fajr.add(const Duration(days: 1));
      newLabel = 'COUNTDOWN TO SAHUR';
    }

    final diff = nextTime.difference(now);

    // Only update state if needed to avoid spam? No, timer runs every second.
    setState(() {
      _timeRemaining = diff;
      _nextPrayer = isSahurTime ? Prayer.fajr : Prayer.maghrib;
      _targetLabel = newLabel;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D471C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D471C).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _locationName,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _targetLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_timeRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Monospace for numbers
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeItem('Fajr', _prayerTimes?.fajr),
              _buildTimeItem('Maghrib', _prayerTimes?.maghrib),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, DateTime? time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
