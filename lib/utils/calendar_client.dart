import 'package:events_demo/secrets.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarClient {
  static const _scopes = const [CalendarApi.CalendarScope];

  Future<Map<String, String>> insert({
    @required String title,
    @required String description,
    @required String location,
    @required List<EventAttendee> attendeeEmailList,
    @required bool shouldNotifyAttendees,
    @required bool hasConferenceSupport,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    var _clientID = new ClientId(Secret.getId(), "");
    Map<String, String> eventData;

    await clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) async {
      var calendar = CalendarApi(client);

      String calendarId = "primary";
      Event event = Event();

      event.summary = title;
      event.description = description;
      event.attendees = attendeeEmailList;
      event.location = location;

      if (hasConferenceSupport) {
        ConferenceData conferenceData = ConferenceData();
        CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
        conferenceRequest.requestId = "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
        conferenceData.createRequest = conferenceRequest;

        event.conferenceData = conferenceData;
      }

      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+05:30";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+05:30";
      end.dateTime = endTime;
      event.end = end;

      try {
        await calendar.events
            .insert(event, calendarId,
                conferenceDataVersion: hasConferenceSupport ? 1 : 0,
                sendUpdates: shouldNotifyAttendees ? "all" : "none")
            .then((value) {
          print("Event Status: ${value.status}");
          if (value.status == "confirmed") {
            String joiningLink;
            String eventId;

            eventId = value.id;

            if (hasConferenceSupport) {
              joiningLink = "https://meet.google.com/${value.conferenceData.conferenceId}";
            }

            eventData = {'id': eventId, 'link': joiningLink};

            print('Event added to Google Calendar');
          } else {
            print("Unable to add event to Google Calendar");
          }
        });
      } catch (e) {
        print('Error creating event $e');
      }
    });

    return eventData;
  }

  Future<Map<String, String>> modify({
    @required String id,
    @required String title,
    @required String description,
    @required String location,
    @required List<EventAttendee> attendeeEmailList,
    @required bool shouldNotifyAttendees,
    @required bool hasConferenceSupport,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    var _clientID = new ClientId(Secret.ANDROID_CLIENT_ID, "");
    Map<String, String> eventData;

    await clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) async {
      var calendar = CalendarApi(client);

      String calendarId = "primary";
      Event event = Event();

      event.summary = title;
      event.description = description;
      event.attendees = attendeeEmailList;
      event.location = location;

      if (hasConferenceSupport) {
        ConferenceData conferenceData = ConferenceData();
        CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
        conferenceRequest.requestId = "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
        conferenceData.createRequest = conferenceRequest;

        event.conferenceData = conferenceData;
      }

      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+05:30";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+05:30";
      end.dateTime = endTime;
      event.end = end;

      try {
        await calendar.events
            .patch(event, calendarId, id,
                conferenceDataVersion: hasConferenceSupport ? 1 : 0,
                sendUpdates: shouldNotifyAttendees ? "all" : "none")
            .then((value) {
          print("Event Status: ${value.status}");
          if (value.status == "confirmed") {
            String joiningLink;
            String eventId;

            eventId = value.id;

            if (hasConferenceSupport) {
              joiningLink = "https://meet.google.com/${value.conferenceData.conferenceId}";
            }

            eventData = {'id': eventId, 'link': joiningLink};

            print('Event updated in google calendar');
          } else {
            print("Unable to update event in google calendar");
          }
        });
      } catch (e) {
        print('Error updating event $e');
      }
    });

    return eventData;
  }

  Future<void> delete(String eventId, bool shouldNotify) async {
    var _clientID = new ClientId(Secret.getId(), "");

    await clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) async {
      var calendar = CalendarApi(client);

      String calendarId = "primary";

      try {
        await calendar.events.delete(calendarId, eventId, sendUpdates: shouldNotify ? "all" : "null").then((value) {
          print('Event deleted from Google Calendar');
        });
      } catch (e) {
        print('Error deleting event: $e');
      }
    });
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
