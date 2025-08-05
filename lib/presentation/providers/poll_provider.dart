import 'package:flutter/material.dart';
import '../../data/models/poll_model.dart';
import '../../data/services/poll_service.dart';

class PollProvider with ChangeNotifier {
  List<Poll> _polls = [];
  Poll? _currentPoll;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Poll> get polls => _polls;
  Poll? get currentPoll => _currentPoll;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Alle Polls laden
  Future<void> loadPolls() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PollService.getAllPolls();
      
      if (result['success']) {
        _polls = result['polls'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Fehler beim Laden der Abstimmungen: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Einzelne Poll laden
  Future<void> loadPollById(int pollId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PollService.getPollById(pollId);
      
      if (result['success']) {
        _currentPoll = result['poll'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Fehler beim Laden der Abstimmung: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Abstimmen
  Future<bool> vote(int pollId, int optionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PollService.vote(pollId, optionId);
      
      if (result['success']) {
        // Poll neu laden um aktuelle Ergebnisse zu bekommen
        await loadPollById(pollId);
        // Auch die Poll-Liste aktualisieren
        await loadPolls();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Fehler beim Abstimmen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Neue Poll erstellen
  Future<bool> createPoll(CreatePollRequest pollRequest) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PollService.createPoll(pollRequest);
      
      if (result['success']) {
        // Neue Poll zur Liste hinzufügen
        _polls.insert(0, result['poll']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Fehler beim Erstellen der Abstimmung: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Poll Results aktualisieren
  Future<void> refreshPollResults(int pollId) async {
    try {
      final result = await PollService.getPollResults(pollId);
      
      if (result['success']) {
        if (_currentPoll?.id == pollId) {
          // Aktualisiere die aktuelle Poll mit neuen Ergebnissen
          _currentPoll = Poll(
            id: _currentPoll!.id,
            title: _currentPoll!.title,
            description: _currentPoll!.description,
            creatorId: _currentPoll!.creatorId,
            creatorName: _currentPoll!.creatorName,
            pollType: _currentPoll!.pollType,
            startDate: _currentPoll!.startDate,
            endDate: _currentPoll!.endDate,
            isActive: _currentPoll!.isActive,
            isPublic: _currentPoll!.isPublic,
            createdAt: _currentPoll!.createdAt,
            totalVotes: result['totalVotes'],
            options: result['options'],
            userVote: _currentPoll!.userVote,
          );
          
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error refreshing poll results: $e');
    }
  }

  // Error zurücksetzen
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Current Poll zurücksetzen
  void clearCurrentPoll() {
    _currentPoll = null;
    notifyListeners();
  }

  // Polls nach Status filtern
  List<Poll> get activePolls => _polls.where((poll) => poll.canVote).toList();
  List<Poll> get endedPolls => _polls.where((poll) => poll.hasEnded).toList();
  List<Poll> get myVotedPolls => _polls.where((poll) => poll.hasUserVoted).toList();
}