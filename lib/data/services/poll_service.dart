import '../models/poll_model.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PollService {
  // Alle öffentlichen Polls abrufen
  static Future<Map<String, dynamic>> getAllPolls() async {
    try {
      final token = await AuthService.getToken();
      final result = await ApiService.get(ApiConstants.polls, token: token);

      print('DEBUG Backend Response: ${result['data']}'); 

      if (result['success']) {
        final pollsData = result['data']['polls'] as List;
        final polls = pollsData.map((pollJson) => Poll.fromJson(pollJson)).toList();
        
        return {
          'success': true,
          'polls': polls,
          'count': result['data']['count'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Laden der Abstimmungen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Einzelne Poll mit Optionen abrufen
  static Future<Map<String, dynamic>> getPollById(int pollId) async {
    try {
      final token = await AuthService.getToken();
      final result = await ApiService.get(
        ApiConstants.pollById(pollId), 
        token: token,
      );
      
      if (result['success']) {
        final pollData = result['data'];
        
        // Poll mit Optionen zusammenfügen
        final poll = Poll.fromJson({
          ...pollData['poll'],
          'options': pollData['options'],
          'userVote': pollData['userVote'],
          'total_votes': pollData['totalVotes'],
        });
        
        return {
          'success': true,
          'poll': poll,
          'userVote': pollData['userVote'],
          'totalVotes': pollData['totalVotes'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Poll nicht gefunden',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Abstimmen
  static Future<Map<String, dynamic>> vote(int pollId, int optionId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      final result = await ApiService.post(
        ApiConstants.pollVote(pollId),
        {'optionId': optionId},
        token: token,
      );
      
      return {
        'success': result['success'],
        'message': result['success'] ? 'Stimme erfolgreich abgegeben!' : null,
        'error': result['error'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Poll Ergebnisse abrufen
  static Future<Map<String, dynamic>> getPollResults(int pollId) async {
    try {
      final result = await ApiService.get(ApiConstants.pollResults(pollId));
      
      if (result['success']) {
        final resultsData = result['data']['results'] as List;
        final options = resultsData.map((optionJson) => PollOption.fromJson(optionJson)).toList();
        
        return {
          'success': true,
          'options': options,
          'totalVotes': result['data']['totalVotes'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Laden der Ergebnisse',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Neue Poll erstellen
  static Future<Map<String, dynamic>> createPoll(CreatePollRequest pollRequest) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      // Admin-Status prüfen
      final user = await AuthService.getUser();
      if (user == null || !user.isAdmin) {
        return {
          'success': false,
          'error': 'Nur Administratoren können Abstimmungen erstellen',
        };
      }

      final result = await ApiService.post(
        ApiConstants.polls,
        pollRequest.toJson(),
        token: token,
      );
      
      if (result['success']) {
        final poll = Poll.fromJson({
          ...result['data']['poll'],
          'options': result['data']['options'],
          'total_votes': 0,
        });
        
        return {
          'success': true,
          'poll': poll,
          'message': 'Abstimmung erfolgreich erstellt!',
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Erstellen der Abstimmung',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Eigene Polls abrufen
  static Future<Map<String, dynamic>> getMyPolls() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht angemeldet',
        };
      }

      final result = await ApiService.get(
        '${ApiConstants.polls}/my/polls',
        token: token,
      );
      
      if (result['success']) {
        final pollsData = result['data']['polls'] as List;
        final polls = pollsData.map((pollJson) => Poll.fromJson(pollJson)).toList();
        
        return {
          'success': true,
          'polls': polls,
          'count': result['data']['count'],
        };
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Fehler beim Laden der eigenen Abstimmungen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }
}